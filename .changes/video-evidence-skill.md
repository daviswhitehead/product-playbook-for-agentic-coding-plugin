---
plugin: product-playbook-for-agentic-coding
bump: minor
---

### Added
- **`video-evidence` skill.** Agents can now read videos and session replays. Encoded video (TikTok, YouTube, Loom, local recordings) goes through `/watch` (claude-video): timestamped frames plus a transcript, with guidance on choosing a detail level and pinning the local engine for private video. Session replays go through the analytics tool in a fixed order: metadata → event timeline → console logs → AI summary → pixels last. The skill also records the lesson that motivated it: a Replay Vision summary prompted about conversion left out a broken stream, five realtime errors and a 143s timeout, all sitting in that session's console log.
- `/playbook:debug` Step 0, `/playbook:research-synthesis`, `insight-extractor-agent` and `user-journey-testing` now point to the skill when a video or replay is the evidence.
