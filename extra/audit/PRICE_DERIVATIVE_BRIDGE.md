# Local derivative bridges (independent continuation)

Write $s=\hat\sigma$, $w=\ln W$, $r=\ln R$, $a=I^*-N+1$, $G=\int_{I^*}^N\gamma^{s-1}$, $\ell(z)=\ln L^s(e^z)$. All factor prices, task masses and labor supply are positive, and the paths are locally differentiable in the perturbation variable. At fixed $K$ and $B$, the equilibrium identities give

$$s(w-r)+\ell(w-r-\ln K)=\ln G-\ln a+\ln K,$$

$$a e^{(1-s)r}+G e^{(1-s)w}=C=B^{1-s}.$$

Differentiating these identities (rather than assuming the desired derivatives) yields

$$(s+\varepsilon_L)(dw-dr)=dG/G-da/a,$$

$$(1-s)(aR^{1-s}dr+GW^{1-s}dw)=-(R^{1-s}da+W^{1-s}dG).$$

For $s\ne1$, use $aR^{1-s}=C(1-s_L)$ and $GW^{1-s}=Cs_L$. Define $\Delta=(dG/G-da/a)/(s+\varepsilon_L)$ and $\Pi=-(R^{1-s}da+W^{1-s}dG)/[(1-s)C]$. Then

$$dw=\Pi+(1-s_L)\Delta,\qquad dr=\Pi-s_L\Delta.$$

In regime R, $da=dI-dN$, $dG=-\gamma(I)^{s-1}dI+\gamma(N)^{s-1}dN$. This recovers the displacement component and the productivity term in Proposition 3. The free-regime comparative statics require the motion of the endogenous cutoff and are not inferred from the restricted-regime formula.

Price ordering: strict monotonicity of $\gamma$ and $W/R=\gamma(\tilde I)$ give $R<W/\gamma(I)$ if $I<\tilde I$, and $W/\gamma(N)<R$ iff $\tilde I<N$ (positive denominators). A boundary equality alone at some other capital level cannot justify the latter. For example $w(k)=1+2/k$, $r(k)=1$ have positive prices for $k>0$ and $r(2)=w(2)/2$, yet $w(1)/2>r(1)$. This example tests only the boundary equality implication, not all premises of the original Spec.

The new independent Lean file states seven precise local/algebraic endpoints, including this limited counterexample. Their compilation and axiom audit passed in CI 45930791358, on source commit 976f9908a8ae38b0e1634f7d061c31b25ea8dc4e. This is a route around two proof obstacles, not a completion or replacement of the original AML target. Global equilibrium regularity, the identification of the local price paths with the frozen Spec, and its other open clauses remain separate obligations.

## First build and repair

CI 45930531521 first compiled the module but reported a single elaboration mismatch at line 34: StrictMono gamma is a dependent function with implicit point arguments, and the goal required an explicit implication at ITilde and N. Replaced exact hm by intro h; exact hm h. The mathematical statement and proof premises are unchanged. The fresh build confirmed the repair: 8319 build jobs, 25 independent endpoints, only standard Lean foundations. See lean-axioms-20261126.txt.
