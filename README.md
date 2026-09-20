# AI-Native Spring Boot Starter

A template Spring Boot project structured specifically to make **AI-assisted
development fast and token-efficient** — for Claude Code, and (with slightly
less automatic enforcement) any other coding agent that can read files, write
files, and run shell commands.

It is two things at once, and both are real:

1. A **working, runnable Spring Boot skeleton** (`pom.xml`, a REST endpoint,
   a passing test) you can build on immediately.
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
mvn test                     # run the test suite
mvn spring-boot:run          # run it locally — GET /api/v1/info
mvn clean package            # produce the runnable fat jar
```

```bash
curl http://localhost:8080/api/v1/info
# {"name":"ai-native-spring-starter","version":"0.1.0-SNAPSHOT","status":"UP"}
```

## What's in here

| Path | What it is |
|---|---|
| `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` | Tool-neutral entry point + tool-specific pointers to it |
| `docs/00-roles-and-responsibilities.md` | The four personas, what each owns |
| `docs/01-po-requirements.md` | PRD template, seeded with one worked example (`REQ-001`) |
| `docs/02-techlead-design.md` | Design doc template, seeded with the matching design (`DES-001`) |
| `docs/03-spec-driven-development-playbook.md` | The process itself: IDs, resume protocol, propose-new-work protocol |
| `docs/04-new-requirement-intake.md` | Exactly what to type for a new request |
| `docs/05-ai-native-development-guide.md` | **Why this structure is token-efficient**, and how to use each native AI capability it wires up |
| `traceability/TRACEABILITY_MATRIX.md` | Per-requirement: what design, what code, what test covers it, right now |
| `tracker/PROJECT_TRACKER.md` | The append-only history, with real command evidence |
| `.claude/agents/*.md` | Claude Code subagents — one per persona, tool-restricted to match its role |
| `.claude/commands/*.md` | `/new-requirement`, `/resume-project` — saved prompts for the two protocols above |
| `.claude/settings.json` | A permission allowlist for the commands this process runs constantly, so approval prompts don't eat a turn every time |
| `src/main/java/...` | The worked example: a minimal `GET /api/v1/info` endpoint |

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
