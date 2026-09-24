"""
Data for the presentation figure: d lnW / dI as a function of capital K on the
regime-(R) interval (K_I, K_under), for three values of sigma_hat.

Fixed primitives (illustrative, not estimates): N = 1, I = 0.5, gamma(i) = exp(5 i),
labor supply L^s(omega) = omega^0.5. sigma_hat = 1 uses ModelS (closed form of the
derivation); sigma_hat in {0.5, 2} use ModelG (paper, eta -> 0). Derivatives are
central finite differences of equilibria recomputed from scratch (as in the tests).

Output: results/wage_response_curves.csv with columns
    sigma, K_over_KI, dlnW_dI
Run: python3 figure_data.py
"""
import csv

import numpy as np

from model import Gamma, LaborSupply, ModelG, ModelS

H = 1e-5
N, I = 1.0, 0.5
gam = Gamma(A=5.0)
Ls = LaborSupply(kind=0, l0=1.0, e=0.5)
rows = []

# sigma_hat = 1: model S
mS = ModelS(gam, Ls)
a, b = I - N + 1, N - I
wI = mS.omega_star(b / a)
KI, KU = gam(I) / wI, gam(N) / wI
for u in np.linspace(0.002, 0.998, 80):
    K = float(np.exp(np.log(KI) + u * (np.log(KU) - np.log(KI))))
    lw = lambda x: np.log(mS.solve(N, x, K).W)
    rows.append((1.0, K / KI, (lw(I + H) - lw(I - H)) / (2 * H)))


def boundaries(m):
    from scipy.optimize import brentq
    f = lambda lk, t: lk + np.log(m.omega_of(I, N, np.exp(lk))) - t
    return (float(np.exp(brentq(lambda lk: f(lk, gam.log(I)), -40, 40))),
            float(np.exp(brentq(lambda lk: f(lk, gam.log(N)), -40, 40))))


for s in (0.5, 2.0):
    mG = ModelG(gam, Ls, s)
    KI, KU = boundaries(mG)
    for u in np.linspace(0.002, 0.998, 80):
        K = float(np.exp(np.log(KI) + u * (np.log(KU) - np.log(KI))))
        lw = lambda x: np.log(mG.solve(N, x, K).W)
        rows.append((s, K / KI, (lw(I + H) - lw(I - H)) / (2 * H)))

with open("results/wage_response_curves.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["sigma", "K_over_KI", "dlnW_dI"])
    w.writerows(rows)

for s in (0.5, 1.0, 2.0):
    r = [x for x in rows if x[0] == s]
    ch = [r[j][1] for j in range(1, len(r)) if np.sign(r[j][2]) != np.sign(r[j - 1][2])]
    print(f"sigma={s}: K/K_I in [{r[0][1]:.3f}, {r[-1][1]:.3f}], dlnW/dI from {r[0][2]:+.3f} to {r[-1][2]:+.3f}, sign change at K/K_I ~ {ch}")
