# Formalization Working Memo: The Race Between Machine and Man: Implications of Technology for Growth, Factor Shares and Employment

This is a working lead log, not audit evidence and not a final validation
report. Record possible issues while reading and proving; independently verify
each retained item against the pinned source and final Lean surface during
closeout.

For every item, record the exact source location, current mathematical reading,
Lean treatment, and review state. Prefer “clarification” unless the printed
formula or statement is actually false.

## Possible Source Clarifications

- Printed p. 13 uses two decorated capital thresholds. Assumption 3 on printed
  p. 8 defines the lower threshold `KUnder`; Proposition 3 says there exists
  `KBar > KUnder` and then gives strict signs below and above `KBar`. The Lean
  reading quantifies over every positive comparison capital on both sides, so
  the second direction is not vacuous under the current equilibrium's
  `K < KUnder` premise.
- Proposition 2 defines `epsilonGamma` typographically as
  `d ln gamma(I) / dI`, while `sigmaFree` governs movement of the endogenous
  threshold `Istar`. Lean evaluates this semi-elasticity at `Istar`.
- Appendix B, p. B-13 calls `sL` the labor share in net output and uses
  `WL + RK = (1-eta)Y`; printed p. 10 defines the same share as
  `WL / (RK + WL)`. Lean uses the ratio definition.
- “May reduce” is read as existence of a positive-capital configuration with a
  strictly negative partial log derivative. “Always increases” is a strict
  positive partial log derivative in every configuration satisfying the Spec.
- Equation (1) permits `sigma = 1` although its printed power expression is
  singular there. `taskAggregate` uses the standard unit-measure
  Cobb--Douglas limit at `sigma = 1`.

## Possible Printed Typos Or Errors

- The extraction loses the underline/overline on the two capital thresholds;
  the pinned PDF was visually checked to restore them.
- **Maintainer-approved correction (Proposition 3(a), printed p. 13,
  `source/w22252.txt:707-708`).** The sentence beginning “In particular, there
  exists” is read under the bullet's standing constrained-regime condition and
  Assumption 3 at every comparison capital: `I < freeThreshold I N k` and
  `k < KUnder`. Even with that scope, its asserted sign pattern is false. Since
  `KBar > KUnder`, its negative branch under Assumption 3 is vacuous; near the
  lower edge of the constrained regime the automation productivity coefficient
  tends to zero while the strictly positive displacement term remains, so the
  wage effect is negative rather than positive. In the paper's `eta = 0`,
  `sigma = 1` special case the exact sign switches from negative to positive at
  `KHat = K_I * exp (1 / ((N - I) * (1 + epsilonL)))`, the reverse of the
  printed direction. `proposition3PrintedCapitalThreshold` preserves the
  printed claim separately. The maintainer-approved corrected conjuncts in
  `proposition3Spec` characterize the positive, negative, and zero wage effects
  pointwise by comparing the automation productivity coefficient with
  `(1 - sL) * LambdaI / (sigmaHat + epsilonL)`; no unique threshold is asserted
  for `sigmaHat ≠ 1`.
- Corrected transcription, printed p. 9 immediately after equation (7): the
  source defines `B = Btilde^((sigma - 1)/(sigmaHat - 1))`. The first compiled
  draft incorrectly used `sigmaHat/(sigmaHat - 1)` in `normalizedB`; both its
  definition and docstring now use the printed numerator `sigma - 1`. The
  audit found no other affected definition: equation (1) still uses
  `sigma/(sigma - 1)`, equation (7) still uses `Btilde^(sigma - 1)`, and
  equation (12) still uses the CES exponent `sigmaHat/(sigmaHat - 1)`.

## Possible Proof-Strategy Deviations

- The paper writes total differentials. Lean uses directional sums of actual
  partial derivatives of declared equilibrium output, wage, and rental
  functions. This is an explicit representation of the same first-order
  objects, not a free scalar linear system.
