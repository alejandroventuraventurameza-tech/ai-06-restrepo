import Mathlib

/-!
# The productivity effect as an integral (Acemoglu–Restrepo, NBER WP 22252, June 2017)

Proposition 3 of the paper (printed p. 13) writes the productivity effect of automation as

  d ln Y |_{K,L} / dI = B^(σ̂-1) / (1-σ̂) · ((W/γ(I*))^(1-σ̂) - R^(1-σ̂)),

and of new tasks as `B^(σ̂-1)/(1-σ̂) · (R^(1-σ̂) - (W/γ(N))^(1-σ̂))`. Both formulas divide by
`1 - σ̂`, so they say nothing at `σ̂ = 1` (and the required Lean run excludes that value).

Own analysis (not the required AppliedModelingLib run): both coefficients are
`B^(σ̂-1) · ∫_lo^hi x^(-σ̂) dx` for a pair of positive cost levels. Written that way:

* `productivity_eq_paper` : the integral equals the paper's formula whenever `σ̂ ≠ 1`;
* `productivity_at_one`   : at `σ̂ = 1` it is `log (hi / lo)` (no limit argument needed);
* `productivity_pos_iff`, `productivity_eq_zero_iff`, `productivity_neg_iff` : its sign is the
  sign of `hi - lo`, **for every real σ̂** — one lemma covers `σ̂ < 1`, `σ̂ = 1` and `σ̂ > 1`.

Economic reading (tutorial §7): with `hi = W/γ(I)` and `lo = R`, automation raises productivity
iff the effective wage in the marginal task exceeds the rental rate (regime R of the paper);
with `lo = W/γ(N)` and `hi = R`, new tasks raise productivity iff `R > W/γ(N)` (Assumption 3).
-/

noncomputable section

open intervalIntegral Real Set MeasureTheory

namespace AR18Sandbox

/-- `B^(σ̂-1) ∫_lo^hi x^(-σ̂) dx`: the productivity coefficient of Proposition 3 in integral form. -/
def productivity (sigmaHat B lo hi : ℝ) : ℝ :=
  B ^ (sigmaHat - 1) * ∫ x in lo..hi, x ^ (-sigmaHat)

lemma zero_not_mem_uIcc {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) : (0 : ℝ) ∉ uIcc lo hi := by
  intro h
  rcases mem_uIcc.mp h with h | h
  · exact absurd h.1 (not_le.mpr hlo)
  · exact absurd h.1 (not_le.mpr hhi)

lemma intervalIntegrable_rpow_neg (sigmaHat : ℝ) {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) :
    IntervalIntegrable (fun x : ℝ => x ^ (-sigmaHat)) volume lo hi := by
  apply ContinuousOn.intervalIntegrable
  intro x hx
  have hx0 : x ≠ 0 := fun h => zero_not_mem_uIcc hlo hhi (h ▸ hx)
  exact (continuousAt_id.rpow_const (Or.inl hx0)).continuousWithinAt

/-- The integral is strictly positive when the bounds are positive and ordered. -/
lemma integral_rpow_neg_pos (sigmaHat : ℝ) {lo hi : ℝ} (hlo : 0 < lo) (hlt : lo < hi) :
    0 < ∫ x in lo..hi, x ^ (-sigmaHat) :=
  intervalIntegral_pos_of_pos_on (intervalIntegrable_rpow_neg sigmaHat hlo (hlo.trans hlt))
    (fun _ hx => Real.rpow_pos_of_pos (hlo.trans hx.1) _) hlt

/-- Sign trichotomy of the productivity coefficient, for every real `σ̂`. -/
theorem productivity_sign (sigmaHat : ℝ) {B lo hi : ℝ} (hB : 0 < B) (hlo : 0 < lo) (hhi : 0 < hi) :
    (lo < hi → 0 < productivity sigmaHat B lo hi) ∧
    (lo = hi → productivity sigmaHat B lo hi = 0) ∧
    (hi < lo → productivity sigmaHat B lo hi < 0) := by
  have hBpow : 0 < B ^ (sigmaHat - 1) := Real.rpow_pos_of_pos hB _
  refine ⟨fun h => ?_, fun h => ?_, fun h => ?_⟩
  · exact mul_pos hBpow (integral_rpow_neg_pos sigmaHat hlo h)
  · simp [productivity, h]
  · have hpos := integral_rpow_neg_pos sigmaHat hhi h
    unfold productivity
    rw [integral_symm]
    exact mul_neg_of_pos_of_neg hBpow (neg_neg_of_pos hpos)

