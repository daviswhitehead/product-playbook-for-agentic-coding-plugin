#!/bin/bash
#
# content-landed.sh — "Has this ref's content already reached the base branch?"
#
# WHY THIS EXISTS:
#   Under squash-merge, ancestry is a lie. `git merge-base --is-ancestor`,
#   `git log --not origin/main`, and `git branch --merged` all report a fully
#   landed branch as unmerged, because the squash commit shares no history with
#   the branch it replaced. Two commands in this plugin asked "did this land?"
#   the ancestry way and both got it wrong:
#
#     - /playbook:learnings Step A2 read four already-merged commits as
#       "stranded unpushed fixes" (4-of-4 false positives, measured 2026-09-16)
#       and opened PR #104 for content that shipped weeks earlier as #101.
#     - /playbook:merge-prs Step 2 triage then queued #104 as MERGE, because its
#       duplicate detection only compared open PRs to each other, never to main.
#
#   The repo's own learnings doc had established the rule for *branch sweeps*
#   back on 2026-07-27 ("compare file contents, not ancestry") — it just never
#   propagated to the two commands that needed it. This script is that rule,
#   executable, so the next command can point at it instead of restating it.
#
# USAGE:
#   scripts/content-landed.sh <ref> [base-ref]     # base defaults to origin/main
#
# EXIT CODES:
#   0  every added line is already present in base  -> LANDED (nothing unique)
#   1  some added lines are missing from base       -> UNIQUE content remains
#   2  usage / bad ref
#
# NOTE ON .changes/:
#   Changeset files are DELETED by scripts/release.sh once consumed, so their
#   absence from the base branch means "already released", not "not landed yet".
#   They are reported separately and never counted as unique content.

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

REF="${1:-}"
BASE="${2:-origin/main}"

if [ -z "$REF" ]; then
    echo "usage: $(basename "$0") <ref> [base-ref]" >&2
    exit 2
fi

git rev-parse --verify --quiet "$REF" >/dev/null   || { echo "bad ref: $REF" >&2; exit 2; }
git rev-parse --verify --quiet "$BASE" >/dev/null  || { echo "bad base: $BASE" >&2; exit 2; }

# Files the ref touches, relative to its own first parent. Using the ref's own
# diff (not ref...base) is deliberate: we want what this work ADDED, then we ask
# whether the base already says it.
FILES="$(git diff-tree --no-commit-id --name-only -r "$REF")"
[ -z "$FILES" ] && FILES="$(git diff --name-only "$BASE...$REF")"

if [ -z "$FILES" ]; then
    echo -e "${GREEN}LANDED${NC}: $REF touches no files vs $BASE"
    exit 0
fi

total_missing=0
changeset_note=""

while IFS= read -r f; do
    [ -z "$f" ] && continue

    case "$f" in
        .changes/*)
            changeset_note="${changeset_note}  ${f} (changeset — consumed by release, absence is expected)\n"
            continue
            ;;
    esac

    # Added lines this ref introduced for this file.
    added="$(git diff "$REF~1" "$REF" -- "$f" 2>/dev/null \
             | grep '^+' | grep -v '^+++' | sed 's/^+//' \
             | grep -v '^[[:space:]]*$')"
    [ -z "$added" ] && continue

    base_content="$(git show "$BASE:$f" 2>/dev/null)"
    if [ -z "$base_content" ]; then
        n=$(printf '%s\n' "$added" | wc -l | tr -d ' ')
        echo -e "${RED}UNIQUE${NC}  $f — absent from $BASE entirely ($n line(s))"
        total_missing=$((total_missing + n))
        continue
    fi

    miss=0; tot=0
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        tot=$((tot + 1))
        printf '%s\n' "$base_content" | grep -qF -- "$line" || miss=$((miss + 1))
    done <<< "$added"

    if [ "$miss" -eq 0 ]; then
        echo -e "${GREEN}landed${NC}  $f — all $tot added line(s) already in $BASE"
    else
        echo -e "${RED}UNIQUE${NC}  $f — $miss of $tot added line(s) missing from $BASE"
        total_missing=$((total_missing + miss))
    fi
done <<< "$FILES"

[ -n "$changeset_note" ] && printf "${YELLOW}changesets ignored:${NC}\n%b" "$changeset_note"

echo "-------------------------------------------"
if [ "$total_missing" -eq 0 ]; then
    echo -e "${GREEN}LANDED: $REF adds nothing $BASE does not already have.${NC}"
    echo "Ancestry may still say otherwise — squash-merge discards it. Trust this."
    exit 0
else
    echo -e "${RED}UNIQUE: $total_missing line(s) in $REF are not in $BASE.${NC}"
    exit 1
fi
