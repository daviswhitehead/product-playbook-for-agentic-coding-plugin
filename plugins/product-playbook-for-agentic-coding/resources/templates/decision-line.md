# Decision line (one per founder decision)

The one definition of the line every playbook surface appends when it puts a choice in front of the founder. Commands link here; don't restate it. Record each decision **when it is shown to him**, not reconstructed at the retro: a taste ledger and a stand-in can only learn from what was written down at the time.

## Shape

One JSON object per line, appended when the question is queued or shown:

```json
{"id":"Q2-1","stage":"qa-round","question":"…","options":["A: …","B: …"],"recommended":"A","category":"<category>","reversibility":"<reversibility>","shown_as":"rendered","blocking":false,"asked":"YYYY-MM-DD","answer":null,"answered":null,"images":["/abs/path/qa/round-2/shots/a.png","/abs/path/qa/round-2/shots/b.png"],"why":null,"why_basis":null}
```

- The first twelve fields are required, in this order. `images`, `why` and `why_basis` are optional (omit or `null`).
- `stage`: a discovery stage (`frame`, `options`, `prototype`, `prd`, `plan`), or `review`, `qa-round`, `delivery`, `packet`.
- `category`, `reversibility`, `shown_as`: the taste-ledger enums (the project's ledger README, or the defaults in [founder-taste.md](./founder-taste.md)). `blocking: true` means the next step cannot start without it. `recommended` is `null` if the agent only asked.
- `images`: what he was shown (repo-relative or absolute paths). **A rendered option always lists its screenshots**; `shown_as: "rendered"` with no `images` is a bug.
- When it settles, fill `answer` (his words, or exactly `default after 48 h`) and `answered` (date). Rewrite the file; it is small.

## Ids and files

| Source | Id | File |
|---|---|---|
| `/playbook:explore` | `D<NN>-<n>` (`NN` = stage number) | `<project>/discovery/decisions.jsonl` (the discovery runner's contract; don't move it) |
| `/playbook:review` | `R-<n>` | `<project>/decisions.jsonl` |
| `/playbook:qa-round` | `Q<round>-<n>` | `<project>/decisions.jsonl` |
| Delivery queue (`decisions-queue.md` during work) | `W-<n>` | `<project>/decisions.jsonl` |
| PR packet (merge plan, proof-of-completion, approval request) | `P<pr>-<n>` | `<project>/decisions.jsonl`; a PR outside any project: `docs/decisions.jsonl` |

`<n>` counts up within its prefix and is never reused. Only discovery uses `D<NN>-`; runners match that pattern. A decision that is also a queue row uses the same id in the queue's `#` column.

## When he answers

He answers with a pick, sometimes with a short reason after it ("B, simpler", "1B 3A, keep it quiet"). Put the pick in `answer` and the reason in `why` with `"why_basis":"stated"`. **Never ask him for a reason**; a decision without one is fine. Use `"inferred"` only for a reason drawn from his own words elsewhere in the same reply or thread (quote them in `why`), never from your recommendation.

## Stand-in

If the repo documents a stand-in predict command (for example in `docs/agent-context.md`), run it right after appending lines and before the founder sees them. Never read or show its output. Never read or write any `.stand-in/` folder: a recommendation that saw the prediction anchors him, and the score means nothing. An unattended `/playbook:explore` run leaves this to its scheduler.
