# AI-Native Spring Boot Starter

A template Spring Boot project structured specifically to make **AI-assisted
development fast and token-efficient** — for Claude Code, and (with slightly
less automatic enforcement) any other coding agent that can read files, write
files, and run shell commands.

It is two things at once, and both are real:

1. A **working, runnable Spring Boot skeleton** (`pom.xml`, a real REST
   endpoint that generates a fixed-rate loan cashflow schedule, 11 passing
   tests) you can build on immediately.
2. A **spec-driven, multi-persona delivery process** — Product Owner → Tech
   Lead → Developer → QA — encoded as files on disk, so a fresh AI session
   (or a different person, weeks later) never has to be re-briefed from
   scratch, and never has to re-derive project state by re-reading the whole
   codebase.

Start here: **`AGENTS.md`**. It's the canonical, tool-neutral entry point —
read it in full before touching anything else. Then read
**`docs/05-ai-native-development-guide.md`** — that's the doc that explains
*why* this structure exists and how it keeps token spend down, which is the
whole point of this template.

## Quickstart

```bash
mvn compile                  # verify it builds
mvn test                     # run the test suite (11 tests)
mvn spring-boot:run          # run it locally
mvn clean package            # produce the runnable fat jar
```

```bash
curl -X POST http://localhost:8080/api/v1/cashflows/fixed-schedule \
  -H 'Content-Type: application/json' \
  -d '{"principal":1000,"annualInterestRate":0.12,"periodsPerYear":12,"numberOfPeriods":1}'
# {"principal":1000,"annualInterestRate":0.12,"periodsPerYear":12,"numberOfPeriods":1,
#  "periods":[{"periodNumber":1,"payment":1010.00,"interest":10.00,"principal":1000.00,"remainingBalance":0.00}]}
```

## What's in here

| Path | What it is |
|---|---|
| `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` | Tool-neutral entry point + tool-specific pointers to it |
| `docs/00-roles-and-responsibilities.md` | The four personas, what each owns |
| `docs/01-po-requirements.md` | PRD template, seeded with a worked example (`REQ-001`: fixed-rate cashflow generation) |
| `docs/02-techlead-design.md` | Design doc template, seeded with the matching design (`DES-001`) |
| `docs/03-spec-driven-development-playbook.md` | The process itself: IDs, resume protocol, propose-new-work protocol |
| `docs/04-new-requirement-intake.md` | Exactly what to type for a new request |
| `docs/05-ai-native-development-guide.md` | **Why this structure is token-efficient**, and how to use each native AI capability it wires up |
| `docs/06-business-processes-and-domain-glossary.md` | Index of business-process files + the shared domain glossary |
| `business-processes/README.md`, `business-processes/TEMPLATE-business-process.md` | **One file per business process** — stakeholders, triggers, business rules, workflow — that a technical `FR-` doesn't carry; seeded with an example (`BP-001`, not yet implemented) |
| `traceability/TRACEABILITY_MATRIX.md` | Per-requirement: what design, what code, what test covers it, right now |
| `tracker/PROJECT_TRACKER.md` | The append-only history, with real command evidence |
| `specs/README.md`, `specs/TEMPLATE-spec.md` | **Optional**: a standalone spec file per requirement, instead of appending to `docs/01`/`docs/02` — opt in per requirement, not a default |
| `.claude/agents/*.md` | Claude Code subagents — one per persona, tool-restricted to match its role |
| `.claude/commands/*.md` | `/new-requirement`, `/resume-project` — saved prompts for the two protocols above |
| `.claude/settings.json` | A permission allowlist for the commands this process runs constantly, so approval prompts don't eat a turn every time |
| `src/main/java/...` | The worked example: `POST /api/v1/cashflows/fixed-schedule`, a fixed-rate amortizing cashflow generator (`domain`/`service`/`api` layers) |

## Using this as a starting point for your own project

1. Read `docs/05-ai-native-development-guide.md` §6 — it walks through
   exactly what to replace (the worked example in `docs/01`/`docs/02`,
   the tracker, the matrix) and what to keep as-is (the process files, the
   subagents, the commands).
2. Rename the Maven coordinates in `pom.xml` and the base package
   (`com.example.starter`).
3. Once your first real requirement is drafted, everything else in this
   README still applies unchanged.

## Adding new work

```
/new-requirement <what you need, and why — one or two sentences>
```

On any agent other than Claude Code, just say the same thing in plain
language — `AGENTS.md` tells any session to run the same protocol either
way. See `docs/04-new-requirement-intake.md`.

By default the requirement/design text goes into `docs/01`/`docs/02`, same
as `REQ-001`. If you'd rather this one get its own file, say so in the
same prompt — see `specs/README.md`.
