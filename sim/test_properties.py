"""
Randomized property tests for derivation/derivation.tex (Model S) and for the
paper's Proposition 3 (Model G, eta -> 0, sigma_hat != 1).

Properties (numbering follows Section 7 of derivation.tex):
  P1  equilibrium conditions hold (task-level cost minimization, CD/CES demand,
      market clearing, labor supply, A3) and I* = min(I, x_hat)
  P2  productivity effect: d lnY/dI|_{K,L} = pi_I, d lnY/dN|_{K,L} = pi_N
  P3  wage / rental / share / employment derivatives match the closed forms
  P4  signs that hold everywhere in regime (R)
  P5  sign(d lnW/dI) = sign(K - K_hat) on the whole regime-(R) interval (K_I, K_under)
  P6  (symbolic, see verify_symbolic.py)
  P7  Model G: paper's Prop. 3 formulas vs finite differences; d lnW/dI < 0 near K_I;
      number of sign changes of d lnW/dI on (K_I, K_under)
  PL  regime (L): all derivatives with respect to I vanish

Every derivative is a central finite difference of an equilibrium recomputed
from scratch by model.py; no closed-form comparative static is used to compute
the "truth".

Usage:
    python3 test_properties.py                      # default sizes
    python3 test_properties.py --draws-s 5000 --draws-g 400 --seed 7
    python3 -m pytest -q test_properties.py         # small sizes, as unit tests
"""
from __future__ import annotations

import argparse
import sys
import time
from dataclasses import dataclass, field

import numpy as np
from scipy.integrate import quad
from scipy.optimize import brentq

from model import Gamma, LaborSupply, ModelG, ModelS, labor_share

H = 1e-5  # finite-difference step in I and N


# ---------------------------------------------------------------------------
# random primitives
# ---------------------------------------------------------------------------
def draw_primitives(rng: np.random.Generator):
    N = rng.uniform(-1.0, 2.0)
    I = N - 1.0 + rng.uniform(0.05, 0.95)
    gam = Gamma(A=rng.uniform(0.3, 6.0),
                c=rng.uniform(0.0, 1.0) if rng.random() < 0.5 else 0.0,
                m=rng.uniform(N - 1.0, N),
                d=rng.uniform(-1.0, 1.0))
    Ls = LaborSupply(kind=int(rng.integers(0, 3)),
                     l0=float(np.exp(rng.uniform(np.log(0.3), np.log(3.0)))),
                     e=rng.uniform(0.1, 3.0),
                     h=rng.uniform(0.1, 0.9))
    return N, I, gam, Ls


def fd(f, x, h=H):
    return (f(x + h) - f(x - h)) / (2.0 * h)


def close(x, y, rtol=2e-5, atol=2e-6):
    return abs(x - y) <= atol + rtol * max(abs(x), abs(y))


@dataclass
class Tally:
    checks: int = 0
    failures: list = field(default_factory=list)
    max_err: dict = field(default_factory=dict)

    def check(self, name, ok, err=0.0, info=""):
        self.checks += 1
        self.max_err[name] = max(self.max_err.get(name, 0.0), float(err))
        if not ok:
            self.failures.append(f"{name}: {info}")


# ---------------------------------------------------------------------------
# Model S
# ---------------------------------------------------------------------------
def check_equilibrium_S(m: ModelS, N, I, K, eq, t: Tally):
    """P1: rebuild the task-level allocation from prices and check every condition."""
    W, R, Y, L = eq.W, eq.R, eq.Y, eq.L
    g = m.gamma

    def price(i):  # (E2), note: uses I (technology), not I*
        return min(R, W / g(i)) if i <= I else W / g(i)

    def uses_capital(i):
        return i <= I and R <= W / g(i)

    cuts = sorted({N - 1.0, eq.Istar, I, N})
    cuts = [c for c in cuts if N - 1.0 <= c <= N]
    lnY = sum(quad(lambda i: np.log(Y / price(i)), lo, hi, epsabs=1e-12)[0]
              for lo, hi in zip(cuts[:-1], cuts[1:]) if hi > lo)
    Kd = sum(quad(lambda i: (Y / price(i)) if uses_capital(i) else 0.0, lo, hi, epsabs=1e-12)[0]
             for lo, hi in zip(cuts[:-1], cuts[1:]) if hi > lo)
    Ld = sum(quad(lambda i: 0.0 if uses_capital(i) else (Y / price(i)) / g(i), lo, hi, epsabs=1e-12)[0]
             for lo, hi in zip(cuts[:-1], cuts[1:]) if hi > lo)
    t.check("P1 lnY = int ln y", close(lnY, np.log(Y), 1e-8, 1e-8), abs(lnY - np.log(Y)))
    t.check("P1 capital market", close(Kd, K, 1e-8, 1e-10), abs(Kd / K - 1))
    t.check("P1 labor market", close(Ld, L, 1e-8, 1e-10), abs(Ld / L - 1))
    t.check("P1 labor supply", close(L, m.Ls(W / (R * K)), 1e-9, 1e-12), abs(L / m.Ls(W / (R * K)) - 1))
    t.check("P1 A3: R > W/gamma(N)", R > W / g(N), 0.0, f"N={N} I={I} K={K}")


