# AI-Native Development Guide

**Status:** Approved, Tech Lead
**Date:** 2026-09-20
**Audience:** anyone using this template — the reason the rest of `docs/`
is structured the way it is.

## 1. Why this doc exists

Every other doc in this repo describes *what* the process is. This one
explains *why* it's shaped this way: this whole layout is a response to
one fact — an AI coding agent has no memory between sessions, and every
token it spends re-deriving something that was already known is a token
that didn't go toward the actual work. This is the doc to read before
assuming "spec-driven process" and "fast, cheap AI development" are in
tension. Done right, they're the same thing: a well-kept written record
is *both* the correctness mechanism and the token-efficiency mechanism.

## 2. Where tokens actually go, unmanaged

If you strip out the tracker, the matrix, the persona split, and the
resume protocol, here's what a long-lived AI-assisted project tends to
cost instead:

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
  in one context window at once, instead of each role's concerns
  collapsing back out once its job is done.
- **No evidence discipline.** A tracker row that says "should work"
  invites a later session to not trust it, and re-verify from scratch —
  the exact loop real command output is supposed to prevent.
- **Whole-file rewrites for small changes.** Sending an entire file back
  through the model to change three lines costs roughly the size of the
  file, twice, for a three-line diff.
- **Serial tool calls with no dependency between them.** Every avoidable
  round trip adds fixed overhead on top of whatever the call itself costs.

## 3. The structural fixes — why this repo is laid out this way

### 3.1 Filesystem as memory

`tracker/PROJECT_TRACKER.md` and `traceability/TRACEABILITY_MATRIX.md`
exist so "what's done, what's next, what covers requirement X" are
**lookups**, not investigations. A session that trusts the tracker reads
maybe 200 lines instead of the whole `src/` tree.

### 3.2 A fixed, ordered resume-read list

`docs/03-spec-driven-development-playbook.md` §5 names exactly which files
to read, in what order, for "continue the project." An agent that already
knows its reading list doesn't spend tool calls discovering one.

### 3.3 Small, single-purpose docs, split by persona

Requirements, design, process, and this guide are four different files on
purpose. A Developer subagent implementing a story needs
`docs/02-techlead-design.md`; it does not need to re-read the Product
Owner's open-questions log or this guide's rationale every time — each doc
earns its place in a persona's required-reading list independently.

### 3.4 Persona-scoped subagents = persona-scoped context

This is the single biggest lever this template pulls, and it's a *native*
Claude Code capability, not a convention: `.claude/agents/*.md` gives each
persona its own subagent with its own restricted tool list (see §4.1).
That means a Product Owner pass literally cannot open a shell and start
exploring the whole codebase — it's confined to the handful of docs its
job requires, by construction, not by discipline. Smaller forced context
per role is a token savings, not just a correctness one.

### 3.5 Evidence discipline kills verification loops

A tracker row that cites the actual `mvn test` output doesn't need to be
re-verified by the next session — it can be trusted and built on. This is
why `docs/03-spec-driven-development-playbook.md` §4 insists on real
command evidence, not descriptions of intent.

### 3.6 The propose-new-work protocol bounds scope drift

Without it, a small ask ("also handle this edge case") tends to expand
mid-implementation into changes nothing documented, which the *next*
session then has to reconstruct from the diff instead of reading a design
delta. Naming new scope explicitly, every time, keeps the docs able to
answer "why does the code do this" without re-deriving it from git blame.

## 4. Native AI capabilities this template wires up (Claude Code)

These are concrete, checked-in mechanisms — not just advice — because a
checked-in mechanism survives a new session; advice in a chat transcript
does not.

### 4.1 Subagents (`.claude/agents/*.md`)

Each persona is a real subagent with a `tools:` allowlist in its
frontmatter. `product-owner.md` lists `Read, Grep, Glob, Edit, Write` —
no `Bash` — so it structurally cannot run a build or explore the codebase
via shell, which is the enforcement behind "Product Owner never writes
code." `developer.md` and `qa-tester.md` add `Bash` because their job
requires actually running `mvn`. This is what makes "stay in persona" a
hard boundary instead of a request the model might drift from over a long
session.

