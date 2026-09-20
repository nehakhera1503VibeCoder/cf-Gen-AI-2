---
description: Resume in-flight work with no further briefing, per the playbook's resume protocol.
---

Resume this project. Follow
`docs/03-spec-driven-development-playbook.md` §5 (the resume protocol)
exactly — do not ask for a re-briefing, and do not re-derive project state
from the source code alone.

1. Read `CLAUDE.md` — orientation and hard rules.
2. Read every `docs/0N-*.md` in order (including
   `docs/05-ai-native-development-guide.md`).
3. Read `traceability/TRACEABILITY_MATRIX.md` — what's covered, what has a
   gap.
4. Read `tracker/PROJECT_TRACKER.md` end to end, paying particular
   attention to the last rows, the "Open Items / Blockers" section, and
   the "Phase Overview" checklist.
5. State, in one or two sentences, what you determined is next and in
   which persona — then resume there, using the matching subagent
   (`.claude/agents/*.md`), logging the same way every prior row did.

If "Open Items / Blockers" and the Phase Overview are both fully checked
off with no open items, say so plainly instead of inventing follow-on
work — offer `/new-requirement` for anything new instead.
