import AR18RaceManMachine.PaperInterface

/-!
# Proof interface for Acemoglu--Restrepo Proposition 3

Clause-level lemmas keep the source conclusions independently checkable.  The
final endpoint only assembles these results after deriving their hypotheses from
the concrete equilibrium paths.
-/

namespace AR18RaceManMachine

open Filter Set MeasureTheory

/-- The two variable-limit derivative facts used in every productivity and
market-clearing calculation. -/
lemma gammaRpow_interval_derivatives
    {gamma : ℝ → ℝ} {sigmaHat a b : ℝ}
    (hab : a < b) (hgammaDiff : Differentiable ℝ gamma)
    (hgammaPos : ∀ x ∈ Set.Icc a b, 0 < gamma x) :
    HasDerivAt (fun u ↦ ∫ x in u..b, Real.rpow (gamma x) (sigmaHat - 1))
        (-Real.rpow (gamma a) (sigmaHat - 1)) a ∧
      HasDerivAt (fun u ↦ ∫ x in a..u, Real.rpow (gamma x) (sigmaHat - 1))
        (Real.rpow (gamma b) (sigmaHat - 1)) b := by
  have hcontGamma : Continuous gamma := hgammaDiff.continuous
  have hcont : ContinuousOn (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1))
      (Set.Icc a b) := by
    intro x hx
    exact (hcontGamma.continuousAt.rpow_const
      (Or.inl (ne_of_gt (hgammaPos x hx)))).continuousWithinAt
  have hint : IntervalIntegrable
      (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) volume a b :=
    (show ContinuousOn (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) (uIcc a b) by
      rwa [uIcc_of_le hab.le]).intervalIntegrable
  let s : Set ℝ := gamma ⁻¹' Set.Ioi 0
  have hsOpen : IsOpen s := isOpen_Ioi.preimage hcontGamma
  have hcontOpen : ContinuousOn
      (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) s := by
    intro x hx
    exact (hcontGamma.continuousAt.rpow_const
      (Or.inl (ne_of_gt hx))).continuousWithinAt
  have hmeasA : StronglyMeasurableAtFilter
      (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) (nhds a) volume :=
    hcontOpen.stronglyMeasurableAtFilter hsOpen a (hgammaPos a ⟨le_rfl, hab.le⟩)
  have hmeasB : StronglyMeasurableAtFilter
      (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) (nhds b) volume :=
    hcontOpen.stronglyMeasurableAtFilter hsOpen b (hgammaPos b ⟨hab.le, le_rfl⟩)
  have hca : ContinuousAt (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) a :=
    hcontGamma.continuousAt.rpow_const
      (Or.inl (ne_of_gt (hgammaPos a ⟨le_rfl, hab.le⟩)))
  have hcb : ContinuousAt (fun x ↦ Real.rpow (gamma x) (sigmaHat - 1)) b :=
    hcontGamma.continuousAt.rpow_const
      (Or.inl (ne_of_gt (hgammaPos b ⟨hab.le, le_rfl⟩)))
  constructor
  · exact intervalIntegral.integral_hasDerivAt_left hint hmeasA hca
  · exact intervalIntegral.integral_hasDerivAt_right hint hmeasB hcb

