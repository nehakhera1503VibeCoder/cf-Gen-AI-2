# Spec-Driven Development Playbook

**Audience:** anyone (human or AI coding agent) continuing this project,
or replicating the pattern for a new one.
**Status:** Approved, Tech Lead
**Date:** 2026-09-20

## 1. The problem this solves

An AI coding session has no memory between conversations. Left unaddressed,
every new request either needs a giant prompt re-explaining the whole
system, or the AI re-derives decisions that were already made —
inconsistently, since nothing forces it to reuse the earlier answer. Both
failure modes also burn tokens: a giant re-briefing prompt costs tokens to
read every time, and re-derivation costs tokens re-exploring a codebase
that already had the answer written down.

This repo's fix: **the filesystem is the memory.** A session (or a person)
doesn't need the conversation history that produced this codebase — it
needs to read a fixed, small set of files, in order, and it has everything
a re-briefing would have given it, dated, attributed, and cross-referenced.
See `docs/05-ai-native-development-guide.md` for the full rationale behind
why this specific structure is the token-efficient one.

## 2. The four-part system

| Part | Answers | Who writes it | Changes how often |
|---|---|---|---|
| `docs/0N-*.md` (PRD, design) | **What** and **why**; **how** it's architected | PO (requirements), Tech Lead (design) | Rarely — amended by a dated delta, not rewritten |
| `traceability/TRACEABILITY_MATRIX.md` | **Where** each requirement lives: which design section, which code, which test | Tech Lead (created), everyone (kept current) | After every unit of work that touches a requirement |
| `tracker/PROJECT_TRACKER.md` | **What has actually happened**, in order, with proof | Every persona, after every unit of work | After every unit of work — append-only log |
| `AGENTS.md` (repo root) | **Where to start**, **what the rules are** — tool-neutral, read by Claude Code, Devin, and Copilot alike | Tech Lead | Rarely — it's the index, not the content |

The tracker and the traceability matrix are not the same thing and both
matter: the tracker is chronological (what happened, in what order, proven
how); the matrix is per-requirement (given `FR-1`, what design section,
what code, what test cover it, right now). Lose the tracker and you lose
the history. Lose the matrix and you can't answer "what would break if I
changed `FR-1`" without re-reading the whole codebase.

## 3. The persona discipline

See `docs/00-roles-and-responsibilities.md` for the full table (owns /
writes to / never does per persona, and the subagent each one maps to).
The short version: **Product Owner** (requirements, sign-off) → **Tech
Lead** (design, build review) → **Developer** (implementation + unit
tests) → **QA/Tester** (independent, full-stack verification). Never
blend two personas' output into one undifferentiated paragraph — that
turns the tracker into narration instead of a check on the work.

## 4. The ID convention

| Prefix | Persona | Example |
|---|---|---|
| `REQ-` | Product Owner (requirements) | `REQ-001` |
| `DES-` | Tech Lead (design) | `DES-001` |
| `DEV-` | Developer (implementation stories) | `DEV-01` |
| `TEST-` | QA/Tester (test rounds) | `TEST-01` |
| `TECHLEAD-` | Tech Lead (build/design reviews, after the initial design) | `TECHLEAD-01` |
| `PO-` | Product Owner (sign-offs, after the initial draft) | `PO-01` |
| `BP-` | Product Owner (business process entries, `docs/06-business-processes-and-domain-glossary.md`) | `BP-001` |

Rules:
- **Never reuse or renumber an ID.** The next one of a given prefix is
  always the next integer, whenever that work happens. Renumbering breaks
  every cross-reference (javadoc, the matrix, other tracker rows) that
  cites it.
- **One row per unit of work.** A session that completes five stories
  writes five rows, not one bundled row.
- **The Notes column carries proof, not intent.** "`mvn test` → 3/3
  pass" belongs in a `Complete` row. "Will add tests" does not — that row
  is `In Progress`, not `Complete`.
- **Every `REQ-` row gets a `traceability/TRACEABILITY_MATRIX.md` row the
  same session it's drafted**, even before design/dev/test exist for it
  (those columns start empty and fill in as the work happens).

## 5. The resume protocol

Given "continue the project" (or `/resume-project` in Claude Code, see
`.claude/commands/resume-project.md`) and nothing else:

1. Read `AGENTS.md` (`CLAUDE.md` imports it automatically in Claude Code)
   — orientation and hard rules.
2. Read every `docs/0N-*.md` in order (including
   `docs/05-ai-native-development-guide.md` — it's rationale, not
   optional background).
3. Read `traceability/TRACEABILITY_MATRIX.md` — what's covered, what has a
   gap.
4. Read `tracker/PROJECT_TRACKER.md` end to end, especially the last rows,
   "Open Items / Blockers", and the phase checklist.
5. Resume at the next open item, in the correct persona, logging the same
   way every prior row did.

