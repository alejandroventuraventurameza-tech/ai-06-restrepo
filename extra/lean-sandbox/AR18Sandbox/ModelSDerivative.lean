import Mathlib
import AR18Sandbox.WageThreshold

/-!
# The wage response is the derivative of the equilibrium log wage (own analysis)

Source: `derivation/derivation.tex`, Lemmas 2.3–2.4, 3.1–3.2 and Theorem 3.3 (special case of
Acemoglu–Restrepo, NBER WP 22252, June 2017: `η = 0`, `σ = 1`, elastic labor supply).

Regime (R), `I* = I`, with the automation frontier `x` as the variable:

* `a x = x - N + 1`, `b x = N - x`                                   (task masses);
* `lw x = log ω(x)`, `ω = W/(RK)`, and `ell t = log Lˢ(eᵗ)`, so `log L(x) = ell (lw x)`;
* labor-market equilibrium (derivation, Lemma 2.4): `ω Lˢ(ω) = b/a`, i.e.
  `lw x + ell (lw x) = log (N - x) - log (x - N + 1)`                 (hypothesis `hLabor`);
* output (derivation, eq. (2.4)):
  `ln Y(x) = a (log K - log a) + b (log L - log b) + ∫_x^N log γ(t) dt`;
* wage (derivation, eq. (2.3)): `ln W(x) = log b + ln Y(x) - log L(x)`.

`hasDerivAt_lnW` proves that `d ln W / dx` at `x = I` equals
`wageResponse a b ε L γ(I) K = log (bK/(aLγ(I))) - 1/(b(1+ε))`, where `ε = ell'(lw I)` is the
labor-supply elasticity at the equilibrium. Combined with `WageThreshold.lean`, this gives the
full chain: equilibrium conditions ⟹ derivative ⟹ sign = sign(K - K̂).

