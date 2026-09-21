#!/usr/bin/env bash
# Scaffold a new AI-native, spec-driven Spring Boot project under any folder.
#
# Generates a blank instance of this template: AGENTS.md/CLAUDE.md, docs/00-06,
# specs/, business-processes/, traceability/, tracker/, .claude/agents +
# .claude/commands + settings.json, and a minimal runnable Spring Boot
# skeleton (pom.xml + one Application class) — parameterized by group ID,
# artifact ID, and base package. See docs/05-ai-native-development-guide.md
# in this repo for the rationale behind the structure this produces.
#
# Usage:
#   scaffold-project.sh <target-directory> [artifact-id] [group-id]
#
# Examples:
#   scaffold-project.sh ../claims-processing-service
#   scaffold-project.sh ../claims-processing-service claims-processing-service com.acme
#
# Flags:
#   --force        Write into an existing, non-empty target directory anyway.
#   --skip-build   Don't run `mvn compile`/`mvn test` after generating (both
#                  run by default, with real output, so "scaffolded" means
#                  "verified to build" — not just "files were written").

set -euo pipefail

FORCE=0
SKIP_BUILD=0
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
    --skip-build) SKIP_BUILD=1 ;;
    -h|--help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done
set -- "${POSITIONAL[@]+"${POSITIONAL[@]}"}"

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <target-directory> [artifact-id] [group-id] [--force] [--skip-build]" >&2
  exit 1
fi

TARGET="$1"
RAW_ARTIFACT_ID="${2:-$(basename "$TARGET")}"
GROUP_ID="${3:-com.example}"

# --- Derive names -----------------------------------------------------------

# artifact-id: lowercase, alnum + hyphens only, matching Maven convention.
ARTIFACT_ID="$(echo "$RAW_ARTIFACT_ID" | tr '[:upper:]' '[:lower:]' | tr -cs -- 'a-z0-9' '-' | sed 's/^-*//; s/-*$//')"
if [ -z "$ARTIFACT_ID" ]; then
  echo "Error: could not derive a valid artifact ID from '$RAW_ARTIFACT_ID'." >&2
  exit 1
fi

# base package: groupId + artifactId with separators stripped (Java package rules).
PACKAGE_SUFFIX="$(echo "$ARTIFACT_ID" | tr -d -- '-_')"
BASE_PACKAGE="${GROUP_ID}.${PACKAGE_SUFFIX}"
PACKAGE_PATH="$(echo "$BASE_PACKAGE" | tr '.' '/')"

# App class name: PascalCase(artifact-id) + "Application".
APP_CLASS="$(echo "$ARTIFACT_ID" | awk -F'-' '{ for (i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print }' OFS='')"

# Display title: Title Case(artifact-id) for headings.
PROJECT_TITLE="$(echo "$ARTIFACT_ID" | awk -F'-' '{ for (i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2) } print }' OFS=' ')"

TODAY="$(date +%Y-%m-%d)"

# --- Safety check ------------------------------------------------------------

if [ -e "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ] && [ "$FORCE" -ne 1 ]; then
  echo "Error: '$TARGET' already exists and is not empty." >&2
  echo "Pass --force to write into it anyway (existing files with the same name will be overwritten)." >&2
  exit 1
fi

mkdir -p "$TARGET"

echo "Scaffolding into: $TARGET"
echo "  artifactId   = $ARTIFACT_ID"
echo "  groupId      = $GROUP_ID"
echo "  basePackage  = $BASE_PACKAGE"
echo "  appClass     = ${APP_CLASS}Application"
echo

write_file() {
  local rel="$1"
  local full="$TARGET/$rel"
  mkdir -p "$(dirname "$full")"
  cat > "$full"
}

# =============================================================================
# Root files
# =============================================================================

write_file "AGENTS.md" <<'FILE'
# AGENTS.md

This is the entry point for **any** coding agent working in this
repository — Claude Code, Devin, GitHub Copilot (coding agent or Chat), or
anything else that reads this file. Read it first, then follow §1 before
doing anything else. Nothing here is tool-specific; it's plain
instructions and plain files any agent can read with normal file tools.

## What this project is

`__PROJECT_TITLE__` — a Spring Boot service built with a **spec-driven,
multi-persona (Product Owner / Tech Lead / Developer / QA), token-efficient
delivery process**. This scaffold starts blank: no requirements exist yet,
and that's the correct starting state — see
`docs/04-new-requirement-intake.md` for how the first one gets drafted.

## §1. Before doing anything: read these, in order

1. `docs/00-roles-and-responsibilities.md` — the four personas and what
   each owns. (A note on enforcement: this repo also ships Claude
   Code–specific subagents at `.claude/agents/*.md` that give Claude Code
   *hard* tool-restricted enforcement of each persona — e.g. the Product
   Owner subagent literally has no shell access. If you're a different
   agent without an equivalent mechanism, treat this document as the
   convention to follow deliberately instead.)
2. `docs/01-po-requirements.md` — the PRD. Binding scope and acceptance
   criteria. Currently empty — see its own header for what to do first.
3. `docs/02-techlead-design.md` — the architecture, package layout, and
   the design decisions named explicitly. Currently empty.
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
   commands, permission allowlists) this repo wires up.
7. `docs/06-business-processes-and-domain-glossary.md` — the index of
   `business-processes/BP-*.md` files (one file per real-world business
   process — see `business-processes/README.md`) plus the shared domain
   glossary. Empty until the first business process is drafted.
8. `traceability/TRACEABILITY_MATRIX.md` — per requirement, what design
   section, what code, and what tests cover it right now. Empty.
9. `tracker/PROJECT_TRACKER.md` — the actual history. Empty — Phase 0 is
   the next open item.

If asked to "continue the project" with no further detail: those nine
reads are the entire briefing needed. With an empty tracker, "next" means
Phase 0 — drafting the first requirement — via `/new-requirement` or the
propose-new-work protocol below. (Claude Code: `/resume-project` runs
this check for you.)

## Starting new work — works with any agent, no special syntax required

State the *what* and *why* in a sentence or two — that's the entire input
needed. Say it as plain language, e.g.:

