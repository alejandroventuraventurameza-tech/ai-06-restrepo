import Mathlib

/-!
Independent local CES derivative bridges. They take local differentiability
and the actual equilibrium identities as premises, not the desired derivative
formulas. These do not close the frozen AppliedModelingLib Spec.
-/
noncomputable section
open Real Filter
open scoped Topology
namespace AR18Sandbox

theorem constrained_lower_price_order {gamma : ℝ → ℝ} {I ITilde W R : ℝ}
    (hm : StrictMono gamma) (hI : I < ITilde) (hg : 0 < gamma I)
    (hR : 0 < R) (hratio : W / R = gamma ITilde) :
    R < W / gamma I := by
  have hW : W = gamma ITilde * R := (div_eq_iff hR.ne').mp hratio
  apply (lt_div_iff₀ hg).mpr
  calc
    R * gamma I = gamma I * R := mul_comm _ _
    _ < gamma ITilde * R := mul_lt_mul_of_pos_right (hm hI) hR
    _ = W := hW.symm

theorem upper_price_order_iff {gamma : ℝ → ℝ} {ITilde N W R : ℝ}
    (hm : StrictMono gamma) (hg : 0 < gamma N)
    (hR : 0 < R) (hratio : W / R = gamma ITilde) :
    W / gamma N < R ↔ ITilde < N := by
  have hW : W = gamma ITilde * R := (div_eq_iff hR.ne').mp hratio
  rw [div_lt_iff₀ hg, hW, mul_comm R (gamma N), mul_lt_mul_iff_of_pos_right hR]
  constructor
  · intro h
    by_contra! hn
    exact (not_lt_of_ge (hm.monotone hn)) h
  · exact hm

/-- Boundary equality alone does not imply the order below the boundary.
This is not a counterexample to the full AML Spec. -/
theorem boundary_equality_alone_insufficient :
    ∃ w r : ℝ → ℝ,
      (∀ k : ℝ, 0 < k → 0 < w k ∧ 0 < r k) ∧
      r 2 = w 2 / 2 ∧ ¬ w 1 / 2 < r 1 := by
  refine ⟨fun k => 1 + 2 / k, fun _ => 1, ?_, ?_, ?_⟩
  · intro k hk
    constructor <;> positivity
  · norm_num
  · norm_num

/-- Differentiate the log equilibrium factor ratio at fixed K. -/
theorem ces_relative_price_derivative
    {a G w r ell : ℝ → ℝ} {t s e logK da dG dw dr : ℝ}
    (hs : 0 < s) (he : 0 < e) (ha0 : 0 < a t) (hG0 : 0 < G t)
    (ha : HasDerivAt a da t) (hG : HasDerivAt G dG t)
    (hw : HasDerivAt w dw t) (hr : HasDerivAt r dr t)
    (hell : HasDerivAt ell e (w t - r t - logK))
    (hRatio : ∀ᶠ x in 𝓝 t,
      s * (w x - r x) + ell (w x - r x - logK) =
        Real.log (G x) - Real.log (a x) + logK) :
    dw - dr = (dG / G t - da / a t) / (s + e) := by
  have hdiff := hw.sub hr
  have harg := hdiff.sub_const logK
  have hleft := (hdiff.const_mul s).add (hell.comp t harg)
  have hright := ((hG.log hG0.ne').sub (ha.log ha0.ne')).add_const logK
  have hkey := ((EventuallyEq.hasDerivAt_iff hRatio).mp hleft).unique hright
  apply (eq_div_iff (add_pos hs he).ne').mpr
  linear_combination hkey

/-- Differentiate the CES dual price identity with fixed B. -/
theorem ces_dual_price_derivative
    {a G w r : ℝ → ℝ} {t s C da dG dw dr : ℝ}
    (ha : HasDerivAt a da t) (hG : HasDerivAt G dG t)
    (hw : HasDerivAt w dw t) (hr : HasDerivAt r dr t)
    (hDual : ∀ᶠ x in 𝓝 t,
      a x * Real.exp ((1-s) * r x) + G x * Real.exp ((1-s) * w x) = C) :
    (1-s) * (a t * Real.exp ((1-s)*r t) * dr +
      G t * Real.exp ((1-s)*w t) * dw) =
      -(da * Real.exp ((1-s)*r t) + dG * Real.exp ((1-s)*w t)) := by
  have hER := (hr.const_mul (1-s)).exp
  have hEW := (hw.const_mul (1-s)).exp
  have hleft := (ha.mul hER).add (hG.mul hEW)
  have hkey := ((EventuallyEq.hasDerivAt_iff hDual).mp hleft).unique (hasDerivAt_const t C)
  linear_combination hkey

theorem ces_dual_weight_normalization
    {s C a G ER EW da dG dw dr sL : ℝ}
    (hs : s ≠ 1) (hC : 0 < C)
    (hcap : a * ER = (1-sL) * C) (hlab : G * EW = sL * C)
    (hweighted : (1-s) * (a * ER * dr + G * EW * dw) = -(da*ER+dG*EW)) :
    (1-sL)*dr+sL*dw = -(da*ER+dG*EW)/((1-s)*C) := by
  rw [hcap, hlab] at hweighted
  apply (eq_div_iff (mul_ne_zero (sub_ne_zero.mpr (Ne.symm hs)) hC.ne')).mpr
  linear_combination hweighted

theorem solve_log_factor_prices {sL dr dw productivity delta : ℝ}
    (hweighted : (1-sL)*dr+sL*dw = productivity)
    (hrelative : dw-dr = delta) :
    dw = productivity+(1-sL)*delta ∧ dr = productivity-sL*delta := by
  constructor
  · linear_combination hweighted + (1-sL)*hrelative
  · linear_combination hweighted - sL*hrelative

end AR18Sandbox
