# Repository 6 — Acemoglu & Restrepo, *The Race Between Machine and Man*

Acemoglu, D. & Restrepo, P., NBER WP 22252, **revised June 2017 (87 pp.) — the version read here and pinned for Lean**
(SHA-256 in [`paper/README.md`](paper/README.md)). Published as *The Race between Man and Machine*, AER 108(6), 2018.
Page, equation and result numbers below refer to the NBER version.

## What question the paper answers
Can an economy in which capital keeps taking over tasks that labor used to perform grow along a balanced path
**without making labor redundant**, that is, with a stable labor share and stable employment? Which market forces
make automation self-limiting, and when do those forces fail?

## The agent's problem, and why the unit of analysis is the aggregate economy
There is no single interesting optimizer. A unit measure of tasks $i\in[N-1,N]$ is aggregated with a CES
(elasticity $\sigma$). Tasks $i\le I$ **can** be done by capital. In each task a competitive firm minimizes
$p(i)=\min\{R,\ W/\gamma(i)\}$, with comparative advantage $\gamma$ strictly increasing (Assumption 1). A household supplies
labor $L=L^s(W/RK)$. The object of the paper is the **equilibrium allocation of tasks to factors**, $I^*=\min\{I,\tilde I\}$
with $W/R=\gamma(\tilde I)$. Two technologies move that allocation: automation ($I$) and new tasks ($N$).

## Main result, with all its conditions (the trap of issue §5)
*Does automation necessarily reduce wages and the labor share?* **No, and the answer depends on the variable, the regime and the horizon.**
Static model, Proposition 3 (Assumptions 1–3, $\varepsilon_L>0$, $\hat\sigma\neq1$ in the printed formulas):

$$\frac{d\ln W}{dI}=\underbrace{B^{\hat\sigma-1}\!\int_{R}^{W/\gamma(I)}\!x^{-\hat\sigma}dx}_{\text{productivity }(+)}\;-\;\underbrace{(1-s_L)\,\frac{\Lambda_I}{\hat\sigma+\varepsilon_L}}_{\text{displacement }(-)},\qquad \Lambda_I=\frac{\gamma(I)^{\hat\sigma-1}}{\int_I^N\gamma^{\hat\sigma-1}}+\frac{1}{I-N+1}>0 .$$

| | constrained regime $I^*=I<\tilde I$ | free regime $I^*=\tilde I<I$ | long run (Prop. 5, $K$ adjusts) |
|---|---|---|---|
| wage $W$ | **rises iff productivity > displacement** | unchanged | rises |
| labor share, employment | fall (always, because $\Lambda_I>0$) | unchanged | fall |
| output $Y$, rental $R$ | rise | unchanged | $R$ returns to $\rho+\delta+\theta g$ |

Automation raises the wage when the **cost saving in the marginal task**, the gap between $W/\gamma(I)$ and $R$, is large. It lowers the
wage when that gain is small ("so-so" technologies). Reinstatement enters through **new tasks** ($dN$), which raise $W$, the labor share
and employment. The word "reinstatement" does not appear in this 2017 version; the paper's two forces for $dI$ are
*productivity* and *displacement* (see `prompts.md` N1).

**What we found (own derivation, simulation and Lean):** the capital threshold printed in Prop. 3 has the **wrong direction**. The paper
says "there exists $\overline K>\underline K$ such that an increase in $I$ increases the wage when $K<\overline K$ and reduces it when
$K>\overline K$". But with Assumption 3 ($K<\underline K$) the second half is vacuous, and near the lower edge $K_I$ of the constrained
regime the productivity gain vanishes. So automation **lowers** the wage when capital is **scarce** and raises it when capital is abundant.
In the paper's own Cobb–Douglas case ($\sigma=1$, $\eta\to0$) with elastic labor, the exact condition is
$$\frac{d\ln W}{dI}>0\iff K>\hat K=K_I\,\exp\!\Big(\tfrac{1}{(N-I)(1+\varepsilon_L)}\Big)$$
([`derivation/`](derivation/derivation.tex), Thm 4.2). The same statement is machine-checked in Lean
([`extra/lean-sandbox/`](extra/lean-sandbox/), `printed_threshold_claim_false`, `corrected_threshold`), and confirmed numerically for
$\hat\sigma\neq1$ over 400 random economies: at most one sign change, always from − to + ([`sim/`](sim/)).

## What is in this repository
| Path | Content |
|---|---|
| [`REQUIREMENTS.md`](REQUIREMENTS.md) | Checklist built from the literal text of issue #5 |
| [`prompts.md`](prompts.md) | Raw prompts and answers (Claude, the Lean agent, the cold question); deviations D1–D2; AI mistakes E1–E2 |
| [`hand/`](hand/) | Handwritten derivation (see below) |
| [`presentation.tex`](presentation.tex) / `.pdf` | 20-minute Beamer deck |
| [`lean/`](lean/) | AppliedModelingLib run (`gpt-5.6-sol`, effort `high`, 4 sessions), copied exactly as generated. Target: Proposition 3. **Partial**: `lake build` and `paper_contribution.py check AR18RaceManMachine --fast` succeed. Proved: the free-regime ordering, positive productivity coefficients, the corrected wage condition, the printed negative branch is vacuous, the formula assembly, and the FTC and eq. (12) log-derivatives. The endpoint keeps one `sorry`. **Exact blocker:** (i) the constrained-regime price ordering does not follow from the Spec's equilibrium-path premises (no positivity or regularity at other capital levels); (ii) linking the eq. (12) derivatives to the equilibrium price paths. The Codex daily quota ran out four times. Details: `prompts.md` §B.3–B.11, checks in `extra/lean-run/` |
| [`derivation/`](derivation/derivation.tex) | Own hand-derivable special case: definitions, lemmas, theorems, and where it does **not** reproduce the paper |
| [`sim/`](sim/) | SymPy verification (17/17) and randomized property test (167,639 checks, 0 failures) |
| [`extra/lean-sandbox/`](extra/lean-sandbox/) | Own Lean proofs (443 lines, no `sorry`): productivity sign lemma for every $\hat\sigma$, wage threshold, refutation of the printed claim |
| [`extra/tutorial/`](extra/tutorial/tutorial.tex) | Reading tutorial (Spanish): five reading questions, task framework, static model |
| [`extensions.md`](extensions.md) | Extension that could grow into the term project |

## Handwritten derivation
`hand/` — *(to be added)*: Theorem 3.3 of the derivation, $d\ln W/dI$ in the Cobb–Douglas case, and solving for $\hat K$. This is the
step where we did not believe the printed statement: the threshold goes the other way.