> Follow the propose-new-work protocol in
> `docs/03-spec-driven-development-playbook.md` §6 for this requirement:
> <what's needed, and why>.

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
mvn spring-boot:run          # run it locally
mvn clean package            # produce the runnable fat jar
java -jar target/__ARTIFACT_ID__-0.1.0-SNAPSHOT.jar   # run the packaged jar standalone
```
FILE

write_file "CLAUDE.md" <<'FILE'
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
  AGENTS.md's resume protocol (§1's nine reads, then pick up at the
  tracker's next open item).
- **`.claude/settings.json`** — pre-approves the read-only and
  build/test commands this process runs constantly (`mvn compile`,
  `mvn test`, `git status`, etc.), so each one doesn't cost an approval
  round-trip. See `docs/05-ai-native-development-guide.md` §4.4.

These exist because Claude Code can enforce a persona's tool access from a
checked-in file; not every agent can. If you're a different tool reading
this same repo, `AGENTS.md` alone is the complete, working instructions —
these files are a bonus layer specific to Claude Code, not a prerequisite.
FILE

write_file ".github/copilot-instructions.md" <<'FILE'
# Copilot Instructions

This repository's actual agent instructions live in **`AGENTS.md`** at the
repository root — read that file in full, then follow its §1, before doing
anything else.

This file exists only because GitHub Copilot Chat sessions in an IDE don't
always pick up `AGENTS.md` by default (the Copilot coding agent does read
`AGENTS.md` natively and needs no pointer). Nothing is duplicated here —
if something about the process needs to change, change it in `AGENTS.md`.
FILE

write_file "README.md" <<'FILE'
# __PROJECT_TITLE__

An AI-native, spec-driven Spring Boot service. Start here: **`AGENTS.md`**
— the canonical, tool-neutral entry point. Then read
`docs/05-ai-native-development-guide.md` for why this structure exists.

## Quickstart

```bash
mvn compile                  # verify it builds
mvn test                     # run the test suite
mvn spring-boot:run          # run it locally
mvn clean package            # produce the runnable fat jar
```

## What's in here

| Path | What it is |
|---|---|
| `AGENTS.md` / `CLAUDE.md` / `.github/copilot-instructions.md` | Tool-neutral entry point + tool-specific pointers to it |
| `docs/00-roles-and-responsibilities.md` | The four personas, what each owns |
| `docs/01-po-requirements.md` | PRD — empty; drafted requirement by requirement |
| `docs/02-techlead-design.md` | Design doc — empty; drafted design by design |
| `docs/03-spec-driven-development-playbook.md` | The process itself: IDs, resume protocol, propose-new-work protocol |
| `docs/04-new-requirement-intake.md` | Exactly what to type for a new request |
| `docs/05-ai-native-development-guide.md` | Why this structure is token-efficient, and how to use each native AI capability it wires up |
| `docs/06-business-processes-and-domain-glossary.md` | Index of business-process files + the shared domain glossary |
| `business-processes/README.md`, `business-processes/TEMPLATE-business-process.md` | One file per real-world business process |
| `specs/README.md`, `specs/TEMPLATE-spec.md` | Optional: a standalone spec file per requirement instead of appending to `docs/01`/`docs/02` |
| `traceability/TRACEABILITY_MATRIX.md` | Per-requirement: what design, what code, what test covers it, right now |
| `tracker/PROJECT_TRACKER.md` | The append-only history, with real command evidence |
| `.claude/agents/*.md` | Claude Code subagents — one per persona, tool-restricted to match its role |
| `.claude/commands/*.md` | `/new-requirement`, `/resume-project` — saved prompts for the two protocols above |
| `.claude/settings.json` | A permission allowlist for the commands this process runs constantly |

## Adding the first (or next) requirement

```
/new-requirement <what you need, and why — one or two sentences>
```

On any agent other than Claude Code, just say the same thing in plain
language — see `docs/04-new-requirement-intake.md`.
FILE

write_file ".gitignore" <<'FILE'
target/
*.class
.idea/
*.iml
.vscode/
.DS_Store
FILE

write_file "pom.xml" <<'FILE'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.4</version>
    <relativePath/>
  </parent>

  <groupId>__GROUP_ID__</groupId>
  <artifactId>__ARTIFACT_ID__</artifactId>
  <version>0.1.0-SNAPSHOT</version>
  <name>__ARTIFACT_ID__</name>
  <description>
    AI-native, spec-driven Spring Boot service. See AGENTS.md and
    docs/05-ai-native-development-guide.md.
  </description>

  <properties>
    <java.version>21</java.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-test</artifactId>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
      </plugin>
    </plugins>
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>
  </build>
</project>
FILE

# =============================================================================
# .claude/
# =============================================================================

write_file ".claude/settings.json" <<'FILE'
{
  "permissions": {
    "allow": [
      "Bash(mvn compile)",
      "Bash(mvn compile:*)",
      "Bash(mvn test)",
      "Bash(mvn test:*)",
      "Bash(mvn clean package)",
      "Bash(mvn -q compile)",
      "Bash(mvn -q test)",
      "Bash(git status)",
      "Bash(git status:*)",
      "Bash(git diff)",
      "Bash(git diff:*)",
      "Bash(git log:*)"
    ]
  }
}
FILE

write_file ".claude/agents/product-owner.md" <<'FILE'
---
name: product-owner
description: Product Owner persona for this project. Use for anything that decides WHAT to build and WHY — drafting or amending requirements, resolving open questions, scope calls, and final sign-off against acceptance criteria. Use PROACTIVELY as the first step of any new-feature request, and as the last step before calling work done.
tools: Read, Grep, Glob, Edit, Write
---

You are the **Product Owner** for this project. You own requirements and
sign-off. You never write or edit source code, and you never make
architecture decisions — those are the Tech Lead's job; if a request
requires one, name it as an open question for the Tech Lead rather than
guessing.

## Before doing anything

Read, in order: `CLAUDE.md`, `docs/00-roles-and-responsibilities.md`,
`docs/01-po-requirements.md`, `docs/03-spec-driven-development-playbook.md`,
`docs/05-ai-native-development-guide.md`,
`docs/06-business-processes-and-domain-glossary.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md` (last rows + Open Items).

## What you own

- `docs/01-po-requirements.md` — the PRD: functional/non-functional
  requirements, scope, acceptance criteria, open questions and their
  resolutions. **Default location for a new requirement's requirements
  text** — see the optional alternative below.
- The Requirements section of a `specs/SPEC-XXX-*.md` file, **only when
  the requester explicitly asked for a standalone spec file** (see
  `specs/README.md`) — same content, same rules, different file.
- `business-processes/BP-<NNN>-*.md` files (one per process — see
  `business-processes/README.md`) and their index rows + the shared
  glossary in `docs/06-business-processes-and-domain-glossary.md`. Not
  every requirement needs one (a purely technical FR with no real-world
  stakeholder/trigger doesn't), but a requirement that serves an actual
  business process (a scheduled job, a report, a workflow with real
  stakeholders) does.
- `REQ-` and `PO-` rows in `tracker/PROJECT_TRACKER.md`.
- The `Description`/Status columns of new rows you add to
  `traceability/TRACEABILITY_MATRIX.md` (the Design/Implementation/Tests
  columns start empty — Tech Lead, Dev, and QA fill those in later).

## For a new requirement

1. First decide whether the ask describes a real-world business process
   (has a stakeholder, a trigger/schedule, business rules, a workflow —
   not just "the system does X") or a purely technical capability. If
   it's a business process:
   - Check `docs/06-business-processes-and-domain-glossary.md` §3 (the
     index) for an existing `BP-XXX` file it belongs to. If none exists,
     copy `business-processes/TEMPLATE-business-process.md` to
     `business-processes/BP-<NNN>-<short-slug>.md` (next unused number)
     and fill in owner/stakeholder, trigger, frequency, actors,
     inputs/outputs, and every business rule explicitly — don't leave
     one implicit for Dev to guess at later.
   - Add the new file's index row to `docs/06-...md` §3 in the same
     session.
   - Add any new domain term the file uses to the shared glossary
     (`docs/06-...md` §4) if it isn't already there.
2. Restate the ask as one or more numbered `FR-`/`NFR-` entries:
   - **Default:** append a new dated section to
     `docs/01-po-requirements.md`, in the same style as the existing ones
     (a single unambiguous sentence per requirement, testable).
   - **Only if explicitly asked for a standalone spec file:** copy
     `specs/TEMPLATE-spec.md` to `specs/SPEC-XXX-<short-slug>.md` and fill
     in its Requirements section instead — don't do both for the same
     requirement, and don't do this unasked (see `specs/README.md`).
   - If step 1 added a `BP-XXX` entry, reference its id here, and
     reference this `REQ-` back from the `BP-XXX` entry's Related
     Requirements field.
3. Note explicitly what's **out of scope** for this pass — don't let scope
   silently grow.
4. Resolve every open question you reasonably can, in writing, in the
   Open Questions section (wherever step 2 put it). Flag anything that's
   actually an architecture decision for the Tech Lead instead of
   resolving it yourself.
5. Add a `REQ-XXX` row to the tracker (next unused number for that prefix
   — never reuse or renumber), citing whichever file step 2 used, and a
   new row to the traceability matrix with the Design/Implementation/Tests
   columns left blank.
6. Hand off to the Tech Lead persona for the design delta.

## For sign-off

1. Read the actual delivered code/tests, and the tracker rows for the
   work being signed off — not just the plan.
2. Check off each acceptance criterion in `docs/01-po-requirements.md`
   against real evidence (an actual test result, an actual command
   output) already recorded in the tracker by Dev/QA — don't accept
   "should work."
3. Log a `PO-XXX` row with the outcome. If something doesn't meet
   criteria, the status is `Blocked`, with exactly what's missing named —
   not a soft pass.

## Never

- Edit anything under `src/`.
- Run `mvn` or any build/test command (that's Dev/QA's job — you review
  their recorded evidence, you don't generate it).
- Blend your voice with another persona's in the same tracker row.
FILE

write_file ".claude/agents/tech-lead.md" <<'FILE'
---
name: tech-lead
description: Tech Lead persona for this project. Use for anything that decides HOW to build something — architecture, module boundaries, the dev story breakdown, naming real design decisions explicitly, and reviewing a finished build against the design doc. Use after the Product Owner has drafted/amended a requirement, and again before Product Owner sign-off.
tools: Read, Grep, Glob, Edit, Write, Bash
---

You are the **Tech Lead** for this project. You own architecture and
design review. You never implement a story yourself, and you never change
the PRD's scope — if a design constraint means scope needs to shrink or
grow, raise it back to the Product Owner rather than deciding it yourself.

## Before doing anything

Read, in order: `CLAUDE.md`, `docs/00-roles-and-responsibilities.md`,
`docs/01-po-requirements.md`, `docs/02-techlead-design.md`,
`docs/03-spec-driven-development-playbook.md`,
`docs/05-ai-native-development-guide.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md`.

## What you own

- `docs/02-techlead-design.md` — architecture, package layout, API
  surface, named design decisions, the Dev story breakdown. **Default
  location for a new requirement's design text.**
- The Design section of a `specs/SPEC-XXX-*.md` file, **only when Product
  Owner used one for this requirement's Requirements section** (see
  `specs/README.md`) — never split one requirement across both a
  `docs/02` delta and a `specs/` file.
- `traceability/TRACEABILITY_MATRIX.md` — you create it (or add a row to
  it) the same session a `REQ-` is drafted, filling in the Design column
  as design work happens.
- `DES-` and `TECHLEAD-` rows in `tracker/PROJECT_TRACKER.md`.
- `AGENTS.md`/`CLAUDE.md` — you're the one who updates process rules if
  they need to change.

## For a new requirement's design delta

1. Read the new `REQ-XXX` — in `docs/01-po-requirements.md`, or in
   `specs/SPEC-XXX-*.md` if Product Owner used that instead — in full.
2. Add the design content in the **same file** the requirement used: a
   new section in `docs/02-techlead-design.md`, or the Design section of
   the same `specs/SPEC-XXX-*.md` file. Either way: what's reused from
   the existing codebase, what's genuinely new, and any real design
   decision named and justified explicitly — never leave one to be
   improvised mid-implementation.
3. Break the work into Dev stories (small enough each gets its own
   `DEV-XXX` row and its own unit tests).
4. Add a `DES-XXX` tracker row, and fill in the Design column of the
   matching traceability matrix row(s).
5. Hand off to the Developer persona.

## For a build review

1. Read the actual shipped code/tests — not the plan, not your own prior
   design doc from memory.
2. Confirm the implementation matches the design delta: package layout,
   named decisions, API surface. Name any deviation explicitly rather than
   silently accepting it.
3. Log a `TECHLEAD-XXX` row with the outcome.

## Never

- Implement a story yourself (that's Dev's job — you design and review,
  you don't write the feature).
- Silently expand or shrink the PRD's scope — raise it to Product Owner.
- Skip naming a real design decision because "it's obvious" — the next
  session reading this doc cold needs it stated, not implied.
FILE

write_file ".claude/agents/developer.md" <<'FILE'
---
name: developer
description: Developer persona for this project. Use to implement one Dev story at a time against an already-approved design, with the unit tests that prove that story, logging real command evidence. Use after the Tech Lead has broken a requirement into stories.
tools: Read, Grep, Glob, Edit, Write, Bash
---

You are the **Developer** for this project. You implement one story at a
time from `docs/02-techlead-design.md`'s story breakdown. You don't invent
new scope, and you don't grade your own work as done without a real
command and its real output to back it up.

## Before doing anything

Read, in order: `CLAUDE.md`, `docs/00-roles-and-responsibilities.md`,
`docs/01-po-requirements.md`, `docs/02-techlead-design.md` (especially the
story breakdown and any design decisions relevant to the story you're
picking up), `docs/05-ai-native-development-guide.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md` to see which stories are already done.

## What you own

- `src/main/java/**` for the story you're implementing.
- `src/test/java/**` unit tests that prove that story's own behavior.
- `DEV-` rows in `tracker/PROJECT_TRACKER.md`.
- The Implementation column of the matching
  `traceability/TRACEABILITY_MATRIX.md` row(s) — list the actual classes/
  methods you touched, not a paraphrase.

## Procedure, per story

1. Implement exactly what the design doc's story describes. If it turns
   out to need something the design doc didn't anticipate, that's a
   design gap — flag it for Tech Lead rather than silently improvising an
   API shape or a new dependency.
2. Write unit tests that exercise every success and failure branch named
   in the design doc's API surface table for this story (not just the
   happy path).
3. Actually run `mvn compile` and `mvn test`. Copy the real output
   (pass/fail counts) into the tracker row — not "tests written," not
   "should pass."
4. Log one `DEV-XXX` row per story (not one row per session covering
   several stories — split it).
5. Update the traceability matrix row(s) this story completes.
6. Prefer `Edit` for changes to a file that already exists; only `Write`
   a brand-new file or a change so pervasive that a full rewrite is
   genuinely clearer (see `docs/05-ai-native-development-guide.md` §5).

## Never

- Mark a row `Complete` without having actually run the command it cites.
- Touch a package another persona owns exclusively without being asked
  (e.g. don't rewrite `docs/02-techlead-design.md`'s architecture — flag
  the gap to Tech Lead instead).
- Bundle unrelated stories into one commit/row because it was convenient.
FILE

write_file ".claude/agents/qa-tester.md" <<'FILE'
---
name: qa-tester
description: QA/Tester persona for this project. Use for an independent verification pass after Dev claims a story or feature is done — full-stack/API-level tests with independently-derived expected values, not values copied from the implementation. Use before Tech Lead's build review and Product Owner sign-off.
tools: Read, Grep, Glob, Edit, Write, Bash
---

You are the **QA/Tester** for this project. You verify Dev's work
independently — you don't write production code, and you never copy
"expected" values straight from the implementation under test; you derive
them yourself from the requirement.

## Before doing anything

Read, in order: `CLAUDE.md`, `docs/00-roles-and-responsibilities.md`,
`docs/01-po-requirements.md`, `docs/02-techlead-design.md`,
`docs/05-ai-native-development-guide.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md` to see which `DEV-` rows are ready for
verification.

## What you own

- `src/test/java/**` integration/acceptance tests (full-stack or
  API-level — not unit tests duplicating Dev's own, unless a gap in
  Dev's coverage genuinely needs closing).
- `TEST-` rows in `tracker/PROJECT_TRACKER.md`.
- The Tests column of the matching `traceability/TRACEABILITY_MATRIX.md`
  row(s).

## Procedure, per verification round

1. Read the requirement (`docs/01-po-requirements.md`) directly — compute
   or state expected values from the requirement's own wording, not from
   reading the implementation's source.
2. Write or extend a full-stack test class exercising the feature through
   its real entry point (REST endpoint, service boundary — whatever the
   design doc's testing strategy specifies).
3. Actually run `mvn test` (the whole suite, not just your new class) and
   record the real pass/fail counts.
4. Cross-check `traceability/TRACEABILITY_MATRIX.md`: every FR/NFR the
   round covers should have both a unit test (Dev's) and a full-stack
   test (yours) listed, with no gap.
5. Log a `TEST-XXX` row with the outcome.

## Never

- Write or edit anything under `src/main/**`.
- Copy an "expected" value from the code under test instead of deriving it
  independently from the requirement.
- Sign off on a requirement (that's Product Owner's job — you provide the
  evidence PO signs off against).
FILE

write_file ".claude/commands/new-requirement.md" <<'FILE'
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
`docs/06-business-processes-and-domain-glossary.md`,
`traceability/TRACEABILITY_MATRIX.md`, and the tail of
`tracker/PROJECT_TRACKER.md` (last rows + Open Items) — so the next unused
ID per prefix, the current architecture, and what's already built are all
known before drafting anything.

Then run the pipeline, staying strictly in one persona at a time (use the
matching subagent for each phase — `.claude/agents/product-owner.md`,
`.claude/agents/tech-lead.md`, `.claude/agents/developer.md`,
`.claude/agents/qa-tester.md` — rather than blending them):

1. **Product Owner**: if the ask describes a real-world business process
   (a stakeholder, a trigger/schedule, business rules — not just "the
   system does X"), first add or update its own file —
   `business-processes/BP-<NNN>-<short-slug>.md` (from
   `business-processes/TEMPLATE-business-process.md`; see
   `business-processes/README.md`) — and its index row + any new
   glossary term in `docs/06-business-processes-and-domain-glossary.md`.
   Then draft the `REQ-XXX` requirement delta in
   `docs/01-po-requirements.md` — **unless the ask above explicitly
   requested a standalone spec file**, in which case use
   `specs/SPEC-XXX-<short-slug>.md` (copied from `specs/TEMPLATE-spec.md`)
   instead; see `specs/README.md`. Cross-reference the `BP-XXX` id from
   the requirement (and vice versa) if one was added. Resolve what can be
   resolved, add the tracker row and a blank-columns traceability matrix
   row, citing whichever file was used.
2. **Tech Lead**: draft the `DES-XXX` design delta in the **same file**
   step 1 used — a new section in `docs/02-techlead-design.md`, or the
   Design section of the same `specs/SPEC-XXX-*.md` file — naming any real
   design decision explicitly, break it into Dev stories, add the tracker
   row, fill in the matrix row's Design column.
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
FILE

write_file ".claude/commands/resume-project.md" <<'FILE'
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
work — offer `/new-requirement` for anything new instead. On a freshly
scaffolded project with an empty tracker, the next open item is always
Phase 0: drafting the first requirement.
FILE

# =============================================================================
# docs/
# =============================================================================

write_file "docs/00-roles-and-responsibilities.md" <<'FILE'
# Roles & Responsibilities

**Status:** Approved, Tech Lead
**Date:** __TODAY__

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
FILE

write_file "docs/01-po-requirements.md" <<'FILE'
# Product Requirements Document

**Status:** Drafted, Product Owner
**Date:** __TODAY__

## 1. Purpose

The binding scope and acceptance criteria for `__PROJECT_TITLE__`. This
file starts empty — draft the first requirement here via
`/new-requirement` (or the propose-new-work protocol,
`docs/03-spec-driven-development-playbook.md` §6) rather than writing
directly into it without a tracker row and a traceability matrix entry.

## 2. Scope

`<Fill in once the first requirement is drafted: what's in scope for this
project's current phase, and what's explicitly deferred.>`

## 3. Personas

See `docs/00-roles-and-responsibilities.md`.

## 4. Functional Requirements

`<FR- entries land here, one per numbered heading, each traced to a
REQ-XXX tracker row — see the "New PRD delta section" template in
docs/03-spec-driven-development-playbook.md §7.>`

## 5. Non-Functional Requirements

`<NFR- entries land here, same convention as §4.>`

## 6. Acceptance Criteria

`<Checkable criteria, added alongside the FRs/NFRs they belong to.>`

## 7. Open Questions

`<Anything unresolved. Resolve what Product Owner reasonably can, in
writing; flag anything that's actually an architecture decision for Tech
Lead instead.>`
FILE

write_file "docs/02-techlead-design.md" <<'FILE'
# Tech Lead Design

**Status:** Drafted, Tech Lead
**Date:** __TODAY__

## 1. Overview

`<Fill in once the first design delta is drafted: the overall shape of the
service, base package, and any framework-level choices.>`

Base package: `__BASE_PACKAGE__`.

## 2. Package layout

```
__BASE_PACKAGE__
└── __APP_CLASS__Application.java     # @SpringBootApplication entry point
```

Extend this as real requirements arrive: `domain/` for entities,
`repository/` for persistence interfaces, `service/` for business logic,
`api/` for controllers + DTOs, `config/` for `@ConfigurationProperties` —
introduced only once a requirement actually needs a layer, not
pre-created empty.

## 3. Design decisions

`<Every design delta names its real decisions explicitly here — rounding
rules, error-handling strategy, a chosen algorithm, whatever isn't
obvious from the code alone. Don't leave one to be improvised
mid-implementation.>`

## 4. API surface

`<Filled in per requirement — method, path, request, response, and the
FR/NFR it satisfies.>`

## 5. Dev story breakdown

`<DEV- stories land here as each requirement's design delta is drafted.>`

## 6. Testing strategy

`<Unit tests: what Dev proves, and how. Full-stack tests: what QA
independently re-derives and verifies, per
docs/00-roles-and-responsibilities.md's QA/Tester rule — not values
copied from the implementation.>`
FILE

write_file "docs/03-spec-driven-development-playbook.md" <<'FILE'
# Spec-Driven Development Playbook

**Audience:** anyone (human or AI coding agent) continuing this project,
or replicating the pattern for a new one.
**Status:** Approved, Tech Lead
**Date:** __TODAY__

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
See `docs/05-ai-native-development-guide.md` for the full rationale.

## 2. The four-part system

| Part | Answers | Who writes it | Changes how often |
|---|---|---|---|
| `docs/0N-*.md` (PRD, design) | **What** and **why**; **how** it's architected | PO (requirements), Tech Lead (design) | Rarely — amended by a dated delta, not rewritten |
| `traceability/TRACEABILITY_MATRIX.md` | **Where** each requirement lives: which design section, which code, which test | Tech Lead (created), everyone (kept current) | After every unit of work that touches a requirement |
| `tracker/PROJECT_TRACKER.md` | **What has actually happened**, in order, with proof | Every persona, after every unit of work | After every unit of work — append-only log |
| `AGENTS.md` (repo root) | **Where to start**, **what the rules are** — tool-neutral, read by Claude Code, Devin, and Copilot alike | Tech Lead | Rarely — it's the index, not the content |

The tracker and the traceability matrix are not the same thing and both
matter: the tracker is chronological (what happened, in what order, proven
how); the matrix is per-requirement (given a requirement, what design
section, what code, what test cover it, right now). Lose the tracker and
you lose the history. Lose the matrix and you can't answer "what would
break if I changed this requirement" without re-reading the whole
codebase.

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
| `BP-` | Product Owner (business process files, `business-processes/BP-<NNN>-*.md`, indexed in `docs/06-business-processes-and-domain-glossary.md`) | `BP-001` |

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
   way every prior row did. On a freshly scaffolded project this is
   Phase 0: drafting the first requirement.

## 6. The propose-new-work protocol — this is the "simple prompt" mechanism

This is what makes a two-sentence ask work instead of a re-briefing. See
`docs/04-new-requirement-intake.md` for the literal intake template and
`.claude/commands/new-requirement.md` for the command that runs it.

1. A human states the *what* and *why*, briefly. That's the entire input.
2. **Product Owner** subagent drafts a PRD delta: if the ask describes a
   real-world business process (a stakeholder, a trigger/schedule,
   business rules — not just "the system does X"), first its own
   `business-processes/BP-<NNN>-*.md` file (`business-processes/README.md`)
   plus its index row in `docs/06-business-processes-and-domain-glossary.md`;
   then a new `REQ-XXX` tracker row, a new/amended section in
   `docs/01-po-requirements.md` (cross-referencing the `BP-` id if one
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
as its own reviewable artifact, ask for it to be written as a single
standalone file instead: `specs/SPEC-XXX-<short-slug>.md`, copied from
`specs/TEMPLATE-spec.md`. This has to be asked for explicitly — see
`specs/README.md`.

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
re-deriving it. See `docs/05-ai-native-development-guide.md` for the
token-efficiency case in full, and §9 below for running this on a
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
FILE

write_file "docs/04-new-requirement-intake.md" <<'FILE'
# New Requirement Intake

**Goal:** a new request should be a one- or two-sentence prompt. Everything
else it needs — the roles, the process, the current state of the project —
already lives in this repo and gets loaded automatically. This document is
what makes that true, and what to type.

## What to actually type

In Claude Code, use the slash command:

```
/new-requirement <what's needed, and why>
```

On any other agent (Devin, Copilot, plain chat), just say the same thing
in plain language — the same `docs/03-spec-driven-development-playbook.md`
§6 protocol is what `AGENTS.md` tells any session to follow for a
new-scope request either way; the slash command is a saved shortcut for
typing that out in Claude Code, at `.claude/commands/new-requirement.md`,
not a different process.

That one line is the entire input. You do not need to (and shouldn't) also
explain: what this project does, how the layers are structured, what the
persona roles are, or what tracker ID comes next. All of that is already on
disk and gets read before any work starts.

## Optional: as a standalone spec file instead

By default the requirement/design text is appended to
`docs/01-po-requirements.md`/`docs/02-techlead-design.md`. If you'd rather
this one get its own file — it's large, or you want it as its own
reviewable artifact — say so in the same prompt:

```
/new-requirement <what and why>. Write it as its own spec file, not a docs/01/02 delta.
```

See `specs/README.md` for what that changes (only where the
requirement/design text lives) and what it doesn't (the tracker, the
matrix, and the persona discipline are identical either way).

## If the requirement is a real-world business process

Some requirements are purely technical ("expose an endpoint that does
X"). Others exist to serve an actual business process — a scheduled job,
a report, a workflow with a real stakeholder and business rules. If
yours is the second kind, say so, and it gets **its own file**,
`business-processes/BP-<NNN>-<short-slug>.md` (see
`business-processes/README.md`), as well as the usual `REQ-XXX` — that's
where the stakeholder, the trigger/schedule, the business rules, and any
domain terminology live, cross-referenced from the requirement rather
than folded into the FR text where it'd be lost the moment someone reads
the requirement in isolation. The new file gets an index row in
`docs/06-business-processes-and-domain-glossary.md` §3.

## What happens automatically, in order

1. **Context load.** The session reads `AGENTS.md` (via `CLAUDE.md`'s
   import in Claude Code, or directly in Devin/Copilot/other agents),
   which points at (and requires reading, in order)
   `docs/00-roles-and-responsibilities.md`, `docs/01-po-requirements.md`,
   `docs/02-techlead-design.md`, `docs/05-ai-native-development-guide.md`,
   `docs/06-business-processes-and-domain-glossary.md`, this file,
   `traceability/TRACEABILITY_MATRIX.md`, and
   `tracker/PROJECT_TRACKER.md`. Nothing about your one-line ask needs to
   restate any of that.
2. **Product Owner pass**: if it's a business process, adds/updates its
   own `business-processes/BP-<NNN>-*.md` file and its index row; drafts
   a `REQ-XXX` row and a PRD delta, resolves any open question it can,
   flags any it can't.
3. **Tech Lead pass**: drafts a `DES-XXX` row and a design delta — what's
   reused, what's new, any real decision named explicitly.
4. **Developer pass**: implements it story by story, `DEV-XXX` rows, unit
   tests per story, actually running `mvn compile`/`mvn test`.
5. **QA/Tester pass**: independent full-stack verification, `TEST-XXX` row,
   with its own hand-derived expected values.
6. **Sign-off**: Product Owner reviews the actual delivered behavior
   against the PRD's acceptance criteria and logs `PO-XXX`.
7. **Traceability updated throughout** — the matrix row for the new `REQ-`
   gets its Design/Implementation/Tests columns filled in as steps 3-5
   happen, not retrofitted afterward.

## Resuming instead of starting new work

If instead you want to pick up in-flight work with no further detail, say
so (or use `/resume-project` in Claude Code,
`.claude/commands/resume-project.md`) — that follows
`docs/03-spec-driven-development-playbook.md` §5 instead: read the same
files, then resume at whatever the tracker's last rows and "Open Items"
section say is next, in the same persona, logging the same way. On a
freshly scaffolded project, that's Phase 0.

## Why a one-liner is enough

Every piece of context a human would otherwise have to restate is durable,
on-disk state, not conversation history:

- **"What does this system do"** → `docs/01-po-requirements.md`.
- **"How is it built"** → `docs/02-techlead-design.md`.
- **"Who does what"** → `docs/00-roles-and-responsibilities.md` — enforced
  by hard tool restrictions in Claude Code (`.claude/agents/*.md`), by
  convention on any other agent.
- **"What's already done, and what's next"** → `tracker/PROJECT_TRACKER.md`.
- **"What covers requirement X, and is it fully covered"** →
  `traceability/TRACEABILITY_MATRIX.md`.

A fresh session — or a different person entirely — reading those things has
the same picture as anyone who was in the room for every prior decision,
at a fraction of the token cost of a conversational re-briefing. See
`docs/05-ai-native-development-guide.md` for why that's true in detail.
FILE

write_file "docs/05-ai-native-development-guide.md" <<'FILE'
# AI-Native Development Guide

**Status:** Approved, Tech Lead
**Date:** __TODAY__
**Audience:** anyone using this project — the reason the rest of `docs/`
is structured the way it is.

## 1. Why this doc exists

Every other doc in this repo describes *what* the process is. This one
explains *why* it's shaped this way: this whole layout is a response to
one fact — an AI coding agent has no memory between sessions, and every
token it spends re-deriving something that was already known is a token
that didn't go toward the actual work. Done right, a well-kept written
record is *both* the correctness mechanism and the token-efficiency
mechanism.

## 2. Where tokens actually go, unmanaged

- **Re-deriving project state from source, every session.** With no
  tracker, "what's already built and what's next" can only be answered by
  reading most of the codebase, every time someone picks the project back
  up.
- **Open-ended exploration instead of a fixed read-list.** "Figure out
  what's going on here" costs many speculative `Grep`/`Read` round trips
  that a five-item ordered reading list would have replaced with five
  direct reads.
- **One giant document instead of several small ones.** If requirements,
  design, and process were one file, every persona would load context
  irrelevant to its own job on every read.
- **Blended personas.** A single undifferentiated pass that tries to be
  PO, Tech Lead, Dev, and QA at once keeps all four roles' concerns live
  in one context window at once.
- **No evidence discipline.** A tracker row that says "should work"
  invites a later session to not trust it, and re-verify from scratch.
- **Whole-file rewrites for small changes.** Sending an entire file back
  through the model to change three lines costs roughly the size of the
  file, twice, for a three-line diff.
- **Serial tool calls with no dependency between them.** Every avoidable
  round trip adds fixed overhead on top of whatever the call itself costs.

## 3. The structural fixes — why this repo is laid out this way

### 3.1 Filesystem as memory

`tracker/PROJECT_TRACKER.md` and `traceability/TRACEABILITY_MATRIX.md`
exist so "what's done, what's next, what covers requirement X" are
**lookups**, not investigations.

### 3.2 A fixed, ordered resume-read list

`docs/03-spec-driven-development-playbook.md` §5 names exactly which files
to read, in what order, for "continue the project."

### 3.3 Small, single-purpose docs, split by persona

Requirements, design, process, and this guide are four different files on
purpose. A Developer subagent implementing a story needs
`docs/02-techlead-design.md`; it does not need to re-read the Product
Owner's open-questions log every time.

### 3.4 Persona-scoped subagents = persona-scoped context

`.claude/agents/*.md` gives each persona its own subagent with its own
restricted tool list. A Product Owner pass literally cannot open a shell
and start exploring the whole codebase — it's confined to the handful of
docs its job requires, by construction.

### 3.5 Evidence discipline kills verification loops

A tracker row that cites the actual `mvn test` output doesn't need to be
re-verified by the next session.

### 3.6 The propose-new-work protocol bounds scope drift

Naming new scope explicitly, every time, keeps the docs able to answer
"why does the code do this" without re-deriving it from git blame.

## 4. Native AI capabilities this repo wires up (Claude Code)

### 4.1 Subagents (`.claude/agents/*.md`)

Each persona is a real subagent with a `tools:` allowlist in its
frontmatter — the enforcement behind "Product Owner never writes code."

### 4.2 Slash commands (`.claude/commands/*.md`)

`/new-requirement <ask>` and `/resume-project` are saved prompts — the
entire multi-step protocol, written once, invoked by name.

### 4.3 The `AGENTS.md` / `CLAUDE.md` dual-file convention

`CLAUDE.md` is one line (`@AGENTS.md`) plus Claude Code–specific notes.
Claude Code auto-loads `CLAUDE.md` at session start.

### 4.4 `.claude/settings.json` permission allowlist

Pre-approves exactly the commands this process runs constantly
(`mvn compile`, `mvn test`, `git status`) and nothing wider.

### 4.5 Hooks (optional — not wired up by default here)

Claude Code supports hooks for things like "remind me if I'm about to end
a turn without a tracker update." Not wired up by default, to keep the
starting point minimal — the natural next capability to add if tracker
updates start getting skipped.

## 5. Engineering habits that cut tokens regardless of tool

- **`Grep`/`Glob` before `Read`.**
- **Read a known range**, not a whole large file, when you already know
  which part you need.
- **Prefer a targeted edit over a whole-file rewrite.**
- **Batch independent tool calls in one turn.**
- **Don't re-read a file you just wrote or edited "to confirm."**
- **Keep tracker rows and commit messages terse and evidentiary.**
- **Split a doc that's grown past what one persona needs for one job.**

## 6. Growing this project

Unlike a template with a worked example to replace, this scaffold starts
blank — there is nothing to strip out. Draft the first requirement via
`/new-requirement` (or manually per `docs/03-...md` §6), and everything
else follows the same discipline from there on: `docs/01`/`docs/02` grow
by dated delta sections, the tracker and matrix grow by row, and
`business-processes/`/`specs/` grow by file, only as each is actually
needed.

## 7. Token-budget checklist (quick reference)

Before doing a unit of work, ask:

- [ ] Am I about to read a whole file when I only need part of it?
- [ ] Am I about to re-derive something the tracker or matrix already
      records?
- [ ] Is the persona I'm acting as reading only what it owns, per
      `docs/00-roles-and-responsibilities.md`?
- [ ] Am I about to `Write` an entire file for a small change? Use `Edit`
      instead.
- [ ] Are the next few tool calls independent of each other? Batch them
      in one turn instead of going serial.
- [ ] Does the tracker row I'm about to write cite a real command and its
      real output — not a description of intent?
FILE

write_file "docs/06-business-processes-and-domain-glossary.md" <<'FILE'
# Business Processes & Domain Glossary

**Status:** Approved, Product Owner
**Date:** __TODAY__
**Owned by:** Product Owner (see `docs/00-roles-and-responsibilities.md`)

## 1. Why this doc exists

An `FR-`/`NFR-` entry in `docs/01-po-requirements.md` is a testable
statement about system behavior — "the system does X." It deliberately
doesn't carry: who in the business asked for it, what real-world event
triggers it, how often it runs, what business rules govern it, or what the
domain terms mean. That context lives in **its own file per business
process**, under `business-processes/` — not as sections in this doc.
This doc is the **index** (§3) and the **shared domain glossary** (§4).

## 2. How business processes are documented

- Each business process gets its own file:
  `business-processes/BP-<NNN>-<short-slug>.md`, copied from
  `business-processes/TEMPLATE-business-process.md`. See
  `business-processes/README.md` for the full convention.
- A business process file can exist **before** any `REQ-` implements it —
  a known future need, not yet built. Its Status field says
  `Not Implemented` explicitly so nobody mistakes documented intent for
  delivered behavior.
- Every process file names the `REQ-`/`FR-` id(s) that implement it, and
  a requirement that exists to serve a business process cites the `BP-`
  id back.
- This is Product Owner's territory (business "what and why"), same as
  `docs/01`. If a business rule turns out to require an architecture
  decision, that's Tech Lead's design doc's job to record — name it as a
  question for Tech Lead rather than deciding it here.

## 3. Business process index

Empty — add a row here in the same session any
`business-processes/BP-*.md` file is created or its status changes.

| ID | Name | Status | File | Related Requirements |
|---|---|---|---|---|
| | | | | |

## 4. Domain glossary

Shared across every business process file — a term goes here once,
referenced from any process (or requirement) that uses it, not redefined
inline every time.

| Term | Definition |
|---|---|
| | |

Add a term here the first time a business process file or requirement
uses it in a way that isn't self-explanatory from plain English.

## 5. Keeping this current

- Product Owner adds a new `business-processes/BP-<NNN>-*.md` file (from
  the template) in the same session a business process is identified,
  and adds its index row here (§3) at the same time.
- A requirement in `docs/01-po-requirements.md` (or a
  `specs/SPEC-XXX.md`) that exists to serve a real-world business process
  references the `BP-` id, rather than describing the technical behavior
  in isolation with the business reason left implicit.
- Neither this doc nor an individual `business-processes/BP-*.md` file
  gets a tracker row of its own for every edit — they're standing
  business context, not a per-unit-of-work deliverable — but a `REQ-` row
  that implements a `BP-` should say so in its Notes column, and both the
  process file's Status/Related-requirements fields and this doc's index
  row should be updated the same session.
FILE

# =============================================================================
# specs/ and business-processes/
# =============================================================================

write_file "specs/README.md" <<'FILE'
# Per-Requirement Spec Files (Optional)

**Default behavior is unchanged.** A new requirement's spec, by default,
is a dated delta section appended to `docs/01-po-requirements.md` (the
PRD, Product Owner's) and `docs/02-techlead-design.md` (the design, Tech
Lead's) — see `docs/03-spec-driven-development-playbook.md` §6. That's
what `/new-requirement` does automatically.

**This folder is an opt-in alternative for a single requirement**, not a
replacement for that default. Use it when a requirement is genuinely
better served by its own standalone file — usually because it's large,
because you want it as its own reviewable artifact, or because the PRD
has grown to where appending yet another delta section makes it harder to
read as a whole.

## How to use it

1. Ask for it explicitly: state the requirement and say you want it as a
   standalone spec file, e.g.:
   > Follow the propose-new-work protocol for this one, but write it as
   > its own `specs/` file instead of appending to `docs/01`/`docs/02`:
   > <what's needed, and why>.
2. Copy `specs/TEMPLATE-spec.md` to `specs/SPEC-<REQ-ID>-<short-slug>.md`
   — the next unused `REQ-` number, same rule as always
   (`docs/03-...md` §4: never reuse or renumber).
3. Fill it in following the same persona discipline as everywhere else in
   this repo: the Requirements section is Product Owner's, the Design
   section is Tech Lead's — co-located in one file for convenience, but
   still written and owned by the persona whose section it is.
4. Everything downstream is identical to the default path: a `REQ-XXX`
   tracker row, a traceability matrix row, `DEV-`/`TEST-`/`TECHLEAD-`/`PO-`
   rows as usual. The only difference is what the tracker row's Artifact
   column and the matrix row's Design column point at.

## What NOT to do

- Don't point a tracker or matrix row at *both* a `docs/01`/`docs/02`
  delta section *and* a `specs/` file for the same requirement.
- Don't retroactively convert an existing requirement into this format
  just because the option exists — only use it going forward, for a
  requirement where it's explicitly asked for.
- Don't use this as a way to skip the tracker or matrix.
FILE

write_file "specs/TEMPLATE-spec.md" <<'FILE'
<!--
Copy this file to specs/SPEC-<REQ-ID>-<short-slug>.md and fill it in. See
specs/README.md for when to use a standalone spec file instead of the
default docs/01/docs/02 delta-section convention, and
docs/03-spec-driven-development-playbook.md §6 for the propose-new-work
protocol this feeds into either way.

Delete this comment block once you start filling the file in for real.
-->

# `<Feature Name>` — `REQ-<NNN>`

**Status:** Drafted
**Date:** `<YYYY-MM-DD>`
**Traces to:** `REQ-<NNN>` in `tracker/PROJECT_TRACKER.md`

---

## Requirements (Product Owner)

*Owned by the Product Owner persona. What and why — not how.*

### Summary

`<One or two sentences: what's needed and why.>`

### Scope

**In scope:** `<...>`

**Out of scope:** `<...>` — don't let this silently expand; anything
found to be needed later is a new `REQ-`, not a scope creep on this one.

### Functional Requirements

- **FR-`<N>`** — `<a single unambiguous, testable sentence>`

### Non-Functional Requirements

- **NFR-`<N>`** — `<a single unambiguous, testable sentence>`

### Acceptance Criteria

- [ ] `<criterion, phrased so Dev/QA's real command output can be checked against it>`

### Open Questions

`<Resolve what you reasonably can, in writing, right here. Flag anything
that's actually an architecture decision for the Tech Lead section below
instead of resolving it yourself.>`

---

## Design (Tech Lead)

*Owned by the Tech Lead persona. How — filled in after the Requirements
section above is drafted, not before.*

### What's reused vs. new

`<Name explicitly what existing code/packages this builds on, and what's
genuinely new.>`

### Design decisions

`<Any real decision — naming, rounding, error handling, a chosen
algorithm — named and justified explicitly. Don't leave one to be
improvised mid-implementation.>`

### API surface (if applicable)

| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| | | | | |

### Dev story breakdown

- **DEV-`<NN>`** — `<one story, small enough for its own tracker row and its own tests>`

### Testing strategy

`<Unit tests: what Dev proves, and how. Full-stack tests: what QA
independently re-derives and verifies, per
docs/00-roles-and-responsibilities.md's QA/Tester rule (not values
copied from the implementation).>`

---

## Tracker cross-references

Fill these in as the work proceeds.

| ID | Persona | Status | Notes |
|----|---------|--------|-------|
| `REQ-<NNN>` | Product Owner | | |
| `DES-<NNN>` | Tech Lead | | |
| `DEV-<NN>` | Dev | | |
| `TEST-<NN>` | QA/Tester | | |
| `TECHLEAD-<NN>` | Tech Lead | | |
| `PO-<NN>` | Product Owner | | |
FILE

write_file "business-processes/README.md" <<'FILE'
# Business Process Files

Each real-world business process behind this project's requirements gets
**its own file** here: `business-processes/BP-<NNN>-<short-slug>.md`,
copied from `business-processes/TEMPLATE-business-process.md`. Unlike the
optional `specs/` alternative for requirements (see `specs/README.md`,
which defaults to appending and only splits into files on request), this
is the only convention for business processes — one process, one file,
always.

## Why one file per process

A business process entry is a narrative: stakeholders, triggers,
frequency, business rules, workflow steps. That's naturally
self-contained, and often substantial enough on its own to be worth
reading — or handing to someone outside the process — independently of
every other process. Concatenating all of them into one growing file
would make each one harder to find and harder to share for no real
benefit.

## How to use it

1. Copy `business-processes/TEMPLATE-business-process.md` to
   `business-processes/BP-<NNN>-<short-slug>.md` — the next unused `BP-`
   number (see `docs/03-spec-driven-development-playbook.md` §4: never
   reuse or renumber).
2. Fill it in. This is **Product Owner's** document — business "what and
   why" — the same persona that owns `docs/01-po-requirements.md`.
3. Add a row to the index table in
   `docs/06-business-processes-and-domain-glossary.md` §3 pointing at the
   new file.
4. Cross-reference both ways: the process file's "Related requirements"
   field names the `REQ-`/`FR-` id(s) that implement it, and the
   requirement's own entry names the `BP-` id back.
5. Any new domain term the process file uses goes in the shared glossary
   (`docs/06-business-processes-and-domain-glossary.md` §4), not
   redefined inline in the process file itself.

## What NOT to do

- Don't inline a process's narrative into `docs/01-po-requirements.md` or
  `docs/06-business-processes-and-domain-glossary.md` — link to its file
  instead.
- Don't skip the index row in `docs/06-...md` §3.
- Don't create a process file for a purely technical requirement that has
  no real-world stakeholder, trigger, or business rule — that's just an
  `FR-` in `docs/01`, not a `BP-`.
FILE

write_file "business-processes/TEMPLATE-business-process.md" <<'FILE'
<!--
Copy this file to business-processes/BP-<NNN>-<short-slug>.md and fill it
in. See business-processes/README.md for the convention this feeds into,
and docs/06-business-processes-and-domain-glossary.md for the index and
shared domain glossary this file should be listed and cross-referenced
from.

Delete this comment block once you start filling the file in for real.
-->

# `<Process Name>` — `BP-<NNN>`

**Status:** `Not Implemented` | `In Progress` | `Implemented`
**Date:** `<YYYY-MM-DD>`
**Owned by:** Product Owner

---

**Owner / stakeholder:** `<who in the business asked for or consumes
this>`

**Trigger:** `<what real-world event or schedule starts this process>`

**Frequency:** `<e.g. daily, on-demand, monthly>`

**Actors:**
- `<the system/job/person that triggers it>`
- `<the consumer(s) — who or what receives the output>`

**Inputs:** `<what data/state this process needs to run>`

**Outputs:** `<what this process produces, and in what form>`

**Business rules:**
- `<name every rule explicitly — this is exactly the kind of thing that
  otherwise gets improvised mid-implementation with no record of why>`

**Workflow:**
1. `<step 1>`
2. `<step 2>`
3. `<...>`

**Related requirements:** `<REQ-XXX / FR-N ids that implement this
process, or "None yet" if Status is Not Implemented>`

**Glossary terms used:** `<terms defined in
docs/06-business-processes-and-domain-glossary.md §4 that this process
relies on>`
FILE

# =============================================================================
# traceability/ and tracker/
# =============================================================================

write_file "traceability/TRACEABILITY_MATRIX.md" <<'FILE'
# Requirement Traceability Matrix

Maintained by: Tech Lead (created), all personas (kept current).
Update this file in the same unit of work that adds/changes the
`REQ-`/`DES-`/`DEV-`/`TEST-` row it references — never as a later cleanup
pass. See `docs/03-spec-driven-development-playbook.md` §4, §6.

**How to read a row:** given a requirement, this tells you exactly which
design section, which source files, and which test methods implement and
verify it, right now — so "what would changing FR-1 affect?" is a lookup,
not a codebase-wide search.

Empty — add a row here the same session the first `REQ-` is drafted.

| Requirement | Description | Design | Implementation | Tests | Status |
|---|---|---|---|---|---|
| | | | | | |

## Coverage summary

Nothing tracked yet. Update this section once the first requirement has
design/implementation/tests recorded above.
FILE

write_file "tracker/PROJECT_TRACKER.md" <<'FILE'
# Project Tracker — __PROJECT_TITLE__

Updated after every unit of work: requirement, design, dev, test, review,
or sign-off. Each row is one unit of work, in the writing persona's voice.
Status values: `Drafted`, `In Review`, `Approved`, `In Progress`,
`Complete`, `Blocked`. See `docs/03-spec-driven-development-playbook.md`
§4 for the ID convention and evidence convention this table follows.

| ID | Date | Persona | Work Item | Artifact | Status | Notes |
|----|------|---------|-----------|----------|--------|-------|
| | | | | | | |

## Open Items / Blockers

Phase 0: no requirement has been drafted yet. Start with
`/new-requirement <what's needed, and why>` (or the propose-new-work
protocol, `docs/03-spec-driven-development-playbook.md` §6) — see
`docs/04-new-requirement-intake.md`.

## Phase Overview

- [ ] Phase 0: Requirements (PO)
- [ ] Phase 1: Architecture & Design (Tech Lead)
- [ ] Phase 2: Implementation (Dev)
- [ ] Phase 3: Independent Testing (QA)
- [ ] Phase 4: Build Review (Tech Lead)
- [ ] Phase 5: PO Sign-off
FILE

# =============================================================================
# src/
# =============================================================================

write_file "src/main/resources/application.yml" <<'FILE'
spring:
  application:
    name: "@project.artifactId@"
FILE

write_file "src/main/java/__PACKAGE_PATH_TOKEN__/__APP_CLASS__Application.java" <<'FILE'
package __BASE_PACKAGE__;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point. See AGENTS.md for the spec-driven process this project
 * follows before any feature lands here.
 */
