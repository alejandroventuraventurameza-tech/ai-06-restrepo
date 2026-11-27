#!/usr/bin/env bash
# Replay, not a new agent run or a proof of the unfinished source theorem.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
upstream="$(cd "$1" && pwd)"
pin=2db7d108cd3a2cb10148974bb2a77856e7d87428
paper=AR18RaceManMachine
cd "$upstream"
test "$(git rev-parse HEAD)" = "$pin"
test ! -e "papers/$paper"
test ! -e "papers/$paper.lean"
printf 'Upstream replay revision: %s\n' "$pin"
printf 'Student snapshot: %s\n' "$(git -C "$root" rev-parse HEAD)"
cp -a "$root/lean" "papers/$paper"
diff -qr "$root/lean" "papers/$paper"
printf 'import %s.PaperInterface\nimport %s.ProofInterface\nimport %s.MainTheorems\n' "$paper" "$paper" "$paper" > "papers/$paper.lean"
printf '\n[[lean_lib]]\nname = "%s"\nsrcDir = "papers"\n' "$paper" >> lakefile.toml
lake exe cache get
python3 scripts/paper_contribution.py check "$paper" --fast
printf 'PAPER_CONTRIBUTION_FAST_EXIT=0\n'
lake build "$paper"
printf 'AML_BUILD_EXIT=0 (historical proof hole allowed)\n'
diff -qr "$root/lean" "papers/$paper"
