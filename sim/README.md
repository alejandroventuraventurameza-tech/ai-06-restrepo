# sim/ — computational verification of `derivation/derivation.tex`

Everything here checks the **own derivation** (block 4) and the paper's **Proposition 3**
with numbers. The derivation itself contains no numerical examples by design.

| File | What it does |
|---|---|
| `model.py` | Equilibrium solvers built only from equilibrium conditions (root finding + quadrature). `ModelS` = the hand-derivable special case (η = 0, σ = 1, elastic labor). `ModelG` = the paper's static model with η → 0 and σ̂ ≠ 1. |
| `verify_symbolic.py` | SymPy, no numbers: re-derives Lemmas 3.1–3.2, Theorem 3.3, the threshold $\hat K$ of Theorem 4.2, and checks that the paper's Prop. 3 at σ̂ = 1 gives the same terms (Obs. 3.4). |
| `test_properties.py` | Randomized property test (P1–P7, PL of derivation §7) over thousands of draws of primitives $(N, I, K, \gamma, L^s, \hat\sigma)$. All "true" derivatives are central finite differences of equilibria recomputed from scratch. |
| `results/` | Raw output of the last run of each script. |

## How to run (from this folder)

```bash
pip install -r requirements.txt          # numpy, scipy, sympy
python3 verify_symbolic.py               # ~5 s
python3 test_properties.py --draws-s 5000 --draws-g 400 --grid 25    # ~35 s
python3 -m pytest -q test_properties.py  # small version, as unit tests (optional)
```

## Random primitives

* $N\sim U(-1,2)$, $I-N+1\sim U(0.05,0.95)$.
* $\ln\gamma(i)=Ai+c\tanh(i-m)+d$ with $A\sim U(0.3,6)$, $c\in\{0\}\cup U(0,1)$: strictly increasing and continuous (A1, C).
* $L^s(\omega)\in\{\ell_0\omega^e,\ \ell_0(1+\omega)^e,\ \ell_0\omega^e/(1+\omega^e)^h\}$, with $e\sim U(0.1,3)$: the elasticity is positive and, for two of the three families, non-constant (LS).
* Model S regime (R): $K$ log-uniform on $(K_I,\underline K)$. Regime (L): $K=K_I e^{-U(0.01,3)}$.
* Model G: $\hat\sigma\sim U(0.2,0.9)$ or $U(1.1,4)$, and a 25-point log grid of $K$ on $(K_I,\underline K)$ per draw.

## Result of the last run (seed 20260923): `results/test_properties.txt`

* **Model S, regime (R): 99,700 checks, 0 failures.** This includes P5: $\operatorname{sign}(d\ln W/dI)=\operatorname{sign}(K-\hat K)$ on every draw.
* **Model S, regime (L): 49,850 checks, 0 failures.** Automation has no effect.
* **Model G (paper, σ̂ ≠ 1): 18,089 checks, 0 failures.** The paper's Prop. 3 formulas match finite differences to about 1e-8. $d\ln W/dI<0$ just above $K_I$ on all 400 draws (P7a).
* **P7, number of sign changes of $d\ln W/dI$ on $(K_I,\underline K)$ in Model G:** 0 changes in 171 draws (automation always lowers the wage in the admissible region) and exactly 1 change in 229 draws, **always from − to +**. No draw had more than one change. This is evidence, not a proof, and a 25-point grid could miss a pair of crossings close together.

## Does the test bite? (mutation check)

Replacing the displacement term $1/(b(1+\varepsilon_L))$ by $1/b$, which drops the adjustment of employment,
makes 349 of 5,960 checks fail (P3 and P5) on 300 draws. So the test detects an error of that size.
