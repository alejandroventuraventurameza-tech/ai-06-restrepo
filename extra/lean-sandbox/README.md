# extra/lean-sandbox — own Lean formalization (not the required run)

> This folder is **our own analysis**. The formalization required by the issue is the
> AppliedModelingLib run in `lean/` (agent `gpt-5.6-sol`). This one was written in the Claude session
> and checked with `lake build`. It formalizes `derivation/derivation.tex` and the productivity
> clauses of Proposition 3. Source: NBER WP 22252, June 2017.

Toolchain and Mathlib are pinned to the **same versions as the AppliedModelingLib clone** of the run:
`leanprover/lean4:v4.30.0-rc2`, Mathlib `5450b53e5ddc75d46418fabb605edbf36bd0beb6` (see `lakefile.toml`,
`lake-manifest.json`).

## What is proved (443 lines, 0 `sorry`, only the standard axioms)

| File | Theorem | Mathematical content | Source |
|---|---|---|---|
| `ProductivitySign.lean` | `productivity_sign`, `_pos_iff`, `_eq_zero_iff`, `_neg_iff` | $B^{\hat\sigma-1}\int_{lo}^{hi}x^{-\hat\sigma}dx$ has the sign of $hi-lo$, **for every real $\hat\sigma$** | tutorial Lemma 7.2 |
| | `productivity_eq_paper` | for $\hat\sigma\neq1$, the integral **equals** the coefficient printed in Prop. 3 | Prop. 3, p. 13 |
| | `productivity_at_one` | at $\hat\sigma=1$ it is $\log(hi/lo)$ (the case the printed formula and the required run leave out) | — |
| | `both_technologies_raise_productivity` | regime (R) ($W/\gamma(I)>R$) and A3 ⟹ both productivity effects $>0$ | Prop. 3, "both technologies increase productivity" |
| | `free_regime_no_productivity_gain` | regime (L) ($W/\gamma(I^*)=R$) ⟹ zero gain | Prop. 3, second bullet |
| `WageThreshold.lean` | `wageResponse_pos_iff`, `_neg_iff`, `_eq_zero_iff` | $\operatorname{sign}(d\ln W/dI)=\operatorname{sign}(K-\hat K)$, with $\hat K=K_I e^{1/(b(1+\varepsilon))}$ | derivation Thm 4.2 |
| | `KI_lt_Khat`, `KI_lt_KUnder`, `Khat_lt_KUnder_iff` | the wage-lowering region is never empty; the wage-raising one is non-empty iff $\log\gamma(N)-\log\gamma(I)>1/(b(1+\varepsilon))$ | derivation Thm 4.2 |
| | **`printed_threshold_claim_false`** | the final sentence of Prop. 3 **as printed** ("∃ $\overline K>\underline K$ … raises the wage if $K<\overline K$, lowers it if $K>\overline K$") is **false**, even restricted to the admissible region $(K_I,\underline K)$ | derivation Cor. 4.3 |
| | `corrected_threshold` | the corrected statement: a single sign change at $\hat K$, from − to + | derivation Cor. 4.4 |
| `ModelSDerivative.lean` | **`hasDerivAt_lnWS`** | from the equilibrium conditions (output, $W=bY/L$, and the labor-market identity $\omega L^s(\omega)=b/a$), $\frac{d\ln W}{dI}=\log\frac{bK}{aL\gamma(I)}-\frac{1}{b(1+\varepsilon)}$. Lean **derives** $d\log\omega/dI$ from the identity; it is not assumed | derivation Lemmas 2.3–3.2, Thm 3.3 |
| | `automation_raises_wage_iff` | end to end: equilibrium conditions ⟹ $d\ln W/dI>0$ iff $K>\hat K$ | derivation Thm 4.2 |
| | `hypotheses_satisfiable` | the premises of `hasDerivAt_lnWS` are jointly satisfiable (constant-elasticity witness), so the theorem is not vacuous | — |

### What Lean checks exactly, and what only after extra premises

* **Exact:** the sign lemma (every $\hat\sigma$), its equality with the printed formula ($\hat\sigma\ne1$),
  the threshold algebra, and the refutation of the printed sentence *inside the special case*.
* **With declared premises:** `hasDerivAt_lnWS` assumes that $\log\omega(I)$ is **differentiable**
  (`hlw`), which the derivation gets from the implicit function theorem. The **value** of the
  derivative is not assumed; Lean obtains it from the labor-market identity (`hLabor`). The other premises are
  continuity and positivity of $\gamma$ (C) and differentiability of $L^s$ with elasticity $\varepsilon$ (LS).
* **Domain change with respect to the paper:** the special case $\eta=0$, $\sigma=1$ (the paper's own
  Corollary 1 setting, with $\gamma$ strictly increasing). The paper's general $\hat\sigma\neq1$ threshold
  is **not** formalized here; `sim/` covers it numerically (P7).

## Build and audit

Build on the **Linux disk**. Lean is very slow on `/mnt/c`, and the Mathlib cache is shared with your
AppliedModelingLib clone because it is the same revision:

```bash
cp -r /mnt/c/Users/ASUS/projects/ai-06-restrepo/extra/lean-sandbox ~/ar18-sandbox
cd ~/ar18-sandbox
lake exe cache get          # same Mathlib as the AppliedModelingLib clone
lake build                  # expected: Build completed successfully
lake env lean audit/PrintAxioms.lean    # expected: only [propext, Classical.choice, Quot.sound]
```

`audit/build-and-axioms.txt` holds the output of these commands from the machine where the files
were written. Re-run them and keep your own output next to it.