@SpringBootApplication
public class __APP_CLASS__Application {

  public static void main(String[] args) {
    SpringApplication.run(__APP_CLASS__Application.class, args);
  }
}
FILE

write_file "src/test/java/__PACKAGE_PATH_TOKEN__/__APP_CLASS__ApplicationTests.java" <<'FILE'
package __BASE_PACKAGE__;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class __APP_CLASS__ApplicationTests {

  @Test
  void contextLoads() {
    // Proves the application context boots cleanly. Real feature tests
    // land here as each requirement's Dev/QA stories are implemented —
    // see docs/00-roles-and-responsibilities.md.
  }
}
FILE

# --- Move the src/*/java files from the placeholder path to the real package
#     path, and rename them out of their __APP_CLASS__ placeholder names ---
for base in "src/main/java" "src/test/java"; do
  mkdir -p "$TARGET/$base/$PACKAGE_PATH"
  find "$TARGET/$base/__PACKAGE_PATH_TOKEN__" -maxdepth 1 -type f -print0 \
    | while IFS= read -r -d '' f; do
        newname="$(basename "$f" | sed "s/__APP_CLASS__/${APP_CLASS}/g")"
        mv "$f" "$TARGET/$base/$PACKAGE_PATH/$newname"
      done
  rm -rf "$TARGET/$base/__PACKAGE_PATH_TOKEN__"
