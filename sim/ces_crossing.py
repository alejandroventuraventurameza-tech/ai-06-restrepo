"""Independent numerical checks of the conditional CES wage crossing.

The predicted capital threshold is derived from the normalized response and
the isoelastic market-clearing ratio, not from a finite-difference fit.
The observed derivatives recompute equilibria at I +/- h using model.py.
"""
from __future__ import annotations

import argparse
import math

import numpy as np

from model import Gamma, LaborSupply, ModelG, ModelS, labor_share


def H(s: float, x: float) -> float:
    z = math.log(x)
    if s == 1.0:
        return z
    return math.expm1((1.0 - s) * z) / (1.0 - s)


def threshold(m, N, I, s, e, l0):
    """Return boundary capitals, displacement threshold, possible interior root."""
    a, b = I - N + 1.0, N - I
    G = b if s == 1.0 else m.Gam(I, N)
    gi, gn = m.gamma(I), m.gamma(N)
    lam = gi ** (s - 1.0) / G + 1.0 / a
    c = a * lam / (s + e)
    def capital(q):
        return math.exp((math.log(a * l0 / G) + (s + e) * math.log(q)) / (1 + e))
    KI, KU = capital(gi), capital(gn)
    Kc = None
    if c < H(s, gn / gi):
        log_ratio = c if s == 1.0 else math.log1p((1.0 - s) * c) / (1.0 - s)
        Kc = capital(gi * math.exp(log_ratio))
    return KI, KU, c, Kc


def run(draws=500, seed=20261126):
    rng = np.random.default_rng(seed)
    checks = 0
    with_root = no_root = 0
    max_error = 0.0
    max_price_error = 0.0
    h = 1e-5
    for _ in range(draws):
        N = float(rng.uniform(-0.5, 1.5))
        a = float(rng.uniform(0.15, 0.85))
        I = N - 1 + a
        s = float(rng.choice([0.35, 0.7, 1.0, 1.3, 2.0, 3.0]))
        e = float(rng.uniform(0.2, 2.5))
        l0 = float(rng.uniform(0.5, 2.0))
        gamma = Gamma(A=float(rng.uniform(0.7, 7.5)), c=float(rng.uniform(0, 0.7)),
                      m=(N+I)/2, d=float(rng.uniform(-0.5, 0.5)))
        ls = LaborSupply(kind=0, l0=l0, e=e)
        m = ModelS(gamma, ls) if s == 1.0 else ModelG(gamma, ls, s)
        KI, KU, c, Kc = threshold(m, N, I, s, e, l0)
        assert 0 < KI < KU
        checks += 1
        if Kc is not None:
            assert KI < Kc < KU
            checks += 1
            with_root += 1
        else:
            no_root += 1
        ks = [float(np.exp(np.log(KI) + f*(np.log(KU)-np.log(KI)))) for f in (0.05, 0.25, 0.5, 0.75, 0.95)]
        if Kc is not None:
            ks += [math.sqrt(KI*Kc), Kc, math.sqrt(Kc*KU)]
        G = (N-I) if s == 1.0 else m.Gam(I, N)
        for K in ks:
            eq = m.solve(N, I, K)
            # Very near an adoption or excluded upper boundary, a central
            # difference would mix regimes; do not silently use it.
            left = m.solve(N, I-h, K)
            right = m.solve(N, I+h, K)
            assert eq.regime == "R"
            q = eq.W/eq.R
            q_expected = math.exp((math.log(G/(a*l0))+(1+e)*math.log(K))/(s+e))
            price_error = abs(math.log(q/q_expected))
            max_price_error = max(max_price_error, price_error)
            assert price_error < 1e-9, (s, K, q, q_expected)
            checks += 1
            share = 1-labor_share(eq)
            score = H(s, q/gamma(I))-c
            pred = share/a * score
            if left.regime != "R" or right.regime != "R" or not (
                left.R > left.W/gamma(N) and right.R > right.W/gamma(N)):
                continue
            actual = (math.log(right.W)-math.log(left.W))/(2*h)
            error = abs(pred-actual)
            max_error = max(max_error, error)
            assert error < 3e-6 + 3e-5*abs(pred), (s,K,pred,actual)
            checks += 1
            if Kc is None:
                assert pred < 0
            elif abs(math.log(K/Kc)) < 1e-10:
                assert abs(pred) < 1e-8
                assert abs(actual) < 3e-6
            else:
                assert np.sign(pred) == np.sign(K-Kc)
                if abs(pred) > 5e-6:
                    assert np.sign(actual) == np.sign(K-Kc)
            checks += 1
    assert with_root > 0 and no_root > 0
    print(f"seed={seed} economies={draws} checks={checks}")
    print(f"interior roots={with_root}; no interior root={no_root}")
    print(f"max log relative-price residual={max_price_error:.3e}")
    print(f"max wage derivative absolute error={max_error:.3e}")
    print("ALL CONDITIONAL CES CHECKS PASSED")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--draws", type=int, default=500)
    p.add_argument("--seed", type=int, default=20261126)
    args = p.parse_args()
    run(args.draws, args.seed)