def run_model_S(n_draws: int, rng: np.random.Generator, t: Tally, t_L: Tally):
    for _ in range(n_draws):
        N, I, gam, Ls = draw_primitives(rng)
        m = ModelS(gam, Ls)
        a, b = I - N + 1.0, N - I
        wI = m.omega_star(b / a)
        eps = Ls.elasticity(wI)
        K_I, K_under = gam(I) / wI, gam(N) / wI
        K_hat = K_I * np.exp(1.0 / (b * (1.0 + eps)))
        # ---- regime (R): K log-uniform on (K_I, K_under), away from the ends
        lo, hi = np.log(K_I), np.log(K_under)
        K = float(np.exp(lo + (hi - lo) * rng.uniform(0.002, 0.998)))
        eq = m.solve(N, I, K)
        if eq.regime != "R" or m.x_hat(N, K) - I < 50 * H:
            continue
        check_equilibrium_S(m, N, I, K, eq, t)
        t.check("P1 regime R <=> K in (K_I, K_under)", K_I < K < K_under)
        # P2 productivity (K, L fixed)
        piI = np.log(eq.W / (gam(I) * eq.R))
        piN = np.log(gam(N) / (eq.W / eq.R))
        dY_I = fd(lambda x: m.lnY(x, N, K, eq.L), I)
        dY_N = fd(lambda x: m.lnY(I, x, K, eq.L), N)
        t.check("P2 dlnY/dI|KL = pi_I", close(dY_I, piI), abs(dY_I - piI))
        t.check("P2 dlnY/dN|KL = pi_N", close(dY_N, piN), abs(dY_N - piN))
        # P3 total derivatives (labor adjusts, K fixed)
        sol_I = {h: m.solve(N, I + h, K) for h in (-H, H)}
        sol_N = {h: m.solve(N + h, I, K) for h in (-H, H)}
        d = lambda sol, f: (f(sol[H]) - f(sol[-H])) / (2 * H)
        dW_I = d(sol_I, lambda e: np.log(e.W)); dR_I = d(sol_I, lambda e: np.log(e.R))
        dL_I = d(sol_I, lambda e: np.log(e.L)); ds_I = d(sol_I, labor_share)
        dW_N = d(sol_N, lambda e: np.log(e.W)); dR_N = d(sol_N, lambda e: np.log(e.R))
        th_W_I = piI - 1.0 / (b * (1.0 + eps))
        th_R_I = piI + 1.0 / (a * (1.0 + eps))
        th_L_I = -eps / (1.0 + eps) / (a * b)
        th_W_N = piN + 1.0 / (b * (1.0 + eps))
        th_R_N = piN - 1.0 / (a * (1.0 + eps))
        t.check("P3 dlnW/dI", close(dW_I, th_W_I), abs(dW_I - th_W_I))
        t.check("P3 dlnR/dI", close(dR_I, th_R_I), abs(dR_I - th_R_I))
        t.check("P3 dlnL/dI", close(dL_I, th_L_I), abs(dL_I - th_L_I))
        t.check("P3 dsL/dI = -1", close(ds_I, -1.0), abs(ds_I + 1.0))
        t.check("P3 dlnW/dN", close(dW_N, th_W_N), abs(dW_N - th_W_N))
        t.check("P3 dlnR/dN", close(dR_N, th_R_N), abs(dR_N - th_R_N))
        t.check("P3 sL = N - I", close(labor_share(eq), b, 1e-10, 1e-12), abs(labor_share(eq) - b))
        # P4 signs
        t.check("P4 dlnR/dI > 0", dR_I > 0, 0, f"{dR_I}")
        t.check("P4 dlnL/dI < 0", dL_I < 0, 0, f"{dL_I}")
        t.check("P4 dsL/dI < 0", ds_I < 0, 0, f"{ds_I}")
        t.check("P4 dlnW/dN > 0", dW_N > 0, 0, f"{dW_N}")
        # P5 threshold
        if abs(np.log(K / K_hat)) > 1e-4:
            t.check("P5 sign(dlnW/dI) = sign(K - K_hat)", np.sign(dW_I) == np.sign(K - K_hat),
                    0, f"N={N:.3f} I={I:.3f} K={K:.4g} K_hat={K_hat:.4g} dW={dW_I:.3g}")
        # ---- regime (L): K below K_I -> automation has no effect
        K_L = K_I * float(np.exp(-rng.uniform(0.01, 3.0)))
        eqL = m.solve(N, I, K_L)
        t_L.check("PL regime is L when K < K_I", eqL.regime == "L", 0, f"{eqL.regime}")
        if eqL.regime == "L" and I - eqL.Istar > 50 * H:
            solL = {h: m.solve(N, I + h, K_L) for h in (-H, H)}
            for nm, f in (("W", lambda e: np.log(e.W)), ("R", lambda e: np.log(e.R)),
                          ("L", lambda e: np.log(e.L)), ("Y", lambda e: np.log(e.Y))):
                dv = (f(solL[H]) - f(solL[-H])) / (2 * H)
                t_L.check(f"PL d ln{nm}/dI = 0", abs(dv) < 1e-7, abs(dv))
            check_equilibrium_S(m, N, I, K_L, eqL, t_L)


