# AGENTS.md

This is the entry point for **any** coding agent working in this
repository — Claude Code, Devin, GitHub Copilot (coding agent or Chat), or
anything else that reads this file. Read it first, then follow §1 before
doing anything else. Nothing here is tool-specific; it's plain
instructions and plain files any agent can read with normal file tools.

## What this project is

An **AI-native Spring Boot starter**: a small, real Spring Boot service
(currently one worked example: fixed-rate cashflow generation) that exists
to demonstrate — and
give you a ready-to-clone copy of — a **spec-driven, multi-persona
(Product Owner / Tech Lead / Developer / QA), token-efficient delivery
process** for building Java Spring services with an AI coding agent. Both
goals are real: it's a working skeleton, and it's a template for running
this process on any new project. See
`docs/05-ai-native-development-guide.md` for why this structure exists and
`tracker/PROJECT_TRACKER.md` for this project's complete, dated history.

## §1. Before doing anything: read these, in order

1. `docs/00-roles-and-responsibilities.md` — the four personas and what
   each owns. (A note on enforcement: this repo also ships Claude
   Code–specific subagents at `.claude/agents/*.md` that give Claude Code
   *hard* tool-restricted enforcement of each persona — e.g. the Product
   Owner subagent literally has no shell access. If you're a different
   agent without an equivalent mechanism, treat this document as the
   convention to follow deliberately instead.)
2. `docs/01-po-requirements.md` — the PRD. Binding scope and acceptance
   criteria.
3. `docs/02-techlead-design.md` — the architecture, package layout, and
   the design decisions named explicitly.
4. `docs/03-spec-driven-development-playbook.md` — the process: ID
   conventions, the resume protocol, the propose-new-work protocol,
   copy-paste templates. **Read this before creating any new tracker or
   matrix row.**
5. `docs/04-new-requirement-intake.md` — exactly what to type for a new
   request, and what happens automatically as a result.
6. `docs/05-ai-native-development-guide.md` — **read this even if you
   think you already know the process.** It's the rationale layer: why
   the structure above is what keeps an AI session's token spend down,
   and how to actually use the native capabilities (subagents, slash
   commands, permission allowlists) this repo wires up. Skipping it is
   how a session ends up doing the process by rote without getting the
   efficiency it exists for.
7. `docs/06-business-processes-and-domain-glossary.md` — the index of
   `business-processes/BP-*.md` files (one file per business process —
   see `business-processes/README.md`) plus the shared domain glossary.
   Each file carries the business narrative a technical `FR-` doesn't:
   who asked for it, what real-world event triggers it, what business
   rules govern it, what the domain terms mean. Check the index before
   drafting a requirement that serves a real-world process (a scheduled
   job, a report, a workflow with actual business stakeholders) — either
   it's already named there, or a new `BP-` file is owed alongside the
   new `REQ-`.
8. `traceability/TRACEABILITY_MATRIX.md` — per requirement, what design
   section, what code, and what tests cover it right now.
9. `tracker/PROJECT_TRACKER.md` — the actual history. Read end to end,
   especially the last rows, "Open Items / Blockers", and the "Phase
   Overview" checklist.

If asked to "continue the project" with no further detail, those nine
reads are the entire briefing needed — resume at whatever the tracker's
last state says is next, in the appropriate persona, logging the same way
every prior entry did. (Claude Code: `/resume-project` runs this for you.)

## Starting new work — works with any agent, no special syntax required

State the *what* and *why* in a sentence or two — that's the entire input
needed. Say it as plain language, e.g.:

> Follow the propose-new-work protocol in
> `docs/03-spec-driven-development-playbook.md` §6 for this requirement:
> add a `/api/v1/echo` endpoint that returns whatever text query param it's
> given.

Every agent reading this file can act on that sentence the same way: read
§1 above, then work the request through Product Owner → Tech Lead →
Developer → QA, in persona, logging each step exactly as
`docs/03-spec-driven-development-playbook.md` §6 and §7 describe. (Claude
Code: `/new-requirement <ask>` is a shortcut for typing this out — it is
not a different process, just a saved prompt.)

## Hard rules

- **Stay in persona.** Product Owner, Tech Lead, Developer, QA/Tester each
  own one kind of artifact and one job — see
  `docs/00-roles-and-responsibilities.md`. Don't blend two personas'
  output into one undifferentiated pass.
- **Keep the tracker updated.** Every unit of work gets its own row, with
  real verification evidence (a command actually run, its actual output),
  not a description of intent. `docs/03-spec-driven-development-playbook.md`
  §4 and §7.
- **Keep the traceability matrix current.** A new `REQ-` row without a
  matching `traceability/TRACEABILITY_MATRIX.md` row is a process defect —
  flag it in the next Tech Lead review, don't let it slide.
- **Actually run things.** `mvn compile` / `mvn test` / `mvn spring-boot:run`
  (or the packaged jar) — verify claims by executing them. A tracker row
  that says "implemented" without a command and its output is not
  following the convention.
- **New scope → new `REQ-`.** Don't improvise new behavior mid-implementation;
  follow the propose-new-work protocol (playbook §6) — even for a small
  ask, the artifacts still get written in each persona's voice and logged.
- **Manage tokens deliberately, not accidentally.** Read
  `docs/05-ai-native-development-guide.md` and follow its checklist (§7):
  targeted reads over whole-file reads, `Edit` over whole-file rewrites,
  batched independent tool calls, and no re-deriving state the tracker or
  matrix already records.

## Quick reference

```bash
mvn compile                  # verify it builds
mvn test                     # run the test suite
mvn spring-boot:run          # run it locally — POST /api/v1/cashflows/fixed-schedule
mvn clean package            # produce the runnable fat jar
java -jar target/ai-native-spring-starter-0.1.0-SNAPSHOT.jar   # run the packaged jar standalone
```

See `README.md` for the quickstart and a sample `curl` request.