### 4.2 Slash commands (`.claude/commands/*.md`)

`/new-requirement <ask>` and `/resume-project` are saved prompts — the
entire multi-step protocol from
`docs/03-spec-driven-development-playbook.md` §5/§6, written once, invoked
by name. Without them, driving the same protocol means re-typing (or the
model re-deriving) the same instructions on every new request. A saved
command is a fixed, reusable token cost instead of a recurring one.

### 4.3 The `AGENTS.md` / `CLAUDE.md` dual-file convention

`CLAUDE.md` is one line (`@AGENTS.md`) plus Claude Code–specific notes.
Claude Code auto-loads `CLAUDE.md` at session start, so the whole §1
reading list and the hard rules are in context before the first user
message is even needed — no manual "please read the docs first" prompt
required, and no duplicated content that could drift between two copies
of the same rules.

### 4.4 `.claude/settings.json` permission allowlist

This process runs the same handful of commands constantly:
`mvn compile`, `mvn test`, `git status`. Without a project-level
allowlist, each one prompts for interactive approval — not a token cost
directly, but a turn cost that compounds across a long session just as
real re-runs do. `.claude/settings.json` in this repo pre-approves exactly
those commands and nothing wider (no wildcard shell access), so routine
verification doesn't stall on a prompt while anything unexpected still
does.

### 4.5 Hooks (optional — not wired up by default here)

Claude Code supports hooks (shell commands run on tool-call or session
events) for things like "remind me if I'm about to end a turn without a
tracker update." This template doesn't ship one by default to keep the
starting point minimal, but it's the natural next native capability to
add if a team finds tracker updates are being skipped — see Claude Code's
own hooks documentation, and the `update-config` skill if you're
configuring one from inside a session.

## 5. Engineering habits that cut tokens regardless of tool

These apply whether or not you're using Claude Code's subagents/commands —
they're just good practice for any AI coding session:

- **`Grep`/`Glob` before `Read`.** Find the right file and the right lines
  before reading whole files speculatively.
- **Read a known range**, not a whole large file, when you already know
  which part you need (line-offset/limit reads).
- **Prefer a targeted edit over a whole-file rewrite.** A diff-shaped edit
  costs roughly the size of the change; a full rewrite costs roughly the
  size of the file, both directions.
- **Batch independent tool calls in one turn** instead of serial round
  trips when the calls don't depend on each other's results.
- **Don't re-read a file you just wrote or edited "to confirm."** The
  write/edit tool already reports success or failure.
- **Keep tracker rows and commit messages terse and evidentiary** — a
  command and its real output, not a narrated retelling of the work.
- **Split a doc that's grown past what one persona needs for one job** —
  that's the signal it's time for a new `docs/0N-*.md` file, not a longer
  one.

## 6. Applying this to a brand-new project (not the worked example here)

To replace this template's worked example with your own domain:

1. Rewrite `docs/01-po-requirements.md` with your real requirements,
   starting the FR/NFR numbering at 1 (drop the worked `FR-1`/`NFR-1`).
2. Rewrite `docs/02-techlead-design.md` with your real architecture,
   package layout, and Dev story breakdown.
3. Reset `tracker/PROJECT_TRACKER.md` to an empty table plus a fresh
   "Phase Overview" checklist (Phase 0 unchecked).
4. Reset `traceability/TRACEABILITY_MATRIX.md` to an empty table with just
   its header row.
5. Rename the Maven coordinates in `pom.xml` and the base package
   (`com.example.starter` → your own), updating the one class that
   references it.
6. Keep everything else unchanged: `docs/00`, `docs/03`, `docs/04`, this
   file, and all of `.claude/`. None of it is specific to the worked
   example — it's the process layer, and it's what the rest of your
   project's history will be recorded against.

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

If the answer to any of these flags a problem, fix that before proceeding
— it's cheaper than fixing it after the fact.
