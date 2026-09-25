import AR18RaceManMachine.MainTheorems

/-!
# Paper interface: Acemoglu--Restrepo Proposition 3

This file formalizes the static environment and Proposition 3 from Daron
Acemoglu and Pascual Restrepo, *The Race Between Machine and Man* (NBER Working
Paper 22252, June 2017 revision). The only selected result is Proposition 3.

The source writes differentials. Here they are directional linearizations made
from actual one-variable derivatives of the declared equilibrium functions.
The definitions `logDifferential2`, `partialLogFirst`, and `partialLogSecond`
make that interpretation explicit.
-/

noncomputable section

open Filter Set
open scoped Topology

namespace AR18RaceManMachine

/-- The two-input CES expression used in task technologies (2)--(3).
At elasticity one, the usual Cobb--Douglas limit is used. -/
def taskCES (elasticity share first second : ℝ) : ℝ :=
  if elasticity = 1 then
    Real.rpow first share * Real.rpow second (1 - share)
  else
    Real.rpow
      (Real.rpow share (1 / elasticity) *
          Real.rpow first ((elasticity - 1) / elasticity) +
        Real.rpow (1 - share) (1 / elasticity) *
          Real.rpow second ((elasticity - 1) / elasticity))
      (elasticity / (elasticity - 1))

/-- Equation (1), including the standard unit-measure Cobb--Douglas limit at
`sigma = 1`. -/
def taskAggregate (sigma Btilde N : ℝ) (taskOutput : ℝ → ℝ) : ℝ :=
  if sigma = 1 then
    Btilde * Real.exp (∫ i in N - 1..N, Real.log (taskOutput i))
  else
    Btilde * Real.rpow
      (∫ i in N - 1..N, Real.rpow (taskOutput i) ((sigma - 1) / sigma))
      (sigma / (sigma - 1))

/-- The effective elasticity `σ̂ = σ(1-η) + ζη`. -/
def effectiveSigma (sigma zeta etaEffective : ℝ) : ℝ :=
  sigma * (1 - etaEffective) + zeta * etaEffective

/-- The paper's normalization `B = B̃^((σ-1)/(σ̂-1))`. -/
def normalizedB (Btilde sigma sigmaHat : ℝ) : ℝ :=
  Real.rpow Btilde ((sigma - 1) / (sigmaHat - 1))

/-- The CES production function in equation (12). -/
def production12
    (gamma : ℝ → ℝ) (B etaEffective sigmaHat Istar N K L : ℝ) : ℝ :=
  B / (1 - etaEffective) *
    Real.rpow
      (Real.rpow (Istar - N + 1) (1 / sigmaHat) *
          Real.rpow K ((sigmaHat - 1) / sigmaHat) +
        Real.rpow
            (∫ i in Istar..N, Real.rpow (gamma i) (sigmaHat - 1))
            (1 / sigmaHat) *
          Real.rpow L ((sigmaHat - 1) / sigmaHat))
      (sigmaHat / (sigmaHat - 1))

/-- `Λ_I` from Proposition 2. -/
def lambdaI (gamma : ℝ → ℝ) (sigmaHat Istar N : ℝ) : ℝ :=
  Real.rpow (gamma Istar) (sigmaHat - 1) /
      (∫ i in Istar..N, Real.rpow (gamma i) (sigmaHat - 1)) +
    1 / (Istar - N + 1)

/-- `Λ_N` from Proposition 2. -/
def lambdaN (gamma : ℝ → ℝ) (sigmaHat Istar N : ℝ) : ℝ :=
  Real.rpow (gamma N) (sigmaHat - 1) /
      (∫ i in Istar..N, Real.rpow (gamma i) (sigmaHat - 1)) +
    1 / (Istar - N + 1)

/-- The labor share `s_L = WL / (RK + WL)`. -/
def laborShare (W R K L : ℝ) : ℝ := W * L / (R * K + W * L)

/-- Directional first-order change of the logarithm of a two-parameter object. -/
def logDifferential2 (object : ℝ → ℝ → ℝ)
    (first second dFirst dSecond : ℝ) : ℝ :=
  deriv (fun x ↦ Real.log (object x second)) first * dFirst +
    deriv (fun x ↦ Real.log (object first x)) second * dSecond

/-- First partial log derivative of a two-parameter object. -/
def partialLogFirst (object : ℝ → ℝ → ℝ) (first second : ℝ) : ℝ :=
  deriv (fun x ↦ Real.log (object x second)) first

