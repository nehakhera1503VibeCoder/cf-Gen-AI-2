# Per-Requirement Spec Files (Optional)

**Default behavior is unchanged.** A new requirement's spec, by default,
is a dated delta section appended to `docs/01-po-requirements.md` (the
PRD, Product Owner's) and `docs/02-techlead-design.md` (the design, Tech
Lead's) — see `docs/03-spec-driven-development-playbook.md` §6. That's
what `/new-requirement` does automatically, and it's the right default:
it keeps the whole PRD and the whole design readable start-to-end in two
files, and it's what `REQ-001` (the worked example) uses.

**This folder is an opt-in alternative for a single requirement**, not a
replacement for that default. Use it when a requirement is genuinely
better served by its own standalone file — usually because it's large,
because you want it as its own reviewable artifact (attached to a PR,
handed to someone outside the process), or because the PRD has grown to
where appending yet another delta section makes it harder to read as a
whole.

## How to use it

1. Ask for it explicitly: state the requirement and say you want it as a
   standalone spec file, e.g.:
   > Follow the propose-new-work protocol for this one, but write it as
   > its own `specs/` file instead of appending to `docs/01`/`docs/02`:
   > <what's needed, and why>.
2. Copy `specs/TEMPLATE-spec.md` to `specs/SPEC-<REQ-ID>-<short-slug>.md`
   (e.g. `specs/SPEC-002-floating-rate-schedule.md`) — the next unused
   `REQ-` number, same rule as always (`docs/03-...md` §4: never reuse or
   renumber).
3. Fill it in following the same persona discipline as everywhere else in
   this repo: the Requirements section is Product Owner's, the Design
   section is Tech Lead's — co-located in one file for convenience, but
   still written and owned by the persona whose section it is, not
   blended into one undifferentiated pass.
4. Everything downstream is identical to the default path: a `REQ-XXX`
   tracker row, a traceability matrix row, `DEV-`/`TEST-`/`TECHLEAD-`/`PO-`
   rows as usual. The only difference is what the tracker row's Artifact
   column and the matrix row's Design column point at —
   `specs/SPEC-XXX-....md` instead of `docs/01-po-requirements.md §N` /
   `docs/02-techlead-design.md §N`.

## What NOT to do

- Don't point a tracker or matrix row at *both* a `docs/01`/`docs/02`
  delta section *and* a `specs/` file for the same requirement — pick one
  per requirement, and make it unambiguous which one is authoritative.
- Don't retroactively convert an existing requirement (e.g. `REQ-001`)
  into this format just because the option now exists — only use it going
  forward, for a requirement where it's explicitly asked for.
- Don't use this as a way to skip the tracker or matrix — a `specs/` file
  replaces *where the requirement/design text lives*, not the
  chronological proof-of-work log or the per-requirement coverage lookup.