Named hypotheses (what Lean needs, beyond the derivation's A1/A3/LS/S-η/S-σ/C):
* `hlw` — the equilibrium `log ω` is differentiable in `I`. The derivation obtains this from
  the implicit function theorem; here it is an explicit regularity premise (it is **not** the
  value of the derivative, which Lean derives from `hLabor`).
* `hell` — `Lˢ` is differentiable with elasticity `ε` at the equilibrium (Assumption LS).
* `hγ` — `γ` is continuous and positive (Assumption C).
-/

noncomputable section

open Real Filter intervalIntegral
open scoped Topology

namespace AR18Sandbox

/-- Log output in regime (R) as a function of the automation frontier `x` (derivation, (2.4)). -/
def lnYS (N K : ℝ) (gamma ell lw : ℝ → ℝ) (x : ℝ) : ℝ :=
  (x - N + 1) * (Real.log K - Real.log (x - N + 1)) +
    (N - x) * (ell (lw x) - Real.log (N - x)) + ∫ t in x..N, Real.log (gamma t)

/-- Log wage `ln W = log b + ln Y - log L` (derivation, (2.3)). -/
def lnWS (N K : ℝ) (gamma ell lw : ℝ → ℝ) (x : ℝ) : ℝ :=
  Real.log (N - x) + lnYS N K gamma ell lw x - ell (lw x)

/-- **Theorem 3.3 of the derivation, wage clause, checked from the equilibrium conditions.** -/
theorem hasDerivAt_lnWS {N K I eps : ℝ} {gamma ell lw : ℝ → ℝ}
    (hI : N - 1 < I ∧ I < N) (hK : 0 < K)
    (hγ : Continuous gamma) (hγpos : ∀ t, 0 < gamma t)
    (hell : HasDerivAt ell eps (lw I)) (heps : 0 < 1 + eps)
    (hlw : DifferentiableAt ℝ lw I)
    (hLabor : ∀ᶠ x in 𝓝 I, lw x + ell (lw x) = Real.log (N - x) - Real.log (x - N + 1)) :
    HasDerivAt (lnWS N K gamma ell lw)
      (wageResponse (I - N + 1) (N - I) eps (Real.exp (ell (lw I))) (gamma I) K) I := by
  obtain ⟨hI1, hI2⟩ := hI
  have ha : 0 < I - N + 1 := by linarith
  have hb : 0 < N - I := by linarith
  set d := deriv lw I with hd_def
  have hlw' : HasDerivAt lw d I := hlw.hasDerivAt
  -- (1) the labor-market identity pins down d = d(log ω)/dI
  have hcomp : HasDerivAt (fun x => lw x + ell (lw x)) (d + eps * d) I :=
    hlw'.add (hell.comp I hlw')
  have hb' : HasDerivAt (fun x => N - x) (-1) I := by
    simpa using (hasDerivAt_id I).const_sub N
  have ha' : HasDerivAt (fun x => x - N + 1) 1 I := by
    simpa using ((hasDerivAt_id I).sub_const N).add_const 1
  have hlogb : HasDerivAt (fun x => Real.log (N - x)) (-1 / (N - I)) I := hb'.log hb.ne'
  have hloga : HasDerivAt (fun x => Real.log (x - N + 1)) (1 / (I - N + 1)) I := ha'.log ha.ne'
  have hrhs : HasDerivAt (fun x => Real.log (N - x) - Real.log (x - N + 1))
      (-1 / (N - I) - 1 / (I - N + 1)) I := hlogb.sub hloga
  have hkey : d + eps * d = -1 / (N - I) - 1 / (I - N + 1) :=
    ((EventuallyEq.hasDerivAt_iff hLabor).mp hcomp).unique hrhs
  -- (2) derivative of log output
  have hlogγ : Continuous fun t => Real.log (gamma t) :=
    hγ.log fun t => (hγpos t).ne'
  have hint : HasDerivAt (fun x => ∫ t in x..N, Real.log (gamma t)) (-Real.log (gamma I)) I :=
    integral_hasDerivAt_left (hlogγ.intervalIntegrable _ _)
      (hlogγ.stronglyMeasurableAtFilter _ _) hlogγ.continuousAt
  have hell' : HasDerivAt (fun x => ell (lw x)) (eps * d) I := hell.comp I hlw'
  have hY1 : HasDerivAt (fun x => (x - N + 1) * (Real.log K - Real.log (x - N + 1)))
      (1 * (Real.log K - Real.log (I - N + 1)) + (I - N + 1) * (0 - 1 / (I - N + 1))) I :=
    ha'.mul ((hasDerivAt_const I (Real.log K)).sub hloga)
  have hY2 : HasDerivAt (fun x => (N - x) * (ell (lw x) - Real.log (N - x)))
      (-1 * (ell (lw I) - Real.log (N - I)) + (N - I) * (eps * d - -1 / (N - I))) I :=
    hb'.mul (hell'.sub hlogb)
  have hY : HasDerivAt (lnYS N K gamma ell lw) _ I := (hY1.add hY2).add hint
  have hW : HasDerivAt (lnWS N K gamma ell lw) _ I := (hlogb.add hY).sub hell'
  convert hW using 1
  -- (3) algebra: the derivative equals log(bK/(aLγ)) - 1/(b(1+ε))
  have hL : 0 < Real.exp (ell (lw I)) := Real.exp_pos _
  have hg := hγpos I
  unfold wageResponse
  rw [Real.log_div (by positivity) (by positivity), Real.log_mul hb.ne' hK.ne',
    Real.log_mul (by positivity) hg.ne', Real.log_mul ha.ne' hL.ne', Real.log_exp]
  have ha0 : I - N + 1 ≠ 0 := ha.ne'
  have hb0 : N - I ≠ 0 := hb.ne'
  have he0 : 1 + eps ≠ 0 := heps.ne'
  have hd : d = (-1 / (N - I) - 1 / (I - N + 1)) / (1 + eps) := by
    rw [eq_div_iff he0]; linear_combination hkey
  rw [hd]
  field_simp
  ring

/-- **End-to-end**: from the equilibrium conditions of the special case, the derivative of the
log wage with respect to automation is positive iff `K > K̂`, negative iff `K < K̂`. -/
theorem automation_raises_wage_iff {N K I eps : ℝ} {gamma ell lw : ℝ → ℝ}
    (hI : N - 1 < I ∧ I < N) (hK : 0 < K)
    (hγ : Continuous gamma) (hγpos : ∀ t, 0 < gamma t)
    (hell : HasDerivAt ell eps (lw I)) (heps : 0 < 1 + eps)
    (hlw : DifferentiableAt ℝ lw I)
    (hLabor : ∀ᶠ x in 𝓝 I, lw x + ell (lw x) = Real.log (N - x) - Real.log (x - N + 1)) :
    (0 < deriv (lnWS N K gamma ell lw) I ↔
        Khat (I - N + 1) (N - I) eps (Real.exp (ell (lw I))) (gamma I) < K) ∧
    (deriv (lnWS N K gamma ell lw) I < 0 ↔
        K < Khat (I - N + 1) (N - I) eps (Real.exp (ell (lw I))) (gamma I)) := by
  have h := (hasDerivAt_lnWS hI hK hγ hγpos hell heps hlw hLabor).deriv
  have ha : 0 < I - N + 1 := by linarith [hI.1]
  have hb : 0 < N - I := by linarith [hI.2]
  rw [h]
  exact ⟨wageResponse_pos_iff ha hb (Real.exp_pos _) (hγpos I) hK,
    wageResponse_neg_iff ha hb (Real.exp_pos _) (hγpos I) hK⟩

/-- **Non-vacuity**: the hypotheses of `hasDerivAt_lnWS` are jointly satisfiable. With a
constant-elasticity labor supply `Lˢ(ω) = ω^ε` (`ell t = ε t`), the equilibrium
`log ω(x) = (log b - log a)/(1+ε)` satisfies the labor-market identity, and the
regularity premises hold. So the theorem is not true merely because its premises are empty. -/
theorem hypotheses_satisfiable {N I eps : ℝ} (hI : N - 1 < I ∧ I < N) (heps : 0 < 1 + eps) :
    ∃ ell lw : ℝ → ℝ, HasDerivAt ell eps (lw I) ∧ DifferentiableAt ℝ lw I ∧
      ∀ᶠ x in 𝓝 I, lw x + ell (lw x) = Real.log (N - x) - Real.log (x - N + 1) := by
  obtain ⟨hI1, hI2⟩ := hI
  have ha : 0 < I - N + 1 := by linarith
  have hb : 0 < N - I := by linarith
  refine ⟨fun t => eps * t, fun x => (Real.log (N - x) - Real.log (x - N + 1)) / (1 + eps),
    ?_, ?_, Eventually.of_forall fun x => ?_⟩
  · simpa using (hasDerivAt_id (((Real.log (N - I) - Real.log (I - N + 1)) / (1 + eps)))).const_mul eps
  · have h1 : DifferentiableAt ℝ (fun x => Real.log (N - x)) I :=
      ((differentiableAt_id.const_sub N).log hb.ne')
    have h2 : DifferentiableAt ℝ (fun x => Real.log (x - N + 1)) I :=
      (((differentiableAt_id.sub_const N).add_const 1).log ha.ne')
    exact (h1.sub h2).div_const _
  · field_simp

end AR18Sandbox