theorem productivity_pos_iff (sigmaHat : ℝ) {B lo hi : ℝ} (hB : 0 < B) (hlo : 0 < lo) (hhi : 0 < hi) :
    0 < productivity sigmaHat B lo hi ↔ lo < hi := by
  obtain ⟨h1, h2, h3⟩ := productivity_sign sigmaHat hB hlo hhi
  refine ⟨fun hp => ?_, h1⟩
  rcases lt_trichotomy lo hi with h | h | h
  · exact h
  · exact absurd (h2 h) hp.ne'
  · exact absurd (h3 h) (not_lt.mpr hp.le)

theorem productivity_eq_zero_iff (sigmaHat : ℝ) {B lo hi : ℝ} (hB : 0 < B) (hlo : 0 < lo)
    (hhi : 0 < hi) : productivity sigmaHat B lo hi = 0 ↔ lo = hi := by
  obtain ⟨h1, h2, h3⟩ := productivity_sign sigmaHat hB hlo hhi
  refine ⟨fun hp => ?_, h2⟩
  rcases lt_trichotomy lo hi with h | h | h
  · exact absurd hp (h1 h).ne'
  · exact h
  · exact absurd hp (h3 h).ne

theorem productivity_neg_iff (sigmaHat : ℝ) {B lo hi : ℝ} (hB : 0 < B) (hlo : 0 < lo) (hhi : 0 < hi) :
    productivity sigmaHat B lo hi < 0 ↔ hi < lo := by
  obtain ⟨h1, h2, h3⟩ := productivity_sign sigmaHat hB hlo hhi
  refine ⟨fun hp => ?_, h3⟩
  rcases lt_trichotomy lo hi with h | h | h
  · exact absurd (h1 h) (not_lt.mpr hp.le)
  · exact absurd (h2 h) hp.ne
  · exact h

/-- For `σ̂ ≠ 1` the integral form is exactly the coefficient printed in Proposition 3. -/
theorem productivity_eq_paper {sigmaHat : ℝ} (hs : sigmaHat ≠ 1) (B : ℝ) {lo hi : ℝ}
    (hlo : 0 < lo) (hhi : 0 < hi) :
    productivity sigmaHat B lo hi =
      B ^ (sigmaHat - 1) / (1 - sigmaHat) * (hi ^ (1 - sigmaHat) - lo ^ (1 - sigmaHat)) := by
  have hr : -sigmaHat ≠ -1 := fun h => hs (by linarith)
  unfold productivity
  rw [integral_rpow (Or.inr ⟨hr, zero_not_mem_uIcc hlo hhi⟩)]
  have h1 : -sigmaHat + 1 = 1 - sigmaHat := by ring
  rw [h1]
  have h2 : (1 - sigmaHat) ≠ 0 := sub_ne_zero.mpr (Ne.symm hs)
  field_simp

/-- At `σ̂ = 1` (Cobb–Douglas across tasks) the coefficient is `log (hi / lo)`. -/
theorem productivity_at_one (B : ℝ) {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) :
    productivity 1 B lo hi = Real.log (hi / lo) := by
  unfold productivity
  have hfun : (fun x : ℝ => x ^ (-(1 : ℝ))) = fun x => x⁻¹ := by
    funext x; exact Real.rpow_neg_one x
  simp only [sub_self, Real.rpow_zero, one_mul, hfun]
  exact integral_inv (zero_not_mem_uIcc hlo hhi)

/-- **Proposition 3, productivity clauses, regime (R), any σ̂ (including σ̂ = 1).**
If the effective wage in the marginal automated task exceeds the rental rate
(`W/γ(I) > R`, which is what `I* = I < Ĩ` means) the productivity effect of automation is
strictly positive; under Assumption 3 (`R > W/γ(N)`) so is that of new tasks. -/
theorem both_technologies_raise_productivity (sigmaHat : ℝ) {B W R gammaI gammaN : ℝ}
    (hB : 0 < B) (hW : 0 < W) (hR : 0 < R) (hgI : 0 < gammaI) (hgN : 0 < gammaN)
    (hRegimeR : R < W / gammaI) (hAssumption3 : W / gammaN < R) :
    0 < productivity sigmaHat B R (W / gammaI) ∧ 0 < productivity sigmaHat B (W / gammaN) R :=
  ⟨(productivity_pos_iff sigmaHat hB hR (div_pos hW hgI)).mpr hRegimeR,
   (productivity_pos_iff sigmaHat hB (div_pos hW hgN) hR).mpr hAssumption3⟩

/-- **Regime (L)**: when `W/γ(I*) = R` the productivity gain from moving the threshold is zero. -/
theorem free_regime_no_productivity_gain (sigmaHat : ℝ) {B W R gammaI : ℝ} (hB : 0 < B)
    (hR : 0 < R) (hFree : W / gammaI = R) : productivity sigmaHat B R (W / gammaI) = 0 :=
  (productivity_eq_zero_iff sigmaHat hB hR (hFree ▸ hR)).mpr hFree.symm

end AR18Sandbox