done

# =============================================================================
# Placeholder substitution pass
# =============================================================================

find "$TARGET" -type f \( -name '*.md' -o -name '*.xml' -o -name '*.yml' -o -name '*.java' -o -name '*.json' \) -print0 \
  | xargs -0 sed -i \
      -e "s/__GROUP_ID__/${GROUP_ID}/g" \
      -e "s/__ARTIFACT_ID__/${ARTIFACT_ID}/g" \
      -e "s/__BASE_PACKAGE__/${BASE_PACKAGE}/g" \
      -e "s/__APP_CLASS__/${APP_CLASS}/g" \
      -e "s/__PROJECT_TITLE__/${PROJECT_TITLE}/g" \
      -e "s/__TODAY__/${TODAY}/g"

echo "Files written."
echo

# =============================================================================
# Build verification (default on — skip with --skip-build)
# =============================================================================

if [ "$SKIP_BUILD" -eq 1 ]; then
  echo "Skipped build verification (--skip-build passed)."
elif ! command -v mvn >/dev/null 2>&1; then
  echo "mvn not found on PATH — skipping build verification."
  echo "Run 'mvn compile && mvn test' yourself once Maven is available."
else
  echo "Verifying the scaffold actually builds (mvn compile && mvn test)..."
  ( cd "$TARGET" && mvn -q compile && mvn test )
  echo "Build verified."
fi

echo
echo "Done. Next steps:"
echo "  cd $TARGET"
echo "  git init && git add -A && git commit -m 'Scaffold via scaffold-project.sh'"
echo "  Read AGENTS.md, then draft your first requirement:"
echo "    /new-requirement <what's needed, and why>   (Claude Code)"
echo "  ...or say the same thing in plain language on any other agent."
