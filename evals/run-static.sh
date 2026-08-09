#!/usr/bin/env bash
#
# Static eval layer — deterministic regression checks for instruction files.
#
# Each fixture under evals/ pins load-bearing phrases (fixed-string match) to the command
# file it covers; the phrase encodes the fix for the fixture's cited incident, so a
# refactor that drops it reintroduces the documented regression. See evals/README.md.
#
# Output: TSV (fixture, type, status, detail) on stdout; summary on stderr.
# Exit 1 on any FAIL. Behavioral expectations are listed as SKIP — they belong to the
# LLM runner, not this script.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

python3 - evals plugins/product-playbook-for-agentic-coding <<'PY'
import os, re, sys

evals_dir, plugin_dir = sys.argv[1], sys.argv[2]
rows, failures = [], 0

for root, _, files in sorted(os.walk(evals_dir)):
    for fn in sorted(files):
        if not fn.endswith(".md") or fn == "README.md":
            continue
        path = os.path.join(root, fn)
        fixture = os.path.relpath(path, evals_dir)
        text = open(path).read()

        m = re.search(r'^command:\s*(\S+)', text, re.M)
        if not m:
            rows.append((fixture, "meta", "FAIL", "no 'command:' in frontmatter")); failures += 1
            continue
        target_rel = m.group(1)
        target = os.path.join(plugin_dir, target_rel)
        if not os.path.isfile(target):
            rows.append((fixture, "meta", "FAIL", f"target not found: {target}")); failures += 1
            continue
        target_text = open(target).read()

        statics = re.findall(r'^- static: (.+)$', text, re.M)
        behaviorals = re.findall(r'^- behavioral: (.+)$', text, re.M)
        if not statics and not behaviorals:
            rows.append((fixture, "meta", "FAIL", "fixture has no expectations")); failures += 1
            continue

        for pat in statics:
            pat = pat.strip().strip('`')
            if pat in target_text:
                rows.append((fixture, "static", "PASS", pat))
            else:
                rows.append((fixture, "static", "FAIL", f"phrase missing from {target_rel}: {pat}"))
                failures += 1
        for b in behaviorals:
            rows.append((fixture, "behavioral", "SKIP", b.strip()))

print("fixture\ttype\tstatus\tdetail")
for r in rows:
    print("\t".join(r))

n = lambda s: sum(1 for r in rows if r[2] == s)
print(f"# static: {n('PASS')} pass, {n('FAIL')} fail | behavioral (LLM runner): {n('SKIP')} pending",
      file=sys.stderr)
sys.exit(1 if failures else 0)
PY