# ---------------------------------------------------------------------------
# Model G (paper, eta -> 0, sigma != 1)
# ---------------------------------------------------------------------------
def paper_prop3(m: ModelG, N, I, eq):
    """Paper's Prop. 3 (constrained case), B = 1, evaluated at the equilibrium."""
    s, g = m.s, m.gamma
    G = m.Gam(I, N)
    a = I - N + 1.0
    LamI = g(I) ** (s - 1.0) / G + 1.0 / a
    LamN = g(N) ** (s - 1.0) / G + 1.0 / a
    piI = ((eq.W / g(I)) ** (1 - s) - eq.R ** (1 - s)) / (1 - s)
    piN = (eq.R ** (1 - s) - (eq.W / g(N)) ** (1 - s)) / (1 - s)
    sL = labor_share(eq)
    eps = m.Ls.elasticity(eq.omega)
    return dict(piI=piI, piN=piN,
                dW_I=piI - (1 - sL) * LamI / (s + eps),
                dR_I=piI + sL * LamI / (s + eps),
                dW_N=piN + (1 - sL) * LamN / (s + eps),
                dR_N=piN - sL * LamN / (s + eps))


def K_boundaries_G(m: ModelG, N, I):
    """K_I (x_hat = I) and K_under (A3 binds) for fixed (N, I): roots in log K."""
    f = lambda lk, target: lk + np.log(m.omega_of(I, N, np.exp(lk))) - target  # increasing in lk

    def root(target):
        lo, hi = -5.0, 5.0
        while f(lo, target) > 0:
            lo *= 2.0
        while f(hi, target) < 0:
            hi *= 2.0
        return brentq(lambda lk: f(lk, target), lo, hi, xtol=1e-14)

    kI, kU = root(m.gamma.log(I)), root(m.gamma.log(N))
    return float(np.exp(kI)), float(np.exp(kU))


