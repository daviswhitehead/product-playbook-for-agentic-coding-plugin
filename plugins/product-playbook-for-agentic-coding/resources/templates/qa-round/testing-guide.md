# Your manual pass: [Project] QA round [N] (about [m] minutes)

<!-- projects/<state>/<project>/qa/round-<N>/testing-guide.md. Enforced by
     "${CLAUDE_PLUGIN_ROOT}"/scripts/check-testing-guide.sh (run it before sending):
       - every step table has #, Do, Expect and Agent test columns, and every step fills Agent test
         (how an agent tested it first, or "Nobody: <why>");
       - NO "after deploy" step here: those go in testing-guide-after-deploy.md, sent after the deploy;
       - at most 10 steps (the guard warns above that).
     Each step is concrete: the page, the exact control label, numbered sub-steps when there is more
     than one action, and the screen to expect. Never "test X" or "verify Y works". Name the device of
     each section: use his real device (from the founder taste file), not a guess. Delete this comment. -->

*[date]. Each step says what to do, what you should see, and how an agent already tested it. Everything here works on [the integration branch at <local URL> | production] today. After-deploy checks come separately, after the deploy.*

## 1. [Device and account, e.g. "iPad mini, Safari, signed in as you"] (about [m] min)

| # | Do | Expect | Agent test | Evidence |
|---|----|--------|------------|----------|
| P1 | 1. Open [exact place]. 2. Tap **[exact label]**. | [The screen you should see, in words you will recognize] | [Which pass, which environment, what it read: "Pass 3, iOS Simulator iOS 27 iPad mini: header stayed in view, scrollY 0"] | `[/abs/path/to/shot.png]` |
| P2 | [...] | [...] | Nobody: [why no agent could test it, e.g. "needs your real memories"] | - |

## Not in this guide, and why

- [Steps an agent fully covered, with the evidence, so he knows they were not skipped.]
