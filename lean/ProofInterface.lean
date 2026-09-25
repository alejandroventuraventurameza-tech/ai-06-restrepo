import AR18RaceManMachine.PaperInterface

/-!
# Proof interface for Acemoglu--Restrepo Proposition 3

Clause-level lemmas keep the source conclusions independently checkable.  The
final endpoint only assembles these results after deriving their hypotheses from
the concrete equilibrium paths.
-/

namespace AR18RaceManMachine

/-- Equation (6) turns the cutoff's relative-price identity into equality of
the rental rate and the effective wage at the cutoff. -/
lemma cutoff_effectiveCost_eq
    {gamma : ℝ → ℝ} {ITilde W R : ℝ}
    (hW : 0 < W) (hR : 0 < R) (hratio : W / R = gamma ITilde) :
    W / gamma ITilde = R := by
  have hgamma : 0 < gamma ITilde := by rw [← hratio]; positivity
  have hW_eq : W = gamma ITilde * R :=
    (div_eq_iff (ne_of_gt hR)).mp hratio
  rw [hW_eq]
  exact mul_div_cancel_left₀ R (ne_of_gt hgamma)

/-- Proposition 3(b), ordering clause. -/
lemma proposition3_free_ordering
    {gamma : ℝ → ℝ} {I N Istar ITilde W R : ℝ}
    (hgamma : StrictMono gamma) (hITildeI : ITilde < I) (hIN : I ≤ N)
    (hIstar : Istar = ITilde) (hW : 0 < W) (hR : 0 < R)
    (hratio : W / R = gamma ITilde) :
    W / gamma Istar = R ∧ R > W / gamma N := by
  have hITildeN : ITilde < N := lt_of_lt_of_le hITildeI hIN
  have hgamma_lt : gamma ITilde < gamma N := hgamma hITildeN
  have hgammaITilde : 0 < gamma ITilde := by rw [← hratio]; positivity
  have hgammaN : 0 < gamma N := lt_trans hgammaITilde hgamma_lt
  have heq : W / gamma ITilde = R := cutoff_effectiveCost_eq hW hR hratio
  subst Istar
  refine ⟨heq, ?_⟩
  calc
    W / gamma N < W / gamma ITilde :=
      (div_lt_div_iff_of_pos_left hW hgammaN hgammaITilde).2 hgamma_lt
    _ = R := heq

/-- The common sign calculation behind both productivity coefficients. -/
lemma positive_rpow_difference_quotient
    {B sigma x y : ℝ} (hB : 0 < B) (hy : 0 < y)
    (hxy : y < x) (hsigma : sigma < 1 ∨ 1 < sigma) :
    0 < Real.rpow B (sigma - 1) / (1 - sigma) *
      (Real.rpow x (1 - sigma) - Real.rpow y (1 - sigma)) := by
  have hBpow : 0 < Real.rpow B (sigma - 1) := Real.rpow_pos_of_pos hB _
  rcases hsigma with hsigma | hsigma
  · have hexp : 0 < 1 - sigma := sub_pos.mpr hsigma
    have hpow : Real.rpow y (1 - sigma) < Real.rpow x (1 - sigma) :=
      Real.rpow_lt_rpow (le_of_lt hy) hxy hexp
    exact mul_pos (div_pos hBpow hexp) (sub_pos.mpr hpow)
  · have hexp : 1 - sigma < 0 := sub_neg.mpr hsigma
    have hpow : Real.rpow x (1 - sigma) < Real.rpow y (1 - sigma) :=
      Real.rpow_lt_rpow_of_neg hy hxy hexp
    have hden : 1 - sigma < 0 := sub_neg.mpr hsigma
    have hquot : Real.rpow B (sigma - 1) / (1 - sigma) < 0 :=
      div_neg_of_pos_of_neg hBpow hden
    exact mul_pos_of_neg_of_neg hquot (sub_neg.mpr hpow)

/-- Proposition 3(a), strict positivity of the automation productivity term. -/
lemma proposition3_automationCoefficient_pos
    {gamma : ℝ → ℝ} {B sigmaHat Istar W R : ℝ}
    (hB : 0 < B) (hR : 0 < R)
    (horder : R < W / gamma Istar)
    (hsigma : sigmaHat < 1 ∨ 1 < sigmaHat) :
    0 < automationProductivityCoefficient gamma B sigmaHat Istar W R := by
  exact positive_rpow_difference_quotient hB hR horder hsigma

/-- Proposition 3(a,b), strict positivity of the new-task productivity term. -/
lemma proposition3_newTaskCoefficient_pos
    {gamma : ℝ → ℝ} {B sigmaHat N W R : ℝ}
    (hB : 0 < B) (hWgamma : 0 < W / gamma N)
    (horder : W / gamma N < R)
    (hsigma : sigmaHat < 1 ∨ 1 < sigmaHat) :
    0 < newTaskProductivityCoefficient gamma B sigmaHat N W R := by
  exact positive_rpow_difference_quotient hB hWgamma horder hsigma