- Relations (B9)--(B10) are exposed as concrete transparent definitions and
  are not premises of `proposition3Spec`; the proof must derive them from the
  equilibrium equations before solving the two-by-two system.

## Possible Model Conventions Or Extra Assumptions

- The `eta -> 0` branch is represented sequentially: a positive path in
  `(0,1)`, indexed by `ℕ`, tends to zero and the limiting closed-form equations are evaluated at
  `etaEffective = 0`. The `zeta = 1` branch uses `etaEffective = eta`.
- `sigmaHat = 1` is excluded because every printed coefficient divides by
  `1-sigmaHat`; both strict sides remain admitted.
- `gamma` is assumed positive on the task interval and differentiable. The
  source calls it productivity and differentiates it but Assumption 1 itself
  states only strict monotonicity.
- The labor-supply schedule and equilibrium output, wage, and rental objects
  are assumed differentiable. Wage, rental, and output are differentiable
  along every declared equilibrium path, including the comparison capital
  levels quantified in the “may reduce” and `KBar` clauses. The paper performs
  these differentiations without a named regularity assumption.
- Equilibrium paths are required to satisfy equations (6) and (8)--(12) at
  every positive-capital, admissible nearby configuration. This makes the
  objects being differentiated genuine equilibria rather than arbitrary
  functions; it is an explicit path-level version of the paper's equilibrium
  model.
- The source environment states `sigma > 0` and `zeta > 0`; these domains are
  retained explicitly even though C7's maintainer checklist only repeats the
  domains most likely to be lost in transcription.

## Architecture Pre-Pass And Semantic Preflight

- The first expanded Spec exceeded Lean's default review-printer depth because
  every equilibrium equation was a separate arrow premise. The interface now
  groups them into four transparent, concrete predicates:
  `proposition3Conditions`, `proposition3StaticEquilibrium`,
  `proposition3EquilibriumPaths`, and
  `proposition3ComparativeStaticQuantities`. Their bodies contain the actual
  equations, inequalities, limits, and differentiability claims; none is an
  abstract predicate parameter or a conclusion supplied as a premise.
- The non-certifying draft semantic preflight subsequently completed without
  printer elision. Its ignored local bundle is
  `.review_traces/proposition3-preflight.txt`. Manual inspection found the
  selected result surface complete subject to the representation changes and
  added assumptions recorded in this memo. This is not an acceptance or proof
  credential.

## Deferred Formalization Or Library Work

- The common real-power sign lemma, the free-regime ordering, both
  variable-limit FTC derivatives, the lower- and upper-endpoint raw log
  derivatives of equation (12), the differential assembly algebra, and the
  corrected wage-sign trichotomy are proved without `sorry` in
  `ProofInterface.lean`.
- **Open constrained-ordering blocker.** C3 relates the current positive
  equilibrium at `K` to factor prices at `KUnder`, but C7 only states positivity
  of `W`, `R`, `Y`, and `L` at the current capital. The global path equations do
  not require positive wage, rental, employment, or output at comparison
  capitals and provide no continuity or monotonicity in the capital argument.
  Since Mathlib's `Real.rpow` is total on negative bases, equations (8)--(12)
  alone do not let the current proof derive that the comparison equilibrium is
  on the intended positive economic branch. Consequently `K < KUnder` cannot
  yet be converted into `ITilde < N`, which is exactly the missing fact for
  `R > W / gamma N` in P3(a). No extra premise was added because the Spec is
  frozen after the two maintainer-approved threshold changes.
- **Open response-derivative blocker.** The FTC and raw production derivatives
  are complete, but the six paper-facing partial identities still require
  local regime stability, positivity of the local equilibrium branch, and
  differentiation and solution of equations (8)--(11). In particular the free
  regime requires proving local equilibrium invariance with respect to the
  nonbinding technology parameter from the path equations, while the
  constrained wage/rental identities require the Lean derivations of
  (B9)--(B10).
- No Propositions 4--9 or dynamic sections are scheduled.
