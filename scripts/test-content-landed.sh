#!/bin/bash
#
# test-content-landed.sh — Exercise content-landed.sh in a sandbox repo.
#
# WHY THIS EXISTS:
#   content-landed.sh answers "has this branch's content already reached main?" for
#   /playbook:merge-prs triage and /playbook:learnings Step A2. It shipped verified only
#   against single-commit refs and small files, and was wrong in BOTH directions:
#     - case 2: a branch whose tip commit only adds a changeset read as LANDED (#115)
#     - case 5: on a base file larger than the pipe buffer, `printf | grep -q` under
#       pipefail took SIGPIPE and reported found lines as missing, intermittently (#116)
#   Neither shape existed in the original fixtures. This builds each one on purpose.
#
# USAGE: scripts/test-content-landed.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${CONTENT_LANDED:-$REPO_ROOT/scripts/content-landed.sh}"
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
PASS=0; FAIL=0
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

expect() {  # expect <name> <want-exit> <ref> [runs]
    local name="$1" want="$2" ref="$3" runs="${4:-1}" got i
    for i in $(seq 1 "$runs"); do
        (cd "$SANDBOX/repo" && "$SCRIPT" "$ref" main >/dev/null 2>&1); got=$?
        if [ "$got" != "$want" ]; then
            echo -e "${RED}FAIL${NC} $name — run $i/$runs exited $got, want $want"
            FAIL=$((FAIL + 1)); return
        fi
    done
    echo -e "${GREEN}PASS${NC} $name"; PASS=$((PASS + 1))
}

cd "$SANDBOX" && git init -q -b main repo && cd repo
git config user.email t@t && git config user.name t
mkdir -p .changes docs
# Base file well past the 64 KiB pipe buffer, with the line case 5 looks for near the top.
{ echo "intro line"; echo "EARLY MATCH: the rule the branch re-adds"
  for i in $(seq 1 6000); do echo "filler line $i ................................................"; done; } > docs/big.md
echo "small base" > docs/small.md
git add -A && git commit -qm base

# 1. single commit, genuinely new content -> UNIQUE
git checkout -q -b one-commit main
echo "brand new rule" >> docs/small.md && git commit -qam "new rule"

# 2. new content, then a changeset-only tip commit -> UNIQUE (regression: #115)
git checkout -q -b changeset-tip main
echo "another new rule" >> docs/small.md && git commit -qam "content"
mkdir -p .changes && echo "changeset" > .changes/x.md && git add .changes/x.md && git commit -qm "changeset"

# 3. squash-landed: main gains the same lines by an unrelated commit -> LANDED
git checkout -q -b squashed main
echo "shipped rule" >> docs/small.md && git commit -qam "content"
mkdir -p .changes && echo "changeset" > .changes/y.md && git add .changes/y.md && git commit -qm "changeset"
git checkout -q main
echo "shipped rule" >> docs/small.md && git commit -qam "squash of squashed"

# 5. branch adds a line the large base already has, early in the file -> LANDED (regression: #116)
git checkout -q -b big-file main
echo "EARLY MATCH: the rule the branch re-adds" >> docs/big.md && git commit -qam "re-add"
git checkout -q main

expect "1 single-commit unique content is UNIQUE"         1 one-commit
expect "2 changeset-only tip does not hide content"       1 changeset-tip
expect "3 squash-landed content is LANDED"                0 squashed
expect "4 an ancestor of main is LANDED"                  0 main~1
expect "5 early match in a >64KiB base is stable LANDED"  0 big-file 15

echo "-------------------------------------------"
echo "content-landed: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
