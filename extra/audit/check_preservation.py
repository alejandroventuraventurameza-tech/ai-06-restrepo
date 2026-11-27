"""Keep AML output and handwritten work frozen, except the ignored trace."""
import subprocess
BASE = "e43c3879c8d176649ee9549be435343b848b9c52"
ALLOWED = {"lean/.review_traces/proposition3-preflight.txt"}
def git(*args):
    return subprocess.check_output(["git", *args], text=True)
changes = set(git("diff", "--name-only", BASE, "HEAD", "--", "lean", "hand").splitlines())
assert changes == ALLOWED, changes
status = git("diff", "--name-status", BASE, "HEAD", "--", "lean", "hand").strip()
assert status == "D\tlean/.review_traces/proposition3-preflight.txt", status
print("Historical AML and hand files unchanged; only the upstream-ignored review trace removed.")
