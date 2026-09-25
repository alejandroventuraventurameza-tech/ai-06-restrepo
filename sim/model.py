"""
Static equilibrium solvers for Acemoglu & Restrepo (NBER WP 22252, June 2017), Section 2.

Two models:
  * ModelS  - the hand-derivable special case of derivation/derivation.tex
              (eta = 0, sigma = 1, general increasing labor supply).
  * ModelG  - the paper's static model with eta -> 0 (Assumption 2(i)), general
              sigma_hat = sigma != 1, B = 1, general increasing labor supply.

Design rule: the solvers compute equilibria from the equilibrium conditions
(market clearing, price index, labor supply, threshold) by root finding and
quadrature. They never use the comparative-statics formulas being tested, so
finite-difference derivatives of these solvers are an independent check of the
formulas in derivation.tex and of the paper's Proposition 3.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Callable

import numpy as np
from scipy.integrate import quad
from scipy.optimize import brentq

EDGE = 1e-9  # keep thresholds strictly inside (N-1, N)


# ---------------------------------------------------------------------------
# Primitive families (all satisfy the named assumptions of derivation.tex)
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Gamma:
    """Comparative-advantage schedule: log gamma(i) = A*i + c*tanh(i - m) + d.
    Strictly increasing (A > 0, c >= 0), continuous, positive  -> A1 and C."""
    A: float
    c: float = 0.0
    m: float = 0.0
    d: float = 0.0

    def log(self, i: float) -> float:
        return self.A * i + self.c * np.tanh(i - self.m) + self.d

    def __call__(self, i: float) -> float:
        return float(np.exp(self.log(i)))

    def dlog(self, i: float) -> float:
        return self.A + self.c * (1.0 - np.tanh(i - self.m) ** 2)


@dataclass(frozen=True)
class LaborSupply:
    """Increasing labor supply L^s(omega) > 0 with elasticity in (0, inf) -> LS.
    kind 0: l0 * omega**e                      (constant elasticity e)
    kind 1: l0 * (1 + omega)**e                (elasticity e*omega/(1+omega))
    kind 2: l0 * omega**e / (1 + omega**e)**h  (elasticity e*(1 - h*omega**e/(1+omega**e)), h in (0,1))"""
    kind: int
    l0: float
    e: float
    h: float = 0.5

    def __call__(self, w: float) -> float:
        if self.kind == 0:
            return self.l0 * w ** self.e
        if self.kind == 1:
            return self.l0 * (1.0 + w) ** self.e
        return self.l0 * w ** self.e / (1.0 + w ** self.e) ** self.h

    def log_at(self, t: float) -> float:
        """ln L^s(e^t), overflow-safe."""
        if self.kind == 0:
            return np.log(self.l0) + self.e * t
        if self.kind == 1:
            return np.log(self.l0) + self.e * np.logaddexp(0.0, t)
        return np.log(self.l0) + self.e * t - self.h * np.logaddexp(0.0, self.e * t)

    def elasticity(self, w: float) -> float:
        if self.kind == 0:
            return self.e
        if self.kind == 1:
            return self.e * w / (1.0 + w)
        z = w ** self.e
        return self.e * (1.0 - self.h * z / (1.0 + z))


def _root_log(f_log: Callable[[float], float], lo: float = -5000.0, hi: float = 5000.0) -> float:
    """Root in omega of an increasing function given in log form: f_log(t) with omega = exp(t)."""
    if not (f_log(lo) < 0 < f_log(hi)):
        raise ValueError("root not bracketed")
    return float(np.exp(brentq(f_log, lo, hi, xtol=1e-14, rtol=1e-15, maxiter=500)))


# ---------------------------------------------------------------------------
# Model S: eta = 0, sigma = 1 (Cobb-Douglas across tasks)
# ---------------------------------------------------------------------------
@dataclass
class Equilibrium:
    Istar: float
    regime: str  # "R", "L" or "F"
    W: float
    R: float
    L: float
    Y: float
    omega: float
    a: float
    b: float
    K: float


class ModelS:
    def __init__(self, gamma: Gamma, Ls: LaborSupply):
        self.gamma, self.Ls = gamma, Ls

    def omega_star(self, u: float) -> float:
        """Solve omega * L^s(omega) = u (Lemma 2.4)."""
        lu = np.log(u)
        return _root_log(lambda t: t + self.Ls.log_at(t) - lu)

    def phi(self, x: float, N: float, K: float) -> float:
        """W/R if the threshold were x (Prop. 2.5)."""
        return K * self.omega_star((N - x) / (x - N + 1.0))

    def x_hat(self, N: float, K: float) -> float:
        g = lambda x: np.log(self.phi(x, N, K)) - self.gamma.log(x)
        lo, hi = N - 1.0 + 1e-10, N - 1e-10
        return float(brentq(g, lo, hi, xtol=1e-15, rtol=1e-15, maxiter=500))

    def solve(self, N: float, I: float, K: float) -> Equilibrium:
        """Equilibrium from (E1)-(E5) (Prop. 2.5): threshold, employment, output, prices."""
        xh = self.x_hat(N, K)
        Istar = min(I, xh)
        regime = "R" if I < xh else ("L" if I > xh else "F")
        a, b = Istar - N + 1.0, N - Istar
        omega = self.omega_star(b / a)
        L = self.Ls(omega)
        Y = float(np.exp(self.lnY(Istar, N, K, L)))
        return Equilibrium(Istar, regime, W=b * Y / L, R=a * Y / K, L=L, Y=Y,
                           omega=omega, a=a, b=b, K=K)

    def lnY(self, Istar: float, N: float, K: float, L: float) -> float:
        """Aggregate output (Lemma 2.3, eq. lnY) for given threshold and factors."""
        a, b = Istar - N + 1.0, N - Istar
        return (a * np.log(K / a) + b * np.log(L / b)
                + quad(self.gamma.log, Istar, N, epsabs=1e-13, epsrel=1e-13)[0])


def labor_share(eq: Equilibrium) -> float:
    return eq.W * eq.L / (eq.W * eq.L + eq.R * eq.K)


# ---------------------------------------------------------------------------
# Model G: paper's static model, eta -> 0, sigma_hat = sigma != 1, B = 1
# ---------------------------------------------------------------------------
class ModelG:
    """Equilibrium from eqs. (8)-(11) and I* = min(I, I~) with eta = 0, B = 1."""

    def __init__(self, gamma: Gamma, Ls: LaborSupply, sigma: float):
        if abs(sigma - 1.0) < 1e-9:
            raise ValueError("use ModelS for sigma = 1")
        self.gamma, self.Ls, self.s = gamma, Ls, sigma

    def Gam(self, x: float, N: float) -> float:
        return quad(lambda i: self.gamma(i) ** (self.s - 1.0), x, N, epsabs=1e-14, epsrel=1e-13)[0]

    def omega_of(self, x: float, N: float, K: float) -> float:
        """omega from the ratio of (9) to (8) and (11): omega^s L^s(omega) = (Gamma/a) K^(1-s) (eq. 13)."""
        rhs = self.Gam(x, N) / (x - N + 1.0) * K ** (1.0 - self.s)
        lr = np.log(rhs)
        return _root_log(lambda t: self.s * t + self.Ls.log_at(t) - lr)

    def x_hat(self, N: float, K: float) -> float:
        g = lambda x: np.log(K * self.omega_of(x, N, K)) - self.gamma.log(x)
        return float(brentq(g, N - 1 + 1e-9, N - 1e-9, xtol=1e-15, rtol=1e-15, maxiter=500))

    def solve(self, N: float, I: float, K: float) -> Equilibrium:
        xh = self.x_hat(N, K)
        Istar = min(I, xh)
        regime = "R" if I < xh else ("L" if I > xh else "F")
        a, b = Istar - N + 1.0, N - Istar
        omega = self.omega_of(Istar, N, K)
        L = self.Ls(omega)
        G = self.Gam(Istar, N)
        s = self.s
        # price index (10) with B = 1:  a R^(1-s) + W^(1-s) * Gamma = 1,  W = omega K R
        R = (a + (omega * K) ** (1.0 - s) * G) ** (-1.0 / (1.0 - s))
        W = omega * K * R
        Y = K * R ** s / a  # capital market clearing (8)
        return Equilibrium(Istar, regime, W=W, R=R, L=L, Y=Y, omega=omega, a=a, b=b, K=K)

    def lnY12(self, Istar: float, N: float, K: float, L: float) -> float:
        """Equation (12) with eta = 0, B = 1 (Proposition 1), for given threshold and factors."""
        s, a = self.s, Istar - N + 1.0
        r = (s - 1.0) / s
        X = a ** (1.0 / s) * K ** r + self.Gam(Istar, N) ** (1.0 / s) * L ** r
        return float(np.log(X) / r)
