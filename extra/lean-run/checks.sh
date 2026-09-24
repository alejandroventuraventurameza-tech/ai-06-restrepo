#!/usr/bin/env bash
# Post-session checks for the AppliedModelingLib run (AR18RaceManMachine).
# Usage (from anywhere):
#   bash checks.sh <label>          e.g.  bash checks.sh session1
# Env var AML (optional): path to the AppliedModelingLib clone (default: ~/AppliedModelingLib)
# Output is shown on screen AND saved next to this script as checks-<label>.txt
set -u
LABEL="${1:-manual}"
AML="${AML:-$HOME/AppliedModelingLib}"
PAPER="papers/AR18RaceManMachine"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT="$HERE/checks-$LABEL.txt"

cd "$AML" || { echo "AppliedModelingLib not found at $AML (set AML=/path)"; exit 1; }
{
  echo "# checks: $LABEL  —  $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "# AppliedModelingLib commit: $(git rev-parse --short HEAD 2>/dev/null)"
  echo
  echo "## 1. abstract predicates (-> Prop / → Prop); every hit is reviewed by hand"
  grep -rnE "(->|→)[[:space:]]*Prop\b" "$PAPER" --include=*.lean || echo "(no hits)"
  echo
  echo "## 2. sorry / admit / axiom"
  grep -rnwE "sorry|admit|axiom" "$PAPER" --include=*.lean || echo "(no hits)"
  echo
  echo "## 3. lake build AR18RaceManMachine (last 40 lines)"
  lake build AR18RaceManMachine 2>&1 | tail -40
  echo "lake build exit code: ${PIPESTATUS[0]}"
  echo
  echo "## 4. paper_contribution check --fast"
  python3 scripts/paper_contribution.py check AR18RaceManMachine --fast 2>&1
  echo "check exit code: $?"
} 2>&1 | tee "$OUT"
echo
echo ">>> saved to $OUT"