/-- Second partial log derivative of a two-parameter object. -/
def partialLogSecond (object : ℝ → ℝ → ℝ) (first second : ℝ) : ℝ :=
  deriv (fun x ↦ Real.log (object first x)) second

/-- The capital-threshold sentence printed in Proposition 3(a), with the
standing constrained-regime condition and Assumption 3 made explicit at every
comparison capital.  The paper's two strict sign directions are preserved here
as a separately named source statement; the maintainer-approved corrected
target used by `proposition3Spec` is the pointwise coefficient comparison. -/
def proposition3PrintedCapitalThreshold
    (freeThreshold wage : ℝ → ℝ → ℝ → ℝ)
    (I N KUnder : ℝ) : Prop :=
  ∃ KBar, KUnder < KBar ∧
    (∀ k, 0 < k → k < KUnder → I < freeThreshold I N k → k < KBar →
      0 < partialLogFirst (fun i n ↦ wage i n k) I N) ∧
    (∀ k, 0 < k → k < KUnder → I < freeThreshold I N k → KBar < k →
      partialLogFirst (fun i n ↦ wage i n k) I N < 0)

/-- Automation coefficient in Proposition 3(a). -/
def automationProductivityCoefficient
    (gamma : ℝ → ℝ) (B sigmaHat Istar W R : ℝ) : ℝ :=
  Real.rpow B (sigmaHat - 1) / (1 - sigmaHat) *
    (Real.rpow (W / gamma Istar) (1 - sigmaHat) -
      Real.rpow R (1 - sigmaHat))

/-- New-task coefficient in both cases of Proposition 3. -/
def newTaskProductivityCoefficient
    (gamma : ℝ → ℝ) (B sigmaHat N W R : ℝ) : ℝ :=
  Real.rpow B (sigmaHat - 1) / (1 - sigmaHat) *
    (Real.rpow R (1 - sigmaHat) -
      Real.rpow (W / gamma N) (1 - sigmaHat))

/-- Relation (B9) from the Appendix B proof of Proposition 3. -/
def b9Relation (sL dLogW dLogR dLogY : ℝ) : Prop :=
  sL * dLogW + (1 - sL) * dLogR = dLogY

/-- Relation (B10) in the technology-constrained regime. -/
def b10ConstrainedRelation
    (sigmaHat epsilonL LambdaI LambdaN dI dN dLogW dLogR : ℝ) : Prop :=
  dLogW - dLogR =
    1 / (sigmaHat + epsilonL) * LambdaN * dN -
      1 / (sigmaHat + epsilonL) * LambdaI * dI

/-- Relation (B10) in the technology-free regime. -/
def b10FreeRelation
    (sigmaFree epsilonL LambdaN dN dLogW dLogR : ℝ) : Prop :=
  dLogW - dLogR = 1 / (sigmaFree + epsilonL) * LambdaN * dN

/-- Assumptions, parameter domains, regimes, and regularity used by Proposition 3. -/
def proposition3Conditions
    (gamma laborSupply : ℝ → ℝ) (etaPath : ℕ → ℝ)
    (wage rental : ℝ → ℝ → ℝ → ℝ)
    (sigma zeta eta etaEffective I N K KUnder Istar ITilde W R Y L
      sigmaHat epsilonL : ℝ) : Prop :=
  StrictMono gamma ∧
  ((etaEffective = 0 ∧ etaPath 0 = eta ∧ Tendsto etaPath atTop (nhds 0)) ∨
    (zeta = 1 ∧ etaEffective = eta)) ∧
  (K < KUnder ∧ rental I N KUnder = wage I N KUnder / gamma N) ∧
  0 < sigma ∧ 0 < zeta ∧
  sigmaHat = effectiveSigma sigma zeta etaEffective ∧
  0 < sigmaHat ∧ (sigmaHat < 1 ∨ 1 < sigmaHat) ∧
  StrictMono laborSupply ∧
  L = laborSupply (W / (R * K)) ∧
  epsilonL = W / (R * K) / L * deriv laborSupply (W / (R * K)) ∧
  0 < epsilonL ∧
  ((Istar = I ∧ I < ITilde) ∨ (Istar = ITilde ∧ ITilde < I)) ∧
  ¬ (Istar = I ∧ I = ITilde) ∧
  (N - 1 < I ∧ I ≤ N) ∧
  (0 < eta ∧ eta < 1) ∧
  (∀ n, 0 < etaPath n ∧ etaPath n < 1) ∧
  (0 < K ∧ 0 < KUnder ∧ 0 < L ∧ 0 < W ∧ 0 < R ∧ 0 < Y) ∧
  (∀ i ∈ Set.Icc (N - 1) N, 0 < gamma i) ∧
  Differentiable ℝ gamma ∧
  DifferentiableAt ℝ laborSupply (W / (R * K))

