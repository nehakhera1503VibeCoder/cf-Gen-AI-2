# CLAUDE.md

@AGENTS.md

The above is this repo's tool-neutral entry point — read it in full before
doing anything else. Everything below is Claude Code–specific: how this
session gets *stronger enforcement* of the same rules, not a different
process.

## Claude Code–specific enforcement

- **Subagents** (`.claude/agents/*.md`) — one per persona, each with its
  own tool access matching `docs/00-roles-and-responsibilities.md`:
  `product-owner` (no `Bash` — can't run builds or touch code),
  `tech-lead`, `developer`, `qa-tester`. Invoke one directly with
  `@agent-<name>`, or let the commands below drive all four in sequence.
- **`/new-requirement <ask>`** (`.claude/commands/new-requirement.md`) —
  runs AGENTS.md's "starting new work" section end to end: PO → Tech Lead
  → Dev → QA, each in its subagent, each logging its own tracker/matrix
  rows.
- **`/resume-project`** (`.claude/commands/resume-project.md`) — runs
  AGENTS.md's resume protocol (§1's eight reads, then pick up at the
  tracker's next open item).
- **`.claude/settings.json`** — pre-approves the read-only and
  build/test commands this process runs constantly (`mvn compile`,
  `mvn test`, `git status`, etc.), so each one doesn't cost an approval
  round-trip. See `docs/05-ai-native-development-guide.md` §4.4.

These exist because Claude Code can enforce a persona's tool access from a
checked-in file; not every agent can. If you're a different tool reading
this same repo, `AGENTS.md` alone is the complete, working instructions —
these files are a bonus layer specific to Claude Code, not a prerequisite.