## 6. The propose-new-work protocol — this is the "simple prompt" mechanism

This is what makes "add an echo endpoint" or "add a notes resource" work as
a two-sentence ask instead of a re-briefing. See
`docs/04-new-requirement-intake.md` for the literal intake template and
`.claude/commands/new-requirement.md` for the command that runs it.

1. A human states the *what* and *why*, briefly. That's the entire input.
2. **Product Owner** subagent drafts a PRD delta: if the ask describes a
   real-world business process (a stakeholder, a trigger/schedule,
   business rules — not just "the system does X"), a `BP-XXX` entry in
   `docs/06-business-processes-and-domain-glossary.md` first, then a new
   `REQ-XXX` tracker row, a new/amended section in
   `docs/01-po-requirements.md` (cross-referencing the `BP-XXX` id if one
   was added), and a new `traceability/TRACEABILITY_MATRIX.md` row for it.
3. **Tech Lead** subagent drafts the design delta: a `DES-XXX` row, a new
   section in `docs/02-techlead-design.md` naming what's reused vs. new
   and any real design decision explicitly (not improvised mid-code), and
   fills in the matrix row's Design column.
4. **Developer** subagent implements it story by story, each with its own
   `DEV-XXX` row and unit tests, filling in the matrix row's
   Implementation/Tests columns as it goes.
5. **QA/Tester** subagent runs an independent verification pass (`TEST-XXX`
   row) with its own, independently-derived expected values — not values
   copied from the implementation.
6. **Product Owner** signs off (`PO-XXX` row) against the PRD's own
   acceptance criteria.

**Optional variant — a standalone spec file.** Steps 2-3 above default to
appending delta sections to `docs/01-po-requirements.md` and
`docs/02-techlead-design.md`. If the requirement is large, or you want it
as its own reviewable artifact instead of a section buried in a growing
PRD, you can ask for it to be written as a single standalone file instead:
`specs/SPEC-XXX-<short-slug>.md`, copied from `specs/TEMPLATE-spec.md`.
This has to be asked for explicitly — it's not the default, and it's not
retroactive (an existing requirement already in `docs/01`/`docs/02` stays
there). See `specs/README.md` for exactly what changes and what doesn't:
the persona ownership, the tracker rows, and the matrix all work
identically either way — only where the requirement/design text itself
lives changes.

For a well-understood, small change it's reasonable for one session to
move through all four persona hats in sequence rather than pausing for
approval at each gate — but every artifact still gets written in that
persona's voice and still gets logged. The discipline is in the record,
not in how many separate conversations it takes to produce it.

## 7. Copy-paste templates

**New tracker row:**
```
| <PREFIX>-<NN> | <YYYY-MM-DD> | <Persona> | <one-line description> | `<artifact path>` | <Drafted\|In Review\|Approved\|In Progress\|Complete\|Blocked> | <real evidence: command run + actual output> |
```

**New traceability row:**
```
| <REQ-ID> | <one-line requirement> | <DES-ID + doc section> | <DEV-ID + files> | <TEST-ID + test files> | <Not Started\|In Progress\|Done> |
```

**New PRD delta section** (append to `docs/01-po-requirements.md`):
```markdown
## <N>. <Feature Name> — Added <YYYY-MM-DD>

**Traces to:** `REQ-<NNN>` in the tracker

<What it does, in/out of scope, acceptance criteria — same structure as
the sections around it.>
```

**New design delta section** (append to `docs/02-techlead-design.md`):
```markdown
## <N>. <Feature Name> Architecture — Added <YYYY-MM-DD>

**Traces to:** `DES-<NNN>` in the tracker, `REQ-<NNN>` in the PRD

<What's reused, what's new, and any real design decision named and
justified explicitly.>
```

## 8. What this is not

This isn't process for its own sake. It's the specific answer to one
problem: an AI session (and, often, a human picking work back up weeks
later) has no memory, so the project needs one that lives on disk instead
of in someone's head — and reading disk state is cheaper, in tokens, than
re-deriving it. A team with shared context some other way doesn't need
this exact mechanism — but a project handed off between people and
between sessions does. See `docs/05-ai-native-development-guide.md` for
the token-efficiency case in full, and §9 below for running this on a
non-Claude agent.

## 9. Running this process from a different agent

Nothing here depends on Claude Code specifically. `AGENTS.md` is read
natively by Devin and by GitHub Copilot's coding agent; Copilot Chat in an
IDE uses `.github/copilot-instructions.md` as a thin pointer to it. The
only thing that changes on a non-Claude agent is enforcement: the
persona/tool-access split in `docs/00-roles-and-responsibilities.md` is a
hard restriction via `.claude/agents/*.md` in Claude Code, and a
convention to follow deliberately everywhere else. Everything else —
the ID convention, the tracker, the matrix, the resume and propose-new-work
protocols — works identically.
