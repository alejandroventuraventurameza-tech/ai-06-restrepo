# Economic audit — 2026-11-26

Baseline: e43c3879c8d176649ee9549be435343b848b9c52. Assignment: [issue #5](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/5). The user's issue #4 URL corresponds to the already-reviewed Repository 5.

## Primary-source comparison

- [NBER WP 22252, June 2017](https://www.nber.org/system/files/working_papers/w22252/w22252.pdf), p. 13, Proposition 3(a): the reported threshold exceeds the Assumption 3 bound and the wage is claimed to rise below the threshold. Page 14 repeats the inverted direction. Appendix B pp. B-12–B-13 derives the productivity and displacement formula and (B9)–(B10), but does not derive the threshold sentence.
- [AER 2018, MIT-hosted published PDF](https://economics.mit.edu/sites/default/files/publications/The%20Race%20Between%20Man%20and%20Machine%20-%20Implications%20of.pdf), p. 1502, Proposition 3, specifies a finite threshold with positive response above it and negative response below it. Page 1503 gives the corrected explanation. Verified text and page image of p. 1502. NBER indexed text accessible; direct PDF and screenshot returned HTTP 403, so the original historical hash is not independently reverified.
- Do not claim that the final published article contains the NBER error. The independent derivation and handwritten evidence remain valuable.

## Scope and new result

In the constrained equilibrium let $a=I-N+1>0$, $G=\int_I^N\gamma^{s-1}>0$, $s=\hat\sigma>0$, $q=W/R$, and $g_I=\gamma(I)<g_N=\gamma(N)$. Under Assumptions 1–3, (8)–(10) imply $1-s_L=aB^{s-1}R^{1-s}$. Divide the Proposition 3 wage formula by this positive factor:

$$\frac{\partial_I\ln W}{1-s_L}=\frac1a H_s(q/g_I)-\frac{\Lambda_I}{s+\varepsilon_L},\qquad H_s(x)=\int_1^x t^{-s}\,dt.$$

For isoelastic supply $L^s(\omega)=\ell_0\omega^e$, equation (13) gives $q^{s+e}=(G/(a\ell_0))K^{1+e}$. Thus $q$ strictly increases with capital, and $H_s$ strictly increases with $q$. Define $c=a\Lambda_I/(s+e)$. Exactly one interior wage-response zero exists iff $c<H_s(g_N/g_I)$; equality is an excluded upper boundary. If it exists, $q_c=g_I[1+(1-s)c]^{1/(1-s)}$ for $s\ne1$ and $K_c=[a\ell_0 q_c^{s+e}/G]^{1/(1+e)}$. For $s=1$, use $H_1=\log$; the earlier Cobb–Douglas threshold follows. If the condition fails, automation lowers wages throughout the admissible restricted interval.

This is an analytical conditional extension, **not** a proof for arbitrary labor supply or a Lean-checked endpoint. The reduction also gives strict monotonicity of the sign score when elasticity is nondecreasing in K. No claim of novel result relative to the literature.

## Evidence ledger

- **Historical Lean-checked**: special-case derivative (with differentiability premise), threshold algebra, refutation of the precise 2017 statement, productivity sign lemmas. Historical recorded axioms only standard Lean foundations. A new build is pending.
- **Analytical**: the sign reduction and conditional CES single crossing above; the original special-case analytical proof is narrowed to KBar > KUnder and admissible capital. A vacuous branch alone does not refute a logical proposition.
- **Numerical historical**: 167,639 checks with zero failures, 400 general-CES draws. A finite grid cannot establish general uniqueness.
- **Open**: frozen AML proposition3 endpoint contains one sorry; constrained price ordering from underdetermined paths and six derivative bridges are unresolved. Generated README/status mismatch (Not started/scaffold vs checked helpers) retained. Historical AML configuration was GPT-5.6 Sol high, not xhigh.
- **Presentation**: source revisions distinguish the two editions, restrict the quantifiers and capital intervals, and reproduce the final Spec rather than the stale excerpt. PDFs are not yet recompiled. No change to original hand images or generated lean folder.

## Privacy and provenance

The tracked historical lean/.review_traces/proposition3-preflight.txt requires review against the issue's instructions; do not force-add private traces. The original tree is frozen for now. If a public trace is inappropriate, document and perform a narrowly scoped removal separately rather than rewriting the generated files or claiming it was never committed.
