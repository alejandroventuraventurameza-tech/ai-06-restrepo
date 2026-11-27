"""Audit specific proof endpoints and reject sorryAx or any nonstandard axiom."""
import re
import sys
from pathlib import Path
EXPECTED = {
    "productivity_sign", "productivity_eq_paper", "productivity_at_one",
    "both_technologies_raise_productivity", "printed_threshold_claim_false",
    "corrected_threshold", "Khat_lt_KUnder_iff", "hasDerivAt_lnWS",
    "automation_raises_wage_iff", "hypotheses_satisfiable",
    "normalizedGain_strictMonoOn", "normalizedGain_continuousOn",
    "ces_interior_root_iff", "ces_no_interior_root_negative", "ces_root_signs",
    "ces_productivity_scale", "ces_wage_normalization",
    "isoelastic_relative_price_order",
    "constrained_lower_price_order",
    "upper_price_order_iff",
    "boundary_equality_alone_insufficient",
    "ces_relative_price_derivative",
    "ces_dual_price_derivative",
    "ces_dual_weight_normalization",
    "solve_log_factor_prices",
}
ALLOWED = {"propext", "Classical.choice", "Quot.sound"}
s = Path(sys.argv[1]).read_text()
rows = re.findall(
    r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)", s, re.S
)
found = {name.rsplit(".", 1)[-1] for name, _ in rows}
assert len(rows) == len(EXPECTED) and found == EXPECTED, (found, EXPECTED)
for name, deps in rows:
    names = {a.strip() for a in deps.split(",") if a.strip()}
    assert names <= ALLOWED, (name, names - ALLOWED)
print(f"{len(rows)} audited theorem endpoints; only standard Lean foundations.")
