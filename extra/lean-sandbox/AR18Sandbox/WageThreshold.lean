import Mathlib

/-!
# When does automation raise the wage? The capital threshold (own analysis)

Source: `derivation/derivation.tex`, Theorem 4.2 and Corollaries 4.3–4.4, for the special case
of Acemoglu–Restrepo (NBER WP 22252, June 2017) with `η = 0` (Assumption 2(i)), Cobb–Douglas
across tasks (`σ = 1`, the paper's own Corollary 1 setting) and an increasing labor supply with
elasticity `ε_L > 0`.

In the technology-constrained regime `I* = I < Ĩ`, with `a = I-N+1`, `b = N-I` (both in `(0,1)`),
employment `L` and the elasticity `ε` do not depend on `K` (derivation, Lemma 2.4), and

  d ln W / dI = log (bK / (aLγ(I))) - 1 / (b(1+ε))
               = productivity effect      - displacement effect.

`ModelSDerivative.lean` proves that this expression *is* the derivative of the equilibrium log
wage; here it is taken as given and we study its sign as a function of capital `K`.

Main results:
* `wageResponse_pos_iff`, `_neg_iff`, `_eq_zero_iff` : sign of `d ln W/dI` = sign of `K - K̂`;
* `KI_lt_Khat` : the wage-lowering region `(K_I, K̂)` is never empty;
* `printed_threshold_claim_false` : the sentence printed in Proposition 3 ("there exists
  `K̄ > K̲` such that an increase in `I` increases the equilibrium wage when `K < K̄` and reduces
  it when `K > K̄`") is **false** in this special case, even restricted to the admissible region;
* `corrected_threshold` : the corrected statement, with the opposite direction.
-/

noncomputable section

open Real

namespace AR18Sandbox

/-- `d ln W / dI` in regime (R) of the special case (derivation, eq. (3.3)). -/
def wageResponse (a b eps L gammaI K : ℝ) : ℝ :=
  Real.log (b * K / (a * L * gammaI)) - 1 / (b * (1 + eps))

/-- Lower edge of regime (R): capital level at which `W/R = γ(I)` (derivation, eq. (4.1)). -/
def KI (a b L gammaI : ℝ) : ℝ := a * L * gammaI / b

/-- Upper edge allowed by Assumption 3: capital level at which `W/R = γ(N)`. -/
def KUnder (a b L gammaN : ℝ) : ℝ := a * L * gammaN / b

/-- The corrected wage threshold `K̂ = K_I · exp(1/(b(1+ε)))`. -/
def Khat (a b eps L gammaI : ℝ) : ℝ := KI a b L gammaI * Real.exp (1 / (b * (1 + eps)))

section
variable {a b eps L gammaI K : ℝ}

lemma KI_pos (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI) : 0 < KI a b L gammaI := by
  unfold KI; positivity

lemma ratio_eq (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI) :
    b * K / (a * L * gammaI) = K / KI a b L gammaI := by
  unfold KI; field_simp

/-- The productivity term is `log (K / K_I)`: zero exactly at the regime boundary. -/
lemma wageResponse_eq (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI) :
    wageResponse a b eps L gammaI K = Real.log (K / KI a b L gammaI) - 1 / (b * (1 + eps)) := by
  unfold wageResponse; rw [ratio_eq ha hb hL hg]

theorem wageResponse_pos_iff (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI)
    (hK : 0 < K) : 0 < wageResponse a b eps L gammaI K ↔ Khat a b eps L gammaI < K := by
  have hKI := KI_pos ha hb hL hg
  rw [wageResponse_eq ha hb hL hg, sub_pos, Real.lt_log_iff_exp_lt (div_pos hK hKI), Khat,
    lt_div_iff₀ hKI, mul_comm]

theorem wageResponse_neg_iff (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI)
    (hK : 0 < K) : wageResponse a b eps L gammaI K < 0 ↔ K < Khat a b eps L gammaI := by
  have hKI := KI_pos ha hb hL hg
  rw [wageResponse_eq ha hb hL hg, sub_neg, Real.log_lt_iff_lt_exp (div_pos hK hKI), Khat,
    div_lt_iff₀ hKI, mul_comm]

theorem wageResponse_eq_zero_iff (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI)
    (hK : 0 < K) : wageResponse a b eps L gammaI K = 0 ↔ K = Khat a b eps L gammaI := by
  constructor
  · intro h
    rcases lt_trichotomy K (Khat a b eps L gammaI) with h' | h' | h'
    · exact absurd h ((wageResponse_neg_iff ha hb hL hg hK).mpr h').ne
    · exact h'
    · exact absurd h ((wageResponse_pos_iff ha hb hL hg hK).mpr h').ne'
  · intro h
    have hKI := KI_pos ha hb hL hg
    rw [wageResponse_eq ha hb hL hg, h, Khat, mul_div_cancel_left₀ _ hKI.ne', Real.log_exp,
      sub_self]

/-- The wage-lowering region `(K_I, K̂)` is never empty (needs `b(1+ε) > 0`). -/
theorem KI_lt_Khat (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI)
    (heps : 0 < 1 + eps) : KI a b L gammaI < Khat a b eps L gammaI := by
  have hKI := KI_pos ha hb hL hg
  have hexp : 1 < Real.exp (1 / (b * (1 + eps))) :=
    Real.one_lt_exp_iff.mpr (by positivity)
  unfold Khat
  nlinarith

/-- `K_I < K̲`: regime (R) is non-empty under Assumption 1 (`γ(I) < γ(N)`). -/
theorem KI_lt_KUnder (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) {gammaN : ℝ}
    (hgI : gammaI < gammaN) : KI a b L gammaI < KUnder a b L gammaN := by
  unfold KI KUnder
  have : a * L * gammaI < a * L * gammaN := by
    have := mul_pos ha hL; nlinarith
  exact div_lt_div_of_pos_right this hb

/-- The wage-raising region `(K̂, K̲)` is non-empty iff comparative advantage is steep enough. -/
theorem Khat_lt_KUnder_iff (ha : 0 < a) (hb : 0 < b) (hL : 0 < L) (hg : 0 < gammaI)
    {gammaN : ℝ} (hgN : 0 < gammaN) :
    Khat a b eps L gammaI < KUnder a b L gammaN ↔
      1 / (b * (1 + eps)) < Real.log gammaN - Real.log gammaI := by
  have hc : 0 < a * L / b := by positivity
  have e1 : Khat a b eps L gammaI = a * L / b * (gammaI * Real.exp (1 / (b * (1 + eps)))) := by
    unfold Khat KI; ring
  have e2 : KUnder a b L gammaN = a * L / b * gammaN := by unfold KUnder; ring
  rw [e1, e2, mul_lt_mul_iff_of_pos_left hc, ← Real.log_div hgN.ne' hg.ne',
    Real.lt_log_iff_exp_lt (div_pos hgN hg), lt_div_iff₀ hg, mul_comm]

end

/-- **Proposition 3 of the paper, final sentence, as printed** (p. 13), restricted to the
admissible capital levels of regime (R), `K ∈ (K_I, K̲)`:
"there exists `K̄ > K̲` such that an increase in `I` increases the equilibrium wage when
`K < K̄` and reduces it when `K > K̄`". -/
def PrintedThresholdClaim (a b eps L gammaI gammaN : ℝ) : Prop :=
  ∃ KBar, KUnder a b L gammaN < KBar ∧
    (∀ K, KI a b L gammaI < K → K < KUnder a b L gammaN → K < KBar →
      0 < wageResponse a b eps L gammaI K) ∧
    (∀ K, KI a b L gammaI < K → K < KUnder a b L gammaN → KBar < K →
      wageResponse a b eps L gammaI K < 0)

/-- **The printed sentence is false** in the special case (which satisfies Assumptions 1, 2(i),
3 and `ε_L > 0`): just above the regime boundary `K_I`, automation lowers the wage, although
`K < K̲ < K̄`. (Its second clause is vacuous on the admissible region because `K̄ > K̲`.) -/
theorem printed_threshold_claim_false {a b eps L gammaI gammaN : ℝ} (ha : 0 < a) (hb : 0 < b)
    (hL : 0 < L) (hg : 0 < gammaI) (heps : 0 < 1 + eps) (hgI : gammaI < gammaN) :
    ¬ PrintedThresholdClaim a b eps L gammaI gammaN := by
  rintro ⟨KBar, hBar, hbelow, -⟩
  set k0 := KI a b L gammaI
  set top := min (Khat a b eps L gammaI) (KUnder a b L gammaN)
  have hk0 : 0 < k0 := KI_pos ha hb hL hg
  have htop : k0 < top :=
    lt_min (KI_lt_Khat ha hb hL hg heps) (KI_lt_KUnder ha hb hL hgI)
  set K := (k0 + top) / 2
  have hK1 : k0 < K := by simp only [K]; linarith
  have hK2 : K < top := by simp only [K]; linarith
  have hKhat : K < Khat a b eps L gammaI := lt_of_lt_of_le hK2 (min_le_left _ _)
  have hKU : K < KUnder a b L gammaN := lt_of_lt_of_le hK2 (min_le_right _ _)
  have hpos := hbelow K hK1 hKU (hKU.trans hBar)
  have hneg := (wageResponse_neg_iff ha hb hL hg (hk0.trans hK1)).mpr hKhat
  exact absurd hpos (not_lt.mpr hneg.le)

/-- **Corrected statement**: there is a threshold `K̂ > K_I` such that automation *lowers* the
wage for `K < K̂` and *raises* it for `K > K̂` (exactly one sign change, at `K̂`). -/
theorem corrected_threshold {a b eps L gammaI : ℝ} (ha : 0 < a) (hb : 0 < b) (hL : 0 < L)
    (hg : 0 < gammaI) (heps : 0 < 1 + eps) :
    ∃ Kh, KI a b L gammaI < Kh ∧ ∀ K, 0 < K →
      (wageResponse a b eps L gammaI K < 0 ↔ K < Kh) ∧
      (wageResponse a b eps L gammaI K = 0 ↔ K = Kh) ∧
      (0 < wageResponse a b eps L gammaI K ↔ Kh < K) :=
  ⟨Khat a b eps L gammaI, KI_lt_Khat ha hb hL hg heps, fun _ hK =>
    ⟨wageResponse_neg_iff ha hb hL hg hK, wageResponse_eq_zero_iff ha hb hL hg hK,
     wageResponse_pos_iff ha hb hL hg hK⟩⟩

end AR18Sandbox
