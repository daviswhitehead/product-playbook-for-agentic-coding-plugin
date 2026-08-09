# Instruction Evals

Regression fixtures for the plugin's instruction files. This is the "ruler" from
`IMPROVEMENT.md`: an instruction edit must not regress these, and a claimed improvement
should move at least one. Without a before/after measure, instruction changes are
indistinguishable from accretion.

## How fixtures work

One fixture = one scenario a command must handle correctly, derived from a **real
incident** (the same friction-driven rule that governs instruction changes — no
speculative fixtures). Each fixture names its incident, describes the scenario, and lists
expectations of two types:

- **`- static:`** — a load-bearing phrase that must literally appear in the command file
  (checked with a fixed-string match by `run-static.sh`). These exist because the phrase
  encodes the fix for the cited incident: if a refactor drops it, the regression that
  incident documented is back. Deterministic, CI-able, zero LLM involvement.
- **`- behavioral:`** — an assertion about how an agent following the command would act
  in the scenario ("checks merge state *before* interpreting check results"). Scored by
  an LLM runner (a Claude session role-playing the scenario against the command file),
  binary pass/fail per assertion. Not yet wired into CI; the weekly improvement run
  scores these when proposing changes to a covered command.

Static checks are the floor, not the ceiling: they catch deletion/paraphrase-away of
known-critical guidance, and they cannot catch a rule that is present but buried or
contradicted. That's what the behavioral layer is for.

## Fixture format

```markdown
---
command: commands/workflows/<name>.md   # relative to the plugin directory
incident: <where this really happened — CHANGELOG version, repo, date, PR>
---

# Scenario: <one line>

<A few sentences: the situation the agent is in, what naive behavior looks like,
what the incident showed goes wrong.>

## Expectations

- static: <literal substring of the command file>
- behavioral: <binary assertion about the agent's behavior in this scenario>
```

## Running

```bash
evals/run-static.sh            # TSV to stdout, exit 1 on any static failure
evals/run-static.sh > evals/baselines.tsv   # refresh the committed baseline
```

`scripts/validate-plugin.sh` runs the static layer, so CI and the pre-commit checklist
get it for free.

**Behavioral runs**: give a Claude session the fixture and the command file, ask it to
role-play the scenario following the command's instructions, and score each behavioral
expectation pass/fail. Record results in the improvement PR that motivated the run (not
in baselines.tsv, which is static-only for determinism). On disagreement or uncertainty,
2-of-3 majority across independent sessions.

## Rules

- **Fixtures are guardrail files** (IMPROVEMENT.md rule 5): an autonomous improvement run
  may READ them and must RUN them, but may not edit or delete them. Weakening a fixture
  to make an edit pass is the one move that must always cross a human.
- **Editing a covered command?** If a static expectation legitimately needs rephrasing
  (the guidance moved, not died), update the fixture in the same human-reviewed PR and
  say why in the changeset.
- **Adding a fixture** requires a real incident citation. The CHANGELOG and
  `docs/learnings/` are the seed corpus.