/-- Equations (1)--(3) and (5)--(12), with the paper's normalizations. -/
def proposition3StaticEquilibrium
    (gamma laborSupply taskOutput taskPrice intermediate labor capital : ℝ → ℝ)
    (sigma zeta etaEffective Btilde B Bzeta psi I N K Istar ITilde
      W R Y L sigmaHat : ℝ) : Prop :=
  0 < Btilde ∧ 0 < B ∧ 0 < psi ∧
  Bzeta = (if zeta = 1 then
      Real.rpow psi etaEffective *
        Real.rpow (1 - etaEffective) (etaEffective - 1) *
        Real.rpow etaEffective (-etaEffective)
    else 1) ∧
  B = normalizedB Btilde sigma sigmaHat ∧
  Y = taskAggregate sigma Btilde N taskOutput ∧
  (∀ i ∈ Set.Ioc I N,
    taskOutput i = Bzeta *
      taskCES zeta etaEffective (intermediate i) (gamma i * labor i)) ∧
  (∀ i ∈ Set.Icc (N - 1) I,
    taskOutput i = Bzeta *
      taskCES zeta etaEffective (intermediate i) (capital i + gamma i * labor i)) ∧
  (∀ i ∈ Set.Icc (N - 1) N,
    taskPrice i = if i ≤ I then
      Real.rpow (min R (W / gamma i)) (1 - etaEffective)
    else Real.rpow (W / gamma i) (1 - etaEffective)) ∧
  W / R = gamma ITilde ∧
  Istar = min I ITilde ∧
  (∀ i ∈ Set.Icc (N - 1) N,
    taskOutput i = Real.rpow Btilde (sigma - 1) * Y *
      Real.rpow (taskPrice i) (-sigma)) ∧
  Real.rpow B (sigmaHat - 1) * (1 - etaEffective) * Y *
      (Istar - N + 1) * Real.rpow R (-sigmaHat) = K ∧
  Real.rpow B (sigmaHat - 1) * (1 - etaEffective) * Y *
      (∫ i in Istar..N,
        (1 / gamma i) * Real.rpow (W / gamma i) (-sigmaHat)) = L ∧
  (Istar - N + 1) * Real.rpow R (1 - sigmaHat) +
      (∫ i in Istar..N, Real.rpow (W / gamma i) (1 - sigmaHat)) =
    Real.rpow B (1 - sigmaHat) ∧
  L = laborSupply (W / (R * K)) ∧
  Y = production12 gamma B etaEffective sigmaHat Istar N K L

/-- Concrete equilibrium identities and equations along the paths differentiated in C8. -/
def proposition3EquilibriumPaths
    (gamma laborSupply : ℝ → ℝ)
    (freeThreshold wage rental employment : ℝ → ℝ → ℝ → ℝ)
    (output : ℝ → ℝ → ℝ → ℝ → ℝ)
    (etaEffective B I N K W R Y L sigmaHat ITilde : ℝ) : Prop :=
  W = wage I N K ∧ R = rental I N K ∧ L = employment I N K ∧
  Y = output I N K L ∧ ITilde = freeThreshold I N K ∧
  (∀ i n k, n - 1 < i → i ≤ n → 0 < k →
    wage i n k / rental i n k = gamma (freeThreshold i n k)) ∧
  (∀ i n k, n - 1 < i → i ≤ n → 0 < k →
    Real.rpow B (sigmaHat - 1) * (1 - etaEffective) *
        output i n k (employment i n k) *
        (min i (freeThreshold i n k) - n + 1) *
        Real.rpow (rental i n k) (-sigmaHat) = k) ∧
  (∀ i n k, n - 1 < i → i ≤ n → 0 < k →
    Real.rpow B (sigmaHat - 1) * (1 - etaEffective) *
        output i n k (employment i n k) *
        (∫ j in min i (freeThreshold i n k)..n,
          (1 / gamma j) * Real.rpow (wage i n k / gamma j) (-sigmaHat)) =
      employment i n k) ∧
  (∀ i n k, n - 1 < i → i ≤ n → 0 < k →
    (min i (freeThreshold i n k) - n + 1) *
        Real.rpow (rental i n k) (1 - sigmaHat) +
        (∫ j in min i (freeThreshold i n k)..n,
          Real.rpow (wage i n k / gamma j) (1 - sigmaHat)) =
      Real.rpow B (1 - sigmaHat)) ∧
  (∀ i n k, n - 1 < i → i ≤ n → 0 < k →
    employment i n k = laborSupply (wage i n k / (rental i n k * k))) ∧
  (∀ i n k l, n - 1 < i → i ≤ n → 0 < k → 0 < l →
    output i n k l = production12 gamma B etaEffective sigmaHat
      (min i (freeThreshold i n k)) n k l) ∧
  (∀ n k l, Differentiable ℝ (fun i ↦ output i n k l)) ∧
  (∀ i k l, Differentiable ℝ (fun n ↦ output i n k l)) ∧
  (∀ n k, Differentiable ℝ (fun i ↦ wage i n k)) ∧
  (∀ i k, Differentiable ℝ (fun n ↦ wage i n k)) ∧
  (∀ n k, Differentiable ℝ (fun i ↦ rental i n k)) ∧
  (∀ i k, Differentiable ℝ (fun n ↦ rental i n k))

