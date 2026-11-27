import AR18Sandbox.ProductivitySign

/-!
# Conditional single crossing for the CES task model (November 2026)

This is independent of the frozen AppliedModelingLib run. It checks the
reduced wage response, continuity and strict monotonicity of the normalized
gain, the precise interior-root condition, and the ordering implied by the
isoelastic equilibrium equation. It does not prove the full source Proposition 3.
-/

noncomputable section

open intervalIntegral Real Set MeasureTheory

namespace AR18Sandbox

/-- H_s(x) = integral from 1 to x of t^(-s). Economic domain x > 0. -/
def normalizedGain (s x : ℝ) : ℝ :=
  ∫ t in (1 : ℝ)..x, t ^ (-s)

@[simp] lemma normalizedGain_one (s : ℝ) : normalizedGain s 1 = 0 := by
  simp [normalizedGain]

lemma normalizedGain_formula {s x : ℝ} (hs : s ≠ 1) (hx : 0 < x) :
    normalizedGain s x = 1 / (1 - s) * (x ^ (1 - s) - 1) := by
  have h := productivity_eq_paper hs (1 : ℝ) (by norm_num : (0 : ℝ) < 1) hx
  simpa only [productivity, normalizedGain, Real.one_rpow, one_mul] using h

lemma normalizedGain_log {x : ℝ} (hx : 0 < x) :
    normalizedGain 1 x = Real.log x := by
  have h := productivity_at_one (1 : ℝ) (by norm_num : (0 : ℝ) < 1) hx
  simpa only [productivity, normalizedGain, sub_self, Real.rpow_zero, one_mul, div_one] using h