/-- Log derivative of equation (12) with respect to its lower task cutoff.
This is the analytic core of the constrained automation productivity partial. -/
lemma production12_logDeriv_lower
    {gamma : ℝ → ℝ} {B etaEffective sigmaHat t N K L : ℝ}
    (hs : sigmaHat ≠ 0)
    (hB : 0 < B) (heta : etaEffective < 1)
    (ha : 0 < t - N + 1) (hK : 0 < K) (hL : 0 < L)
    (hG : 0 < ∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
    (hint : HasDerivAt
      (fun u ↦ ∫ x in u..N, Real.rpow (gamma x) (sigmaHat - 1))
      (-Real.rpow (gamma t) (sigmaHat - 1)) t) :
    deriv (fun u ↦ Real.log (production12 gamma B etaEffective sigmaHat u N K L)) t =
      (sigmaHat / (sigmaHat - 1)) *
        (((1 / sigmaHat) * Real.rpow (t - N + 1) (1 / sigmaHat - 1) *
            Real.rpow K ((sigmaHat - 1) / sigmaHat) -
          (1 / sigmaHat) *
            Real.rpow (∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
              (1 / sigmaHat - 1) *
            Real.rpow (gamma t) (sigmaHat - 1) *
            Real.rpow L ((sigmaHat - 1) / sigmaHat)) /
          (Real.rpow (t - N + 1) (1 / sigmaHat) *
              Real.rpow K ((sigmaHat - 1) / sigmaHat) +
            Real.rpow (∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
                (1 / sigmaHat) *
              Real.rpow L ((sigmaHat - 1) / sigmaHat))) := by
  let G : ℝ := ∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1)
  let core : ℝ :=
    Real.rpow (t - N + 1) (1 / sigmaHat) * Real.rpow K ((sigmaHat - 1) / sigmaHat) +
      Real.rpow G (1 / sigmaHat) * Real.rpow L ((sigmaHat - 1) / sigmaHat)
  let coreD : ℝ :=
    (1 / sigmaHat) * Real.rpow (t - N + 1) (1 / sigmaHat - 1) *
        Real.rpow K ((sigmaHat - 1) / sigmaHat) -
      (1 / sigmaHat) * Real.rpow G (1 / sigmaHat - 1) *
        Real.rpow (gamma t) (sigmaHat - 1) *
        Real.rpow L ((sigmaHat - 1) / sigmaHat)
  have hAderiv : HasDerivAt (fun u : ℝ ↦ u - N + 1) 1 t := by
    convert ((hasDerivAt_id t).sub_const N).add_const 1 using 1
  have hArpow := hAderiv.rpow_const (Or.inl (ne_of_gt ha)) (p := 1 / sigmaHat)
  have hGrpow := hint.rpow_const (Or.inl (ne_of_gt hG)) (p := 1 / sigmaHat)
  have hcore : HasDerivAt
      (fun u ↦
        Real.rpow (u - N + 1) (1 / sigmaHat) * Real.rpow K ((sigmaHat - 1) / sigmaHat) +
        Real.rpow (∫ x in u..N, Real.rpow (gamma x) (sigmaHat - 1))
            (1 / sigmaHat) * Real.rpow L ((sigmaHat - 1) / sigmaHat))
      coreD t := by
    convert
      (hArpow.mul_const (Real.rpow K ((sigmaHat - 1) / sigmaHat))).add
        (hGrpow.mul_const (Real.rpow L ((sigmaHat - 1) / sigmaHat))) using 1; (
      dsimp [G, coreD]; ring)
  have hcorePos : 0 < core := by
    dsimp [core]
    positivity
  have houter := hcore.rpow_const (Or.inl (ne_of_gt hcorePos))
      (p := sigmaHat / (sigmaHat - 1))
  have hC : 0 < B / (1 - etaEffective) := div_pos hB (sub_pos.mpr heta)
  have hprod : HasDerivAt
      (fun u ↦ production12 gamma B etaEffective sigmaHat u N K L)
      ((B / (1 - etaEffective)) *
        (coreD * (sigmaHat / (sigmaHat - 1)) *
          Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) t := by
    simpa only [production12, G, core, coreD] using
      houter.const_mul (B / (1 - etaEffective))
  have hprodPos : 0 < production12 gamma B etaEffective sigmaHat t N K L := by
    rw [production12]
    exact mul_pos hC (Real.rpow_pos_of_pos hcorePos _)
  have hlog := hprod.log (ne_of_gt hprodPos)
  rw [hlog.deriv]
  have hCne : B / (1 - etaEffective) ≠ 0 := ne_of_gt hC
  have hcoreNe : core ≠ 0 := ne_of_gt hcorePos
  have hpowNe : Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) ≠ 0 :=
    ne_of_gt (Real.rpow_pos_of_pos hcorePos _)
  have hpowrel : Real.rpow core (sigmaHat / (sigmaHat - 1)) =
      Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) * core := by
    conv_lhs => rw [show sigmaHat / (sigmaHat - 1) =
      (sigmaHat / (sigmaHat - 1) - 1) + 1 by ring]
    simpa only [Real.rpow_one] using
      Real.rpow_add hcorePos (sigmaHat / (sigmaHat - 1) - 1) 1
  rw [production12]
  change
    (B / (1 - etaEffective) *
      (coreD * (sigmaHat / (sigmaHat - 1)) *
        Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) /
      (B / (1 - etaEffective) * Real.rpow core (sigmaHat / (sigmaHat - 1))) = _
  rw [hpowrel]
  change
    (B / (1 - etaEffective) *
      (coreD * (sigmaHat / (sigmaHat - 1)) *
        Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) /
      (B / (1 - etaEffective) *
        (Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) * core)) =
      (sigmaHat / (sigmaHat - 1)) * (coreD / core)
  apply (div_eq_iff (mul_ne_zero hCne (mul_ne_zero hpowNe hcoreNe))).2
  field_simp [hcoreNe]

/-- Log derivative of equation (12) with respect to the upper task endpoint.
This is the analytic core of the new-task productivity partial. -/
lemma production12_logDeriv_upper
    {gamma : ℝ → ℝ} {B etaEffective sigmaHat t N K L : ℝ}
    (hs : sigmaHat ≠ 0)
    (hB : 0 < B) (heta : etaEffective < 1)
    (ha : 0 < t - N + 1) (hK : 0 < K) (hL : 0 < L)
    (hG : 0 < ∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
    (hint : HasDerivAt
      (fun u ↦ ∫ x in t..u, Real.rpow (gamma x) (sigmaHat - 1))
      (Real.rpow (gamma N) (sigmaHat - 1)) N) :
    deriv (fun u ↦ Real.log (production12 gamma B etaEffective sigmaHat t u K L)) N =
      (sigmaHat / (sigmaHat - 1)) *
        ((-(1 / sigmaHat) * Real.rpow (t - N + 1) (1 / sigmaHat - 1) *
            Real.rpow K ((sigmaHat - 1) / sigmaHat) +
          (1 / sigmaHat) *
            Real.rpow (∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
              (1 / sigmaHat - 1) *
            Real.rpow (gamma N) (sigmaHat - 1) *
            Real.rpow L ((sigmaHat - 1) / sigmaHat)) /
          (Real.rpow (t - N + 1) (1 / sigmaHat) *
              Real.rpow K ((sigmaHat - 1) / sigmaHat) +
            Real.rpow (∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1))
                (1 / sigmaHat) *
              Real.rpow L ((sigmaHat - 1) / sigmaHat))) := by
  let G : ℝ := ∫ x in t..N, Real.rpow (gamma x) (sigmaHat - 1)
  let core : ℝ :=
    Real.rpow (t - N + 1) (1 / sigmaHat) * Real.rpow K ((sigmaHat - 1) / sigmaHat) +
      Real.rpow G (1 / sigmaHat) * Real.rpow L ((sigmaHat - 1) / sigmaHat)
  let coreD : ℝ :=
    -(1 / sigmaHat) * Real.rpow (t - N + 1) (1 / sigmaHat - 1) *
        Real.rpow K ((sigmaHat - 1) / sigmaHat) +
      (1 / sigmaHat) * Real.rpow G (1 / sigmaHat - 1) *
        Real.rpow (gamma N) (sigmaHat - 1) *
        Real.rpow L ((sigmaHat - 1) / sigmaHat)
  have hAderiv : HasDerivAt (fun u : ℝ ↦ t - u + 1) (-1) N := by
    convert ((hasDerivAt_const N t).sub (hasDerivAt_id N)).add_const 1 using 1
    norm_num
  have hArpow := hAderiv.rpow_const (Or.inl (ne_of_gt ha)) (p := 1 / sigmaHat)
  have hGrpow := hint.rpow_const (Or.inl (ne_of_gt hG)) (p := 1 / sigmaHat)
  have hcore : HasDerivAt
      (fun u ↦
        Real.rpow (t - u + 1) (1 / sigmaHat) * Real.rpow K ((sigmaHat - 1) / sigmaHat) +
        Real.rpow (∫ x in t..u, Real.rpow (gamma x) (sigmaHat - 1))
            (1 / sigmaHat) * Real.rpow L ((sigmaHat - 1) / sigmaHat))
      coreD N := by
    convert
      (hArpow.mul_const (Real.rpow K ((sigmaHat - 1) / sigmaHat))).add
        (hGrpow.mul_const (Real.rpow L ((sigmaHat - 1) / sigmaHat))) using 1; (
      dsimp [G, coreD]; ring)
  have hcorePos : 0 < core := by
    dsimp [core]
    positivity
  have houter := hcore.rpow_const (Or.inl (ne_of_gt hcorePos))
      (p := sigmaHat / (sigmaHat - 1))
  have hC : 0 < B / (1 - etaEffective) := div_pos hB (sub_pos.mpr heta)
  have hprod : HasDerivAt
      (fun u ↦ production12 gamma B etaEffective sigmaHat t u K L)
      ((B / (1 - etaEffective)) *
        (coreD * (sigmaHat / (sigmaHat - 1)) *
          Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) N := by
    simpa only [production12, G, core, coreD] using
      houter.const_mul (B / (1 - etaEffective))
  have hprodPos : 0 < production12 gamma B etaEffective sigmaHat t N K L := by
    rw [production12]
    exact mul_pos hC (Real.rpow_pos_of_pos hcorePos _)
  have hlog := hprod.log (ne_of_gt hprodPos)
  rw [hlog.deriv]
  have hCne : B / (1 - etaEffective) ≠ 0 := ne_of_gt hC
  have hcoreNe : core ≠ 0 := ne_of_gt hcorePos
  have hpowNe : Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) ≠ 0 :=
    ne_of_gt (Real.rpow_pos_of_pos hcorePos _)
  have hpowrel : Real.rpow core (sigmaHat / (sigmaHat - 1)) =
      Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) * core := by
    conv_lhs => rw [show sigmaHat / (sigmaHat - 1) =
      (sigmaHat / (sigmaHat - 1) - 1) + 1 by ring]
    simpa only [Real.rpow_one] using
      Real.rpow_add hcorePos (sigmaHat / (sigmaHat - 1) - 1) 1
  rw [production12]
  change
    (B / (1 - etaEffective) *
      (coreD * (sigmaHat / (sigmaHat - 1)) *
        Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) /
      (B / (1 - etaEffective) * Real.rpow core (sigmaHat / (sigmaHat - 1))) = _
  rw [hpowrel]
  change
    (B / (1 - etaEffective) *
      (coreD * (sigmaHat / (sigmaHat - 1)) *
        Real.rpow core (sigmaHat / (sigmaHat - 1) - 1))) /
      (B / (1 - etaEffective) *
        (Real.rpow core (sigmaHat / (sigmaHat - 1) - 1) * core)) =
      (sigmaHat / (sigmaHat - 1)) * (coreD / core)
  apply (div_eq_iff (mul_ne_zero hCne (mul_ne_zero hpowNe hcoreNe))).2
  field_simp [hcoreNe]

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