/-- Proposition 2's named quantities used by Proposition 3. -/
def proposition3ComparativeStaticQuantities
    (gamma : ℝ → ℝ)
    (Istar N W R K L sigmaHat epsilonGamma sigmaFree LambdaI LambdaN sL : ℝ) : Prop :=
  epsilonGamma = deriv (fun i ↦ Real.log (gamma i)) Istar ∧
  0 < epsilonGamma ∧
  sigmaFree = sigmaHat + 1 / epsilonGamma * LambdaI ∧
  sigmaHat < sigmaFree ∧
  LambdaI = lambdaI gamma sigmaHat Istar N ∧
  LambdaN = lambdaN gamma sigmaHat Istar N ∧
  sL = laborShare W R K L

/--
Proposition 3, with all clauses of both printed bullets except for the final
capital-threshold sentence of bullet (a), whose maintainer-approved corrected
target is used here.  `proposition3PrintedCapitalThreshold` preserves that
sentence separately with its standing regime and Assumption 3 scope explicit.

Conditions/configurations and their named hypotheses:

* C1 is the first conjunct of `hConditions`. Its differentiability conjunct is
  an extra regularity premise not stated in Assumption 1.
* C2 is the second conjunct of `hConditions`. Its first disjunct represents `η → 0` by a sequence
  `etaPath` in `(0,1)` tending to zero and evaluates the limiting formulas at
  the closure value `etaEffective = 0`; its second disjunct is `zeta = 1` and
  `etaEffective = eta`.
* C3 is the third conjunct of `hConditions`: `K < KUnder`, where `KUnder` is a capital level at
  which the concrete equilibrium prices satisfy `R = W/γ(N)`.
* C4 is the `sigmaHat` block of `hConditions`. It admits both
  `sigmaHat < 1` and `1 < sigmaHat`; `sigmaHat = 1` is explicitly excluded.
* C5 is the labor-supply block of `hConditions`; its differentiability
  conjunct is named extra regularity.
* C6 is the regime block of `hConditions` for the two strict regimes and its
  boundary conjunct excludes
  omitted boundary `Istar = I = ITilde` (footnote 15).
* C7 is the domain/positivity block of `hConditions`, together with the first
  three positivity conjuncts of `hStaticEquilibrium`.
* C8 is encoded by the differentiability block of `hConditions` and the
  concrete equilibrium identities/equations in `hEquilibriumPaths`, together
  with the `logDifferential2` expressions below. Thus the differentials are
  actual directional derivatives of equilibrium objects, not unconstrained
  scalar data.

The corrected capital-threshold content gives the positive, negative, and zero
automation wage effects exactly by comparison with the displacement term
`(1-sL) * LambdaI / (sigmaHat+epsilonL)`.  It does not assert a unique capital
threshold for `sigmaHat ≠ 1`.

