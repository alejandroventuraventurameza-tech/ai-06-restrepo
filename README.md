# Repository 6 — Acemoglu & Restrepo

**Assigned source:** NBER Working Paper 22252, *The Race Between Machine and Man*, revised June 2017 (87 pp., [source pin](paper/README.md)). Published as *The Race between Man and Machine*, AER 108(6), 1488–1542 (2018). All source numbering is NBER unless marked AER. [Assignment](https://github.com/alexanderquispe/AI-Econ-Modeling/issues/5).

## Question and model
Can continuing automation coexist with balanced growth, a stable labor share and employment? The unit of analysis is the **aggregate task allocation**, rather than one optimizer. A CES aggregates tasks $i\in[N-1,N]$. Capital can perform $i\le I$; firms choose the cheaper feasible factor ($R$ versus $W/\gamma(i)$), with $\gamma$ strictly increasing. Households supply $L=L^s(W/(RK))$. The equilibrium cutoff is $I^*=\min(I,\tilde I)$ with $W/R=\gamma(\tilde I)$. Automation increases $I$; new tasks increase $N$.

## Main result and conditions
Under Assumptions 1–3 (comparative advantage, homothetic demand and adoption of new tasks), $\varepsilon_L>0$, $\hat\sigma>0$, $\hat\sigma\ne1$ in the printed formula, and the **strict restricted regime** $I^*=I<\tilde I<N$, Proposition 3 gives
$$
\frac{d\ln W}{dI}=
\underbrace{B^{\hat\sigma-1}\int_R^{W/\gamma(I)}x^{-\hat\sigma}dx}_{\text{productivity }(+)}
-\underbrace{\frac{(1-s_L)\Lambda_I}{\hat\sigma+\varepsilon_L}}_{\text{displacement }(-)},\quad
\Lambda_I=\frac{\gamma(I)^{\hat\sigma-1}}{\int_I^N\gamma^{\hat\sigma-1}}+\frac1{I-N+1}>0.
$$
The wage rises iff productivity exceeds displacement; the labor share and employment fall. In the strict free regime $\tilde I<I$, marginal automation has no effect; the boundary is excluded. New tasks counter displacement through reinstatement. In the interior constrained BGP (Prop. 5; Assumptions 1′ and 2, constant $g$, $n=N-I>\max\{\bar n(\rho),\tilde n(\rho)\}$), effective wages rise and labor share/employment fall; the interior free BGP instead has zero marginal automation effect (AER pp. 1508–1509).

## Our analysis
NBER 2017 p. 13 reverses the capital-threshold signs; AER 2018 p. 1502 already corrects them. Under the Cobb–Douglas/no-intermediate special case and elastic labor, for $K_I<K<\underline K$ the wage rises iff
$$K>\hat K=K_I\exp\!\left(\frac1{(N-I)(1+\varepsilon_L)}\right).$$
The positive region exists iff $\hat K<\underline K$. Below $K_I$ additional automation is not adopted. The independent counterexample refutes the assigned wording, not the corrected publication. The November CES extension proves an interior-crossing condition under isoelastic labor supply, not arbitrary supply. See [economic audit](extra/audit/ECONOMIC_AUDIT.md) and [derivation](derivation/derivation.pdf).

## Verification and deliverables
- [Presentation PDF](presentation.pdf) and [Beamer source](presentation.tex); [20-minute guide](extra/audit/PRESENTATION_GUIDE.md), [tutorial](extra/tutorial/tutorial.pdf).
- [Historical AML export](lean/): GPT-5.6 Sol high, not xhigh; one original sorry remains in Proposition 3. Successful build and --fast replay do not prove that endpoint. Original generated files preserved except an upstream-ignored preflight trace (see audit). [Agent logs](extra/lean-run/) and [prompts/deviations](prompts.md).
- [Independent Lean sandbox](extra/lean-sandbox/): [CI 45930791358](https://github.com/alejandroventuraventurameza-tech/ai-06-restrepo/actions/runs/45930791358) verified 25 endpoints with standard Lean foundations, including [seven local derivative bridges](extra/audit/PRICE_DERIVATIVE_BRIDGE.md). [Closeout audit](extra/audit/CLOSEOUT.md).
- [Numerical verification](sim/): 17 symbolic identities, 167,639 original checks and 11,770 new checks, zero failures. [Extensions](extensions.md) and [requirements](REQUIREMENTS.md).

## Handwritten evidence (original, unchanged)
- [1](hand/hand_1.jpeg): assumptions and expenditure FOC.
- [2](hand/hand_2.jpeg): factor prices, labor share and employment derivative.
- [3](hand/hand_3.jpeg): productivity and wage-response derivation.
- [4](hand/hand_4.jpeg): capital thresholds.
- [5](hand/hand_5.jpeg): capital regions (revised derivation clarifies when the positive interval is empty).
- [6](hand/hand_6.jpeg): counterexample to the printed NBER threshold.
