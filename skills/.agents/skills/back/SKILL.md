---
name: back
description: Return from AFK — deliver the brief from the decision log, then keep working attended.
disable-model-invocation: true
---

!`~/.claude/scripts/afk.sh off`

- If the output above is "Not AFK", relay that one line and stop.
- Otherwise it is the brief, assembled from the on-disk log — the source of truth even right after a compaction. Relay it as-is; light formatting touch-ups at most.
- Then, in this same turn, pick the in-progress work back up exactly where it stands — attended now, questions allowed again. Only if everything was already complete: say so and stop after the brief.