theorem normalizedGain_strictMonoOn (s : ℝ) :
    StrictMonoOn (normalizedGain s) (Ioi (0 : ℝ)) := by
  intro x hx y hy hxy
  have hx' : 0 < x := hx
  have hy' : 0 < y := hy
  have hadd := intervalIntegral.integral_add_adjacent_intervals
    (intervalIntegrable_rpow_neg s (by norm_num : (0 : ℝ) < 1) hx')
    (intervalIntegrable_rpow_neg s hx' hy')
  have hp := integral_rpow_neg_pos s hx' hxy
  unfold normalizedGain
  linarith

theorem normalizedGain_continuousOn (s : ℝ) :
    ContinuousOn (normalizedGain s) (Ioi (0 : ℝ)) := by
  by_cases hs : s = 1
  · subst s
    have h : ContinuousOn Real.log (Ioi (0 : ℝ)) := by
      intro x hx
      exact (Real.continuousAt_log (ne_of_gt (show 0 < x from hx))).continuousWithinAt
    exact h.congr (fun x hx => normalizedGain_log hx)
  · have h : ContinuousOn (fun x : ℝ => 1 / (1 - s) * (x ^ (1 - s) - 1)) (Ioi (0 : ℝ)) := by
      intro x hx
      have hx' : 0 < x := hx
      have hp : ContinuousAt (fun y : ℝ => y ^ (1 - s)) x :=
        continuousAt_id.rpow_const (Or.inl hx'.ne')
      have hc : ContinuousAt (fun y : ℝ => 1 / (1 - s) * (y ^ (1 - s) - 1)) x :=
        continuousAt_const.mul (hp.sub continuousAt_const)
      exact hc.continuousWithinAt
    exact h.congr (fun x hx => normalizedGain_formula hs hx)

/-- The wage-gain root is interior exactly when the upper-bound gain exceeds
the positive displacement threshold. Equality at the excluded upper bound
does not give an interior root. -/
theorem ces_interior_root_iff (s : ℝ) {u c : ℝ} (hu : 1 < u) (hc : 0 < c) :
    (∃! x : ℝ, x ∈ Ioo 1 u ∧ normalizedGain s x = c) ↔ c < normalizedGain s u := by
  have hu0 : 0 < u := by linarith
  have hmono := normalizedGain_strictMonoOn s
  constructor
  · rintro ⟨x, ⟨hx, heq⟩, _⟩
    have hx0 : 0 < x := by linarith [hx.1]
    have hlt := hmono (show x ∈ Ioi (0 : ℝ) from hx0) (show u ∈ Ioi (0 : ℝ) from hu0) hx.2
    rwa [heq] at hlt
  · intro hupper
    have hcont : ContinuousOn (normalizedGain s) (Icc 1 u) :=
      (normalizedGain_continuousOn s).mono (by intro x hx; exact show 0 < x from lt_of_lt_of_le zero_lt_one hx.1)
    have hmem : c ∈ Icc (normalizedGain s 1) (normalizedGain s u) := by
      exact ⟨by simpa only [normalizedGain_one] using hc.le, hupper.le⟩
    obtain ⟨x, hx, heq⟩ := intermediate_value_Icc hu.le hcont hmem
    have hx1 : 1 < x := by
      by_contra! h
      have hEq : x = 1 := le_antisymm h hx.1
      rw [hEq, normalizedGain_one] at heq
      linarith
    have hxu : x < u := by
      by_contra! h
      have hEq : x = u := le_antisymm hx.2 h
      rw [hEq] at heq
      linarith
    refine ⟨x, ⟨⟨hx1, hxu⟩, heq⟩, ?_⟩
    intro y hy
    have hx0 : 0 < x := by linarith
    have hy0 : 0 < y := by linarith [hy.1.1]
    exact hmono.injOn (show y ∈ Ioi (0 : ℝ) from hy0)
      (show x ∈ Ioi (0 : ℝ) from hx0) (hy.2.trans heq.symm)

/-- If the upper-bound condition fails, the wage response is negative throughout
the open admissible interval. -/
theorem ces_no_interior_root_negative (s : ℝ) {x u c : ℝ}
    (hx : 1 < x) (hxu : x < u) (hc : normalizedGain s u ≤ c) :
    normalizedGain s x < c := by
  have hx0 : 0 < x := by linarith
  have hu0 : 0 < u := hx0.trans hxu
  exact lt_of_lt_of_le
    (normalizedGain_strictMonoOn s (show x ∈ Ioi (0 : ℝ) from hx0)
      (show u ∈ Ioi (0 : ℝ) from hu0) hxu) hc

/-- Given the interior root, the strict sign ordering follows by monotonicity,
not by inspecting a finite grid. -/
theorem ces_root_signs (s : ℝ) {x r c : ℝ}
    (hx : 0 < x) (hr : 0 < r) (hroot : normalizedGain s r = c) :
    (normalizedGain s x < c ↔ x < r) ∧
    (normalizedGain s x = c ↔ x = r) ∧
    (c < normalizedGain s x ↔ r < x) := by
  have hm := normalizedGain_strictMonoOn s
  have hx' : x ∈ Ioi (0 : ℝ) := hx
  have hr' : r ∈ Ioi (0 : ℝ) := hr
  rw [← hroot]
  constructor
  · constructor
    · intro h
      by_contra! hxr
      rcases eq_or_lt_of_le hxr with heq | hlt
      · rw [heq] at h
        exact (lt_irrefl _ h)
      · exact (not_lt_of_ge (hm hr' hx' hlt).le) h
    · exact hm hx' hr'
  · constructor
    · constructor
      · intro h
        exact hm.injOn hx' hr' h
      · intro h
        rw [h]
    · constructor
      · intro h
        by_contra! hrx
        rcases eq_or_lt_of_le hrx with heq | hlt
        · rw [heq] at h
          exact (lt_irrefl _ h)
        · exact (not_lt_of_ge (hm hx' hr' hlt).le) h
      · exact hm hr' hx'

/-- Normalization of the actual CES productivity coefficient for s ≠ 1. -/
theorem ces_productivity_scale {s B R x : ℝ} (hs : s ≠ 1)
    (hR : 0 < R) (hx : 0 < x) :
    productivity s B R (R * x) =
      B ^ (s - 1) * R ^ (1 - s) * normalizedGain s x := by
  rw [productivity_eq_paper hs B hR (mul_pos hR hx), normalizedGain_formula hs hx,
    Real.mul_rpow hR.le hx.le]
  ring

/-- The reduced wage formula follows from the original productivity-minus-
displacement formula and the positive capital-share identity. -/
theorem ces_wage_normalization {s B R x a capitalShare Λ e response : ℝ}
    (hs : s ≠ 1) (hR : 0 < R) (hx : 0 < x) (ha : 0 < a)
    (hshare : capitalShare = a * B ^ (s - 1) * R ^ (1 - s))
    (hresponse : response = productivity s B R (R * x) - capitalShare * Λ / (s + e)) :
    response = capitalShare * (normalizedGain s x / a - Λ / (s + e)) := by
  have hcoef : capitalShare / a = B ^ (s - 1) * R ^ (1 - s) := by
    rw [hshare]
    field_simp [ha.ne']
  rw [hresponse, ces_productivity_scale hs hR hx, ← hcoef]
  ring

/-- Isoelastic supply and the equilibrium ratio equation imply increasing
relative factor prices. C = G/(a*l0), all quantities positive. -/
theorem isoelastic_relative_price_order {s e C K1 K2 q1 q2 : ℝ}
    (hs : 0 < s) (he : 0 < e) (hC : 0 < C)
    (hK1 : 0 < K1) (hK2 : K1 < K2) (hq1 : 0 < q1) (hq2 : 0 < q2)
    (h1 : q1 ^ (s + e) = C * K1 ^ (1 + e))
    (h2 : q2 ^ (s + e) = C * K2 ^ (1 + e)) : q1 < q2 := by
  apply (Real.rpow_lt_rpow_iff hq1.le hq2.le (add_pos hs he)).mp
  rw [h1, h2]
  exact mul_lt_mul_of_pos_left
    (Real.rpow_lt_rpow hK1.le hK2 (by linarith)) hC

end AR18Sandbox
