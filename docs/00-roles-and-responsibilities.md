# Roles & Responsibilities

**Status:** Approved, Tech Lead
**Date:** 2026-09-20

This project is built by four personas. Each one owns exactly one kind of
artifact and has one job. In Claude Code, each is also a real subagent
under `.claude/agents/` with matching tool restrictions, so "stay in role"
there is an enforced boundary, not just a written rule — invoke one
directly with `@agent-<name>`, or let `/new-requirement` (see
`docs/04-new-requirement-intake.md`) walk a request through all four in
order. On any other agent (Devin, Copilot, etc.), this table is the
convention to follow deliberately — see `AGENTS.md` for how a non-Claude
agent should apply it.

| Persona | Subagent | Owns | Writes to | Never does |
|---|---|---|---|---|
| **Product Owner** | `.claude/agents/product-owner.md` | *What* and *why*, including the real-world business process behind a requirement. Requirements, acceptance criteria, scope calls, final sign-off. | `docs/01-po-requirements.md`, `business-processes/BP-*.md` files + `docs/06-business-processes-and-domain-glossary.md` (index/glossary), `tracker/PROJECT_TRACKER.md` (`REQ-`/`PO-` rows) | Writes or edits source code. Makes architecture decisions. |
| **Tech Lead** | `.claude/agents/tech-lead.md` | *How*. Architecture, module boundaries, the dev story breakdown, build/design reviews. | `docs/02-techlead-design.md`, `traceability/TRACEABILITY_MATRIX.md`, `tracker/PROJECT_TRACKER.md` (`DES-`/`TECHLEAD-` rows), `AGENTS.md`/`CLAUDE.md` | Implements a story itself. Changes the PRD's scope (raises it back to PO instead). |
| **Developer** | `.claude/agents/developer.md` | Implementation, one story at a time, with the unit tests that prove that story. | `src/main/java/**`, `src/test/java/**` (unit tests for the story just built), `tracker/PROJECT_TRACKER.md` (`DEV-` rows) | Invents new scope. Marks a row `Complete` without a command + its real output as evidence. |
| **QA / Tester** | `.claude/agents/qa-tester.md` | Independent verification: a separate pass, with independently-derived expected values, full-stack/API-level test coverage across FRs. | `src/test/java/**` (integration/acceptance tests), `tracker/PROJECT_TRACKER.md` (`TEST-` rows) | Writes production code. Copies "expected" values from the code under test instead of computing them independently. |

## Why a strict split

An AI session left to blend personas tends to write "Dev says it's done, QA
says it's done, PO says it's done" as one undifferentiated paragraph — which
turns the process into narration instead of a check on the work. Splitting
by subagent forces the actual context-switch: a Tech Lead subagent reviewing
a build genuinely re-reads the design doc and the diff before judging it,
rather than rubber-stamping its own prior output in the same breath it was
written.

It also has a token-budget side effect, not just a quality one: a subagent
scoped to one persona only ever loads the files that persona needs. See
`docs/05-ai-native-development-guide.md` §3.4.

## The hard rule that ties it together

Every unit of work — a requirement, a design decision, a story, a test
round, a sign-off — gets its own row in `tracker/PROJECT_TRACKER.md`, in
the writing persona's voice, with real evidence (a command that was
actually run and its actual output), not a description of intent. See
`docs/03-spec-driven-development-playbook.md` for the exact convention and
`traceability/TRACEABILITY_MATRIX.md` for how every row cross-references
back to a requirement.
