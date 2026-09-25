# Extensions

What could be relaxed or added, stated precisely: which equation changes and what we expect.
Checked against the paper first: Appendix A (general model, Assumption 2′) and Appendix B (B1–B4:
general comparative statics, welfare, ε ∈ (0,1), ν ∈ (0,1)), plus Section 5 (skills, creative destruction, welfare),
do **not** contain an open-economy or cross-country version of the static threshold.

## 1. (Candidate for the term project) The same automation technology in capital-rich and capital-poor economies

**Idea.** The corrected threshold says that an advance in the automation frontier $I$ raises the wage only if capital is abundant
enough, $K>\hat K$. Below $K_I$ it is not even adopted (free regime), and in $(K_I,\hat K)$ it is adopted and **lowers** the wage.
Automation technologies are mostly developed in capital-rich economies and diffused to capital-poor ones. So the *same* $dI$ can raise
wages in the North ($K_N>\hat K$) and lower them in the South ($K_I<K_S<\hat K$).

**What changes.** Two economies $j\in\{N,S\}$ share the technology $(I,N)$ (common frontier) but differ in $K_j$ (and possibly $L_j$,
$\varepsilon_{L,j}$). Equations (8)–(12) hold country by country. With Cobb–Douglas across tasks (our special case) everything is
explicit: $d\ln W_j/dI=\log\big(K_j/K_{I,j}\big)-1/\big((N-I)(1+\varepsilon_{L,j})\big)$.

**Expected result.** Wage divergence after a common automation shock whenever $K_S<\hat K_S<\hat K_N<K_N$. With directed technical change
(the paper's Section 4), innovation targeted at the North's factor prices would choose too much automation for the South: an
"appropriate technology" mechanism in the spirit of Acemoglu & Zilibotti (2001, *QJE*). **To check before claiming novelty:** the later
literature on robots, demographics and automation in developing economies.

**Why it can grow.** (i) Theory: prove the single crossing for $\hat\sigma\neq1$ (P7 in `sim/` suggests it holds). (ii) Dynamics: the
short-run wage dip after automation lasts while $K(t)<\hat K$. (iii) Data: capital per worker and robot adoption (IFR) for Peru and the
region against wage growth in exposed occupations.

## 2. Single crossing for general $\hat\sigma$ (theory)
Our Theorem 4.2 uses $\hat\sigma=1$, where the labor share does not depend on $K$. For $\hat\sigma\neq1$ the displacement term
$(1-s_L(K))\Lambda_I/(\hat\sigma+\varepsilon_L(K))$ moves with $K$. Goal: sufficient conditions on $\hat\sigma$ and $L^s$ under which
$d\ln W/dI$ crosses zero once. Numerical evidence (400 draws): at most one crossing, always from − to +.

## 3. What happens at the boundary $I^*=I=\tilde I$
The paper drops it (footnote 15). The one-sided derivatives are $0$ and $-(1-s_L)\Lambda_I/(\hat\sigma+\varepsilon_L)$. A formal treatment
with one-sided derivatives, or a smooth approximation of the $\min$, would complete the comparative statics. It is a small but clean
Lean target.
