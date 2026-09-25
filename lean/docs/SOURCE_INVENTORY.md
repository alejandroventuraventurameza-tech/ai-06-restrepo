# Source Inventory: AR18RaceManMachine

## Source pin

- Governing source: NBER Working Paper 22252, revised June 2017.
- Official page: <https://www.nber.org/papers/w22252>.
- Official PDF: <https://www.nber.org/system/files/working_papers/w22252/w22252.pdf>.
- PDF SHA-256: `441d01202afd56ef8002fc24ffc2beb51191741c0b5accb11d2534620dd616b7`.
- PDF metadata title: `man_vs_machine_june_6_2017.dvi`.
- Page count: 87.
- Cached `pdftotext -layout` extraction SHA-256:
  `f00f7422f2ae98c11ccf00a1c60213c418f3d70e81d403df2b011ba416aafea7`.
- One official/arXiv intake search found the official NBER revision and no
  corresponding arXiv record.

After this source-first inventory was completed, the run was restricted to the
frozen extracts for printed pp. 5--14 and Appendix B, pp. B-12--B-13, as
required by R1.

## Selected result

Exactly one source result is selected:

- Proposition 3, “Impact of technology on productivity, wages, and factor
  prices,” Section 2.2, printed p. 13. Every sentence and displayed formula in
  both bullets is one clause of the single `proposition3Spec` review row.

The proof endpoint is `AR18RaceManMachine.proposition3`. Its proof is deferred
and currently contains `sorry` as permitted for this statement-first session.

## Governing semantic prerequisites

The following are prerequisites, not additional selected paper results:

- Section 2.1 static environment and the static-equilibrium definition;
- equations (1)--(3) and (5)--(12);
- Assumptions 1--3;
- `sigmaHat`, `B`, `LambdaI`, `LambdaN`, `epsilonL`, `epsilonGamma`,
  `sigmaFree`, and `sL` from Proposition 2 and its surrounding text;
- proof relations (B9)--(B10), retained as concrete transparent relations;
- footnote 15's explicit omission of the boundary `Istar = I = ITilde`.

Equation (4), preferences, is context for the labor-supply schedule but is not
needed as an independent semantic object once equation (11), monotonicity, and
the elasticity definition are exposed. Equations (13) onward and dynamic-model
objects are outside this selected result.

## Complete named-presentation inventory

The one-time whole-source inventory found the following visibly named theory.
Only Proposition 3 and its governing prerequisites above are in this run's
maintainer-selected scope.

### Main text

- Assumptions 1, 2, and 3: selected governing prerequisites.
- Proposition 1, Corollary 1, Proposition 2: result rows out of scope; only the
  definitions from Proposition 2 needed by Proposition 3 are prerequisites.
- Proposition 3: selected result.
- Assumption 1-prime; Propositions 4 and 5: out of scope.
- Assumption 4; Proposition 6; Corollary 2: out of scope.
- Assumption 1-double-prime; Propositions 7, 8, and 9: out of scope.

### Appendices

- Assumption 2-prime; Lemmas A1 and A2: out of scope except where the printed
  Proposition 3 proof cites earlier comparative statics already represented by
  the concrete equilibrium equations.
- Assumption 1-prime and Assumption 4 restatements: presentation aliases of
  main-text assumptions and out of scope.
- Lemma A3: out of scope.
- Proposition B1: out of scope; it is a general-model counterpart of
  Proposition 2, not the selected result.
- Lemma B1 and Proposition B2: out of scope.
- Assumption 2-double-prime and Propositions B3--B4: out of scope.

The source's empirical appendix, figures, tables, standalone displayed
formulas, simulations, literature discussion, and dynamic sections are
deep-audit material and are excluded by the maintainer's explicit selection.
They do not create additional claim rows.

## Proposition 3 source atoms

### Bullet (a): `Istar = I < ITilde`

1. `W / gamma Istar > R > W / gamma N`.
2. The two-term formula for `d ln Y` at fixed `K,L` in `dI,dN`.
3. Both automation and new tasks increase productivity.
4. The displayed formulas for `d ln W` and `d ln R`.
5. Higher `N` always raises the wage and may reduce the rental rate.
6. Higher `I` always raises the rental rate and may reduce the wage.
7. There exists an upper threshold `KBar > KUnder`; the automation wage
   derivative is strictly positive below `KBar` and strictly negative above it.

### Bullet (b): `Istar = ITilde < I`

1. `W / gamma Istar = R > W / gamma N`.
2. The one-term formula for `d ln Y` at fixed `K,L`.
3. New tasks increase productivity and additional automation does not.
4. The displayed `sigmaFree` formulas for `d ln W` and `d ln R`.
5. Higher `N` always raises the wage and may reduce the rental rate.
6. Higher `I` has no effect on either factor price.

## Dependency order

1. CES/task aggregation and equation (12) production definitions.
2. Static equilibrium equations (1)--(3), (5)--(12), Assumptions 1--3.
3. Proposition 2 quantities and the actual-derivative interpretation.
4. Appendix B relations (B9)--(B10).
5. Proposition 3's single Spec and proof endpoint.