Equations (1)--(3) and (5)--(12) are the literal conjuncts of
`hStaticEquilibrium`. The transparent predicates used by these four grouped
hypotheses contain only concrete equations, inequalities, and regularity
statements; they are not abstract equilibrium or conclusion oracles.
-/
def proposition3Spec : Prop :=
  ∀ (gamma laborSupply taskOutput taskPrice intermediate labor capital : ℝ → ℝ)
    (etaPath : ℕ → ℝ)
    (freeThreshold : ℝ → ℝ → ℝ → ℝ)
    (wage rental employment : ℝ → ℝ → ℝ → ℝ)
    (output : ℝ → ℝ → ℝ → ℝ → ℝ)
    (sigma zeta eta etaEffective Btilde B Bzeta psi I N K KUnder Istar ITilde
      W R Y L sigmaHat epsilonL epsilonGamma sigmaFree LambdaI LambdaN sL dI dN : ℝ)
    (hConditions : proposition3Conditions gamma laborSupply etaPath wage rental
      sigma zeta eta etaEffective I N K KUnder Istar ITilde W R Y L sigmaHat epsilonL)
    (hStaticEquilibrium : proposition3StaticEquilibrium gamma laborSupply taskOutput
      taskPrice intermediate labor capital sigma zeta etaEffective Btilde B Bzeta psi
      I N K Istar ITilde W R Y L sigmaHat)
    (hEquilibriumPaths : proposition3EquilibriumPaths gamma laborSupply freeThreshold
      wage rental employment output etaEffective B I N K W R Y L sigmaHat ITilde)
    (hComparativeStaticQuantities : proposition3ComparativeStaticQuantities gamma
      Istar N W R K L sigmaHat epsilonGamma sigmaFree LambdaI LambdaN sL),
  let dLogY := logDifferential2 (fun i n ↦ output i n K L) I N dI dN
  let dLogW := logDifferential2 (fun i n ↦ wage i n K) I N dI dN
  let dLogR := logDifferential2 (fun i n ↦ rental i n K) I N dI dN
  let automationCoefficient :=
    automationProductivityCoefficient gamma B sigmaHat Istar W R
  let newTaskCoefficient :=
    newTaskProductivityCoefficient gamma B sigmaHat N W R
  ((Istar = I ∧ I < ITilde) →
      W / gamma Istar > R ∧ R > W / gamma N ∧
      dLogY = automationCoefficient * dI + newTaskCoefficient * dN ∧
      0 < automationCoefficient ∧ 0 < newTaskCoefficient ∧
      dLogW = dLogY + (1 - sL) *
        (1 / (sigmaHat + epsilonL) * LambdaN * dN -
          1 / (sigmaHat + epsilonL) * LambdaI * dI) ∧
      dLogR = dLogY - sL *
        (1 / (sigmaHat + epsilonL) * LambdaN * dN -
          1 / (sigmaHat + epsilonL) * LambdaI * dI) ∧
      0 < partialLogSecond (fun i n ↦ wage i n K) I N ∧
      (∃ k, 0 < k ∧
        partialLogSecond (fun i n ↦ rental i n k) I N < 0) ∧
      0 < partialLogFirst (fun i n ↦ rental i n K) I N ∧
      (∃ k, 0 < k ∧
        partialLogFirst (fun i n ↦ wage i n k) I N < 0) ∧
      (0 < partialLogFirst (fun i n ↦ wage i n K) I N ↔
        automationCoefficient > (1 - sL) * LambdaI / (sigmaHat + epsilonL)) ∧
      (partialLogFirst (fun i n ↦ wage i n K) I N < 0 ↔
        automationCoefficient < (1 - sL) * LambdaI / (sigmaHat + epsilonL)) ∧
      (partialLogFirst (fun i n ↦ wage i n K) I N = 0 ↔
        automationCoefficient = (1 - sL) * LambdaI / (sigmaHat + epsilonL))) ∧
    ((Istar = ITilde ∧ ITilde < I) →
      W / gamma Istar = R ∧ R > W / gamma N ∧
      dLogY = newTaskCoefficient * dN ∧
      0 < newTaskCoefficient ∧
      partialLogFirst (fun i n ↦ output i n K L) I N = 0 ∧
      dLogW = dLogY + (1 - sL) *
        (1 / (sigmaFree + epsilonL) * LambdaN * dN) ∧
      dLogR = dLogY - sL *
        (1 / (sigmaFree + epsilonL) * LambdaN * dN) ∧
      0 < partialLogSecond (fun i n ↦ wage i n K) I N ∧
      (∃ k, 0 < k ∧
        partialLogSecond (fun i n ↦ rental i n k) I N < 0) ∧
      partialLogFirst (fun i n ↦ wage i n K) I N = 0 ∧
      partialLogFirst (fun i n ↦ rental i n K) I N = 0)

end AR18RaceManMachine
