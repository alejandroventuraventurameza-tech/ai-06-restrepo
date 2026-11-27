# Repository 6 closeout audit — 26 November 2026 (Lima)

## Verified evidence

| Gate | Evidence |
|---|---|
| Historical repository and issue comment | PRs #1–4 merged September 24 before 22:00 Lima; issue #5 comment posted before deadline. November revisions are submitted through PR #5. |
| Assigned source | NBER WP 22252 June 2017 source pin preserved. AER p. 1502 visually compared and direction reconciled. Direct NBER PDF blocked (403), course path returned 404; historical PDF hash not independently recomputed. |
| Historical AML | Run 45929885625, job 140279812715: paper_contribution.py check --fast exit 0; lake build exit 0 (8317 jobs); original proof hole remains. Pinned upstream revision 2db7d108cd3a2cb10148974bb2a77856e7d87428. |
| Independent Lean | Run 45930791358, job 140282723690, on 976f9908a8ae38b0e1634f7d061c31b25ea8dc4e: build 8319 jobs; exactly 25 named theorem endpoints, only standard Lean foundations. See lean-axioms-20261126.txt. |
| Economics | Run 45930791358, job 140282723791 successful; earlier detailed run 45929885625: 17 symbolic identities, 167,639 original and 11,770 new numerical checks, zero failures. New test 500 isoelastic economies (377 roots, 123 without interior root), maximum wage-derivative discrepancy 9.944e-9; 240 figure points reproduced. |
| Documents | Run 45930791328 completed successfully, source commit 976f9908a8ae38b0e1634f7d061c31b25ea8dc4e, PDF candidate commit 264b5b783f8b2cc169b0a19cb5b73f8d3ee1ce33. 20-slide deck, 8-page derivation, 10-page tutorial. All earlier sheets reviewed and all changed sheets reviewed again. Final source blob identities match the compiled source. One residual title-page vertical-box warning (13.79993pt); no visible clipping. Exact hashes and sheets in qa-render/. |
| Hand notes and AML preservation | Preservation check compares to e43c3879c8d176649ee9549be435343b848b9c52; all six original photos and generated tracked artifacts unchanged except the explicitly upstream-ignored preflight trace removed from the delivery tree. No history rewrite; prior trace remains in Git history. |

## Boundaries and deviations

- The original AppliedModelingLib proof is partial. The required historical run used GPT-5.6 Sol high, not xhigh, because of the quota. The student reports permission to use GPT-6 and email the later continuation; actual reasoning-effort metadata is not available here. Original raw transcripts are not fully recoverable; existing genuine logs/excerpts are preserved. No reconstructed transcript is represented as raw.
- The 25 independent endpoints prove the stated narrower economic and mathematical results, not the original whole Proposition 3. The isoelastic crossing is conditional; arbitrary labor supply is not proved to have a unique crossing. The local price bridges deduce derivatives from positive differentiable local equilibrium paths and dual/factor-ratio identities. Global source-to-Spec regularity, identification of these paths, free-regime derivative assembly and remaining clauses remain open. The boundary counterexample concerns the isolated equality implication, not every premise of the source Spec.
- NBER 2017 contains the reversed threshold; AER 2018 already corrects the direction. No claim of an unpublished correction to AER, novel general theorem, or empirical causal estimate is made.
- The 20-minute guide is a suggested timing plan, not a claim that the student has rehearsed or presented the revised deck.
- November work is a revision of the already posted repository. No email or new issue comment has been sent.

The final integration commit consists only of the reviewed PDF artifacts and documentation after the validated source revision. See the PR history for exact commits.
