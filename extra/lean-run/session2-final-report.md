I stopped without changing the repository because the frozen Spec needs maintainer review.

The blocking mismatch is in [PaperInterface.lean](/home/asus/AppliedModelingLib/papers/AR18RaceManMachine/PaperInterface.lean:300): the source’s capital-threshold sentence occurs inside the standing regime \(I^*=I<\widetilde I\), but lines 316–320 quantify over every positive comparison capital `k` without requiring that regime at `k`.

For sufficiently low capital, the equilibrium can enter the free regime \(\widetilde I<I\). The second bullet then requires the wage’s \(I\)-derivative to be zero, while lines 317–318 require it to be strictly positive because \(k<KBar\). A concrete specialization illustrating this uses
\(\hat\sigma=2\), \(\gamma(i)=e^i\), \(L^s(\omega)=\omega\), \(B=1\), \(N=1\), and \(I=1/2\): below the constrained/free transition, equilibrium wages are independent of \(I\).

The likely repair is to restrict both threshold quantifiers to comparison configurations satisfying `I < freeThreshold I N k`, or otherwise quantify over equilibria satisfying the entire constrained-regime premise. I did not make that change.

### Files

No repository files were created or changed by me. Temporary diagnostics were created only under `/tmp`. Existing workspace changes and untracked files were preserved.

The Spec was not changed. The original `sorry` remains at [ProofInterface.lean](/home/asus/AppliedModelingLib/papers/AR18RaceManMachine/ProofInterface.lean:13).

### Clause status under R4

| Clause | Status |
|---|---|
| P3.a ordering | open — proof campaign stopped at the Spec mismatch |
| P3.a productivity differential | open — requires the variable-limit integral derivative |
| P3.a both productivity coefficients positive | open — downstream of ordering and derivative work |
| P3.a wage and rental formulas | open — requires deriving B9–B10 from equilibrium paths |
| P3.a higher \(N\): wage/rental signs | open — includes a cross-capital existential |
| P3.a higher \(I\): rental/wage signs | open — includes a cross-capital existential |
| P3.a capital threshold | open — Lean encoding drops the standing regime; its unrestricted reading conflicts with P3.b |
| P3.b ordering | open — a diagnostic Lean derivation succeeded, but no repository lemma was committed after the mandatory stop |
| P3.b productivity differential | open — requires the production-function derivative |
| P3.b productivity signs/no automation effect | open |
| P3.b wage and rental formulas | open — requires free-regime B9–B10 |
| P3.b higher \(N\): wage/rental signs | open |
| P3.b \(I\) has no factor-price effect | open |

### Diagnostics

`lake build +AR18RaceManMachine` exited successfully, but correctly reported the unresolved endpoint:

```text
⚠ [8315/8316] Replayed AR18RaceManMachine.ProofInterface
warning: papers/AR18RaceManMachine/ProofInterface.lean:13:8: declaration uses `sorry`
Build completed successfully (8316 jobs).
```

`python3 scripts/paper_contribution.py check AR18RaceManMachine --fast` exited `0`:

```text
+ lake build +AR18RaceManMachine.PaperInterface
Build completed successfully (8314 jobs).
+ git diff --check -- papers/AR18RaceManMachine papers/AR18RaceManMachine.lean lakefile.toml ':(exclude)papers/AR18RaceManMachine/source/'
```

That fast check only builds `PaperInterface`, so it does not clear the unresolved proof endpoint. Closeout and final-validation artifacts were not generated.

The source ambiguity is the scope of “when \(K<\bar K\)” and “when \(K>\bar K\)” in the threshold sentence. Its placement strongly suggests that the surrounding constrained-regime condition remains active; the current Lean statement instead treats it as an unrestricted all-capital assertion.