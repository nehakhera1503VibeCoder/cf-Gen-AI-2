---
description: Intake a new requirement and run it through the full PO -> Tech Lead -> Dev -> QA pipeline, logging every step.
argument-hint: <one or two sentences: what's needed and why>
---

A new requirement has come in:

> $ARGUMENTS

Follow `docs/03-spec-driven-development-playbook.md` §6 (the
propose-new-work protocol) and `docs/04-new-requirement-intake.md` exactly.
Do not ask the requester to restate context that already lives on disk —
read it yourself first.

Before anything else, read in order: `CLAUDE.md`,
`docs/00-roles-and-responsibilities.md`, `docs/01-po-requirements.md`,
`docs/02-techlead-design.md`, `docs/05-ai-native-development-guide.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md` (last rows + Open Items) — so the next unused
ID per prefix, the current architecture, and what's already built are all
known before drafting anything.

Then run the pipeline, staying strictly in one persona at a time (use the
matching subagent for each phase — `.claude/agents/product-owner.md`,
`.claude/agents/tech-lead.md`, `.claude/agents/developer.md`,
`.claude/agents/qa-tester.md` — rather than blending them):

1. **Product Owner**: draft the `REQ-XXX` requirement delta in
   `docs/01-po-requirements.md`, resolve what can be resolved, add the
   tracker row and a blank-columns traceability matrix row.
2. **Tech Lead**: draft the `DES-XXX` design delta in
   `docs/02-techlead-design.md`, naming any real design decision
   explicitly, break it into Dev stories, add the tracker row, fill in the
   matrix row's Design column.
3. **Developer**: implement each story with unit tests, one `DEV-XXX`
   tracker row per story, actually running `mvn compile`/`mvn test` and
   recording the real output. Fill in the matrix row's Implementation
   column.
4. **QA/Tester**: an independent full-stack verification pass with
   independently-derived expected values, one `TEST-XXX` row, actually
   running the full suite. Fill in the matrix row's Tests column.
5. **Tech Lead**: a build review (`TECHLEAD-XXX` row) confirming the
   shipped code matches the design delta, naming any deviation explicitly.
6. **Product Owner**: sign off (`PO-XXX` row) against the PRD's own
   acceptance criteria, using Dev/QA's recorded evidence — not "should
   work."

If the ask is genuinely ambiguous or contradicts existing scope, stop and
ask before drafting — don't guess and proceed silently.