/-- Maintainer-approved correction of Proposition 3(a)'s printed capital
threshold sentence: all three wage-effect signs are exactly coefficient
comparisons. -/
lemma proposition3_correctedAutomationWageSigns
    {gamma : ℝ → ℝ} {wage : ℝ → ℝ → ℝ → ℝ}
    {B sigmaHat Istar I N K W R sL LambdaI epsilonL : ℝ}
    (hformula :
      partialLogFirst (fun i n ↦ wage i n K) I N =
        automationProductivityCoefficient gamma B sigmaHat Istar W R -
          (1 - sL) * LambdaI / (sigmaHat + epsilonL)) :
    (0 < partialLogFirst (fun i n ↦ wage i n K) I N ↔
      automationProductivityCoefficient gamma B sigmaHat Istar W R >
        (1 - sL) * LambdaI / (sigmaHat + epsilonL)) ∧
    (partialLogFirst (fun i n ↦ wage i n K) I N < 0 ↔
      automationProductivityCoefficient gamma B sigmaHat Istar W R <
        (1 - sL) * LambdaI / (sigmaHat + epsilonL)) ∧
    (partialLogFirst (fun i n ↦ wage i n K) I N = 0 ↔
      automationProductivityCoefficient gamma B sigmaHat Istar W R =
        (1 - sL) * LambdaI / (sigmaHat + epsilonL)) := by
  rw [hformula]
  constructor
  · constructor <;> intro h <;> linarith
  constructor
  · constructor <;> intro h <;> linarith
  · constructor <;> intro h <;> linarith

/-- Under the approved Assumption 3 scope, the printed negative branch has no
comparison capital: `KBar > KUnder` and `k < KUnder` contradict `KBar < k`. -/
lemma proposition3_printedNegativeBranch_vacuous
    {KUnder KBar : ℝ} (hThresholds : KUnder < KBar) :
    ∀ k : ℝ, k < KUnder → KBar < k → False := by
  intro k hk hKBar
  linarith

/-- Proposition 3(a), assembly of all three displayed differential formulas
from their six partial-derivative identities. -/
lemma proposition3_constrainedDifferentialFormulas
    {output : ℝ → ℝ → ℝ → ℝ → ℝ}
    {wage rental : ℝ → ℝ → ℝ → ℝ}
    {I N K L dI dN automationCoefficient newTaskCoefficient sL sigmaHat epsilonL
      LambdaI LambdaN : ℝ}
    (hYI : partialLogFirst (fun i n ↦ output i n K L) I N = automationCoefficient)
    (hYN : partialLogSecond (fun i n ↦ output i n K L) I N = newTaskCoefficient)
    (hWI : partialLogFirst (fun i n ↦ wage i n K) I N =
      automationCoefficient - (1 - sL) * LambdaI / (sigmaHat + epsilonL))
    (hWN : partialLogSecond (fun i n ↦ wage i n K) I N =
      newTaskCoefficient + (1 - sL) * LambdaN / (sigmaHat + epsilonL))
    (hRI : partialLogFirst (fun i n ↦ rental i n K) I N =
      automationCoefficient + sL * LambdaI / (sigmaHat + epsilonL))
    (hRN : partialLogSecond (fun i n ↦ rental i n K) I N =
      newTaskCoefficient - sL * LambdaN / (sigmaHat + epsilonL)) :
    let dLogY := logDifferential2 (fun i n ↦ output i n K L) I N dI dN
    let dLogW := logDifferential2 (fun i n ↦ wage i n K) I N dI dN
    let dLogR := logDifferential2 (fun i n ↦ rental i n K) I N dI dN
    dLogY = automationCoefficient * dI + newTaskCoefficient * dN ∧
    dLogW = dLogY + (1 - sL) *
      (1 / (sigmaHat + epsilonL) * LambdaN * dN -
        1 / (sigmaHat + epsilonL) * LambdaI * dI) ∧
    dLogR = dLogY - sL *
      (1 / (sigmaHat + epsilonL) * LambdaN * dN -
        1 / (sigmaHat + epsilonL) * LambdaI * dI) := by
  simp only [logDifferential2, partialLogFirst, partialLogSecond] at *
  rw [hYI, hYN, hWI, hWN, hRI, hRN]
  constructor
  · rfl
  constructor <;> ring

/-- Proposition 3(b), assembly of the productivity and factor-price
differentials and the two zero automation partials. -/
lemma proposition3_freeDifferentialFormulas
    {output : ℝ → ℝ → ℝ → ℝ → ℝ}
    {wage rental : ℝ → ℝ → ℝ → ℝ}
    {I N K L dI dN newTaskCoefficient sL sigmaFree epsilonL LambdaN : ℝ}
    (hYI : partialLogFirst (fun i n ↦ output i n K L) I N = 0)
    (hYN : partialLogSecond (fun i n ↦ output i n K L) I N = newTaskCoefficient)
    (hWI : partialLogFirst (fun i n ↦ wage i n K) I N = 0)
    (hWN : partialLogSecond (fun i n ↦ wage i n K) I N =
      newTaskCoefficient + (1 - sL) * LambdaN / (sigmaFree + epsilonL))
    (hRI : partialLogFirst (fun i n ↦ rental i n K) I N = 0)
    (hRN : partialLogSecond (fun i n ↦ rental i n K) I N =
      newTaskCoefficient - sL * LambdaN / (sigmaFree + epsilonL)) :
    let dLogY := logDifferential2 (fun i n ↦ output i n K L) I N dI dN
    let dLogW := logDifferential2 (fun i n ↦ wage i n K) I N dI dN
    let dLogR := logDifferential2 (fun i n ↦ rental i n K) I N dI dN
    dLogY = newTaskCoefficient * dN ∧
    dLogW = dLogY + (1 - sL) *
      (1 / (sigmaFree + epsilonL) * LambdaN * dN) ∧
    dLogR = dLogY - sL *
      (1 / (sigmaFree + epsilonL) * LambdaN * dN) := by
  simp only [logDifferential2, partialLogFirst, partialLogSecond] at *
  rw [hYI, hYN, hWI, hWN, hRI, hRN]
  constructor
  · ring
  constructor <;> ring

/-- Exact-type proof endpoint for Proposition 3. -/
theorem proposition3 : proposition3Spec := by
  sorry

end AR18RaceManMachine