def run_model_G(n_draws: int, rng: np.random.Generator, t: Tally, grid: int, crossings: list):
    for _ in range(n_draws):
        N, I, gam, Ls = draw_primitives(rng)
        s = rng.uniform(0.2, 0.9) if rng.random() < 0.5 else rng.uniform(1.1, 4.0)
        m = ModelG(gam, Ls, s)
        K_I, K_under = K_boundaries_G(m, N, I)
        if not K_I < K_under:
            t.check("P7 K_I < K_under", False, 0, f"N={N} I={I} s={s}")
            continue
        lo, hi = np.log(K_I), np.log(K_under)
        Ks = np.exp(lo + (hi - lo) * np.concatenate(([1e-3], np.linspace(0.02, 0.98, grid - 1))))
        signs = []
        for j, K in enumerate(Ks):
            eq = m.solve(N, I, float(K))
            if eq.regime != "R" or m.x_hat(N, float(K)) - I < 50 * H:
                continue
            sol = {h: m.solve(N, I + h, float(K)) for h in (-H, H)}
            dW = (np.log(sol[H].W) - np.log(sol[-H].W)) / (2 * H)
            signs.append(np.sign(dW))
            if j == 0:  # P7a: just above K_I
                t.check("P7a dlnW/dI < 0 near K_I", dW < 0, 0, f"N={N:.3f} I={I:.3f} s={s:.3f} dW={dW:.3g}")
            if j % 5 == 1:  # P1/P2/P3 on a subset of grid points
                p = paper_prop3(m, N, I, eq)
                G = m.Gam(I, N)
                t.check("P1G labor market (9)", close(eq.Y * eq.W ** (-s) * G, eq.L, 1e-8, 1e-12),
                        abs(eq.Y * eq.W ** (-s) * G / eq.L - 1))
                t.check("P1G eq. (12)", close(m.lnY12(I, N, float(K), eq.L), np.log(eq.Y), 1e-8, 1e-10),
                        abs(m.lnY12(I, N, float(K), eq.L) - np.log(eq.Y)))
                t.check("P1G A3", eq.R > eq.W / gam(N))
                dY = fd(lambda x: m.lnY12(x, N, float(K), eq.L), I)
                t.check("P2G dlnY/dI|KL = paper", close(dY, p["piI"]), abs(dY - p["piI"]))
                dYN = fd(lambda x: m.lnY12(I, x, float(K), eq.L), N)
                t.check("P2G dlnY/dN|KL = paper", close(dYN, p["piN"]), abs(dYN - p["piN"]))
                dR = (np.log(sol[H].R) - np.log(sol[-H].R)) / (2 * H)
                solN = {h: m.solve(N + h, I, float(K)) for h in (-H, H)}
                dWN = (np.log(solN[H].W) - np.log(solN[-H].W)) / (2 * H)
                dRN = (np.log(solN[H].R) - np.log(solN[-H].R)) / (2 * H)
                t.check("P3G dlnW/dI = paper", close(dW, p["dW_I"]), abs(dW - p["dW_I"]))
                t.check("P3G dlnR/dI = paper", close(dR, p["dR_I"]), abs(dR - p["dR_I"]))
                t.check("P3G dlnW/dN = paper", close(dWN, p["dW_N"]), abs(dWN - p["dW_N"]))
                t.check("P3G dlnR/dN = paper", close(dRN, p["dR_N"]), abs(dRN - p["dR_N"]))
        sg = [x for x in signs if x != 0]
        n_changes = int(sum(1 for u, v in zip(sg[:-1], sg[1:]) if u != v))
        crossings.append((n_changes, sg[0] if sg else 0, sg[-1] if sg else 0, s))
        # direction: if there is a sign change, it must go from - to +
        if n_changes >= 1:
            t.check("P7b first crossing is - to +", sg[0] < 0, 0, f"s={s:.3f}")


# ---------------------------------------------------------------------------
def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--draws-s", type=int, default=3000)
    ap.add_argument("--draws-g", type=int, default=200)
    ap.add_argument("--grid", type=int, default=25)
    ap.add_argument("--seed", type=int, default=20260923)
    args = ap.parse_args(argv)
    rng = np.random.default_rng(args.seed)

    t0 = time.time()
    tS, tL, tG, crossings = Tally(), Tally(), Tally(), []
    run_model_S(args.draws_s, rng, tS, tL)
    tS_time = time.time() - t0
    run_model_G(args.draws_g, rng, tG, args.grid, crossings)
    total = time.time() - t0

    out = []
    out.append(f"seed={args.seed} draws_S={args.draws_s} draws_G={args.draws_g} grid={args.grid}")
    out.append(f"time: model S {tS_time:.1f}s, total {total:.1f}s")
    for name, t in (("Model S, regime R", tS), ("Model S, regime L", tL), ("Model G (paper, sigma != 1)", tG)):
        out.append(f"\n== {name}: {t.checks} checks, {len(t.failures)} failures")
        for k, v in sorted(t.max_err.items()):
            out.append(f"   max err  {k:40s} {v:.2e}")
        for f in t.failures[:15]:
            out.append(f"   FAIL {f}")
    if crossings:
        ch = np.array([c[0] for c in crossings])
        out.append("\n== P7 sign changes of dlnW/dI on (K_I, K_under), Model G")
        for k in sorted(set(ch.tolist())):
            out.append(f"   {k} change(s): {int((ch == k).sum())} draws")
    report = "\n".join(out)
    print(report)
    nfail = len(tS.failures) + len(tL.failures) + len(tG.failures)
    return report, nfail


# pytest entry points (small sizes)
def test_model_S_small():
    t, tl = Tally(), Tally()
    run_model_S(60, np.random.default_rng(1), t, tl)
    assert not t.failures and not tl.failures, t.failures + tl.failures


def test_model_G_small():
    t, cr = Tally(), []
    run_model_G(4, np.random.default_rng(2), t, 10, cr)
    assert not t.failures, t.failures


if __name__ == "__main__":
    _, nfail = main()
    sys.exit(1 if nfail else 0)
