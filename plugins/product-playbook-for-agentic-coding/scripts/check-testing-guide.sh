#!/usr/bin/env bash
#
# Executable check for /playbook:qa-round founder testing guides.
#
#   "${CLAUDE_PLUGIN_ROOT}"/scripts/check-testing-guide.sh [file-or-dir ...]
#   (no args = every testing-guide*.md under ./projects, except projects/done/)
#
# Why this exists
# ---------------
# In one QA round a founder could not tell what to do for four of nineteen steps
# he was handed ("I don't know what I'm supposed to do for D6 or D7...", "G4/G5
# not sure how to test... I trust it's good enough"). All four were "after
# deploy" one-liners mixed into a guide he was running BEFORE the deploy, with no
# screen to expect. A step he cannot run is a step that silently did not happen.
#
# Checks, for every testing-guide*.md (templates: resources/templates/qa-round/):
#   1. Every step table (header row's first cell is "#") has an "Expect" column
#      and an "Agent test" column, and every step fills "Agent test". The
#      pre-tested rule: each step was agent-tested first, or says plainly that no
#      agent could test it ("Nobody: <why>").
#   2. A guide whose file name lacks "after-deploy" has no after-deploy step: no
#      step row that says "after deploy", and no step table under an
#      "after deploy" heading. Those go in testing-guide-after-deploy.md.
# Warns (does not fail) when a guide has more than 10 steps.
#
# Exits 1 on any FAIL, 0 otherwise. Ported from chef-chopsky
# scripts/check-testing-guide.sh (2026-10-10), made path-generic.

set -uo pipefail

MAX_STEPS="${TESTING_GUIDE_MAX_STEPS:-10}"
FILES=()

add_file() {
  case "$1" in
    projects/done/*|./projects/done/*|*/projects/done/*) return ;;
  esac
  case "$(basename "$1")" in
    testing-guide*.md) [ -f "$1" ] && FILES+=("$1") ;;
  esac
}

scan_dir() {
  while IFS= read -r f; do add_file "$f"; done < <(
    find "$1" -type f -name 'testing-guide*.md' -not -path '*/projects/done/*' -not -path 'projects/done/*' 2>/dev/null | sort
  )
}

if [ "$#" -gt 0 ]; then
  for a in "$@"; do
    if [ -d "$a" ]; then scan_dir "$a"; else add_file "$a"; fi
  done
elif [ -d projects ]; then
  scan_dir projects
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "Testing-guide check: no guides to check."
  exit 0
fi

FAILED=0
for f in "${FILES[@]}"; do
  is_after_deploy=0
  case "$(basename "$f")" in
    *after-deploy*) is_after_deploy=1 ;;
  esac

  out=$(awk -v file="$f" -v after_deploy_file="$is_after_deploy" -v max_steps="$MAX_STEPS" '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
    function split_row(line, cells,    n, i, s) {
      s = line
      gsub(/\\\|/, "\001", s)            # escaped pipes are cell text, not separators
      sub(/^[ \t]*\|/, "", s); sub(/\|[ \t]*$/, "", s)
      n = split(s, cells, "|")
      for (i = 1; i <= n; i++) cells[i] = trim(cells[i])
      return n
    }
    BEGIN { in_table = 0; step_table = 0; heading_after = 0; steps = 0 }
    /^#+[ \t]/ {
      heading_after = (tolower($0) ~ /after[- ]deploy/) ? 1 : 0
      in_table = 0
      next
    }
    /^[ \t]*\|/ {
      n = split_row($0, c)
      if (!in_table) {                   # header row of a new table
        in_table = 1; step_table = (c[1] == "#"); agent_col = 0; expect_col = 0
        if (step_table) {
          for (i = 1; i <= n; i++) {
            h = tolower(c[i])
            if (h ~ /agent test/) agent_col = i
            if (h ~ /^expect/) expect_col = i
          }
          if (!agent_col) printf "FAIL %s:%d: step table has no \"Agent test\" column\n", file, NR
          if (!expect_col) printf "FAIL %s:%d: step table has no \"Expect\" column (what the screen should show)\n", file, NR
          if (heading_after && !after_deploy_file)
            printf "FAIL %s:%d: step table under an \"after deploy\" heading; move it to testing-guide-after-deploy.md\n", file, NR
        }
        next
      }
      if ($0 ~ /^[ \t]*\|[ \t:|-]+$/) next  # separator row
      if (!step_table) next
      steps++
      id = c[1]
      if (agent_col) {
        cell = tolower(c[agent_col])
        if (cell == "" || cell == "-" || cell == "n/a" || cell == "tbd" || cell == "?")
          printf "FAIL %s:%d: step %s has no \"Agent test\" entry (say how an agent tested it, or \"Nobody: <why>\")\n", file, NR, id
      }
      if (!after_deploy_file && tolower($0) ~ /after[- ]deploy/)
        printf "FAIL %s:%d: step %s is an after-deploy step in a pre-deploy guide; move it to testing-guide-after-deploy.md\n", file, NR, id
      next
    }
    { in_table = 0 }
    END {
      if (steps > max_steps)
        printf "WARN %s: %d steps (at most %d concrete steps per guide; cut what an agent fully covered)\n", file, steps, max_steps
    }
  ' "$f")

  if [ -n "$out" ]; then
    printf '%s\n' "$out" | sed 's/^/  /'
    if printf '%s\n' "$out" | grep -q '^FAIL'; then FAILED=1; fi
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo ""
  echo "BLOCKED: a founder testing guide breaks the QA-round rules (resources/templates/qa-round/testing-guide.md)."
  exit 1
fi

echo "Testing-guide check passed (${#FILES[@]} guide(s): every step agent-tested or says why not; no after-deploy steps mixed in)."
