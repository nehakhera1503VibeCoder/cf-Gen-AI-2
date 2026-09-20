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
(the way `docs/01-po-requirements.md`'s requirements are, deliberately,
append-only) would make each one harder to find and harder to share for
no real benefit — a business process isn't looked up "in chronological
order" the way a PRD delta is.

## How to use it

1. Copy `business-processes/TEMPLATE-business-process.md` to
   `business-processes/BP-<NNN>-<short-slug>.md` — the next unused `BP-`
   number (see `docs/03-spec-driven-development-playbook.md` §4: never
   reuse or renumber, same rule as every other ID prefix in this repo).
2. Fill it in. This is **Product Owner's** document — business "what and
   why" — the same persona that owns `docs/01-po-requirements.md`.
3. Add a row to the index table in
   `docs/06-business-processes-and-domain-glossary.md` §3 pointing at the
   new file. That index is the one place to see every business process at
   a glance without opening each file individually.
4. Cross-reference both ways: the process file's "Related requirements"
   field names the `REQ-`/`FR-` id(s) that implement it, and the
   requirement's own entry (in `docs/01-po-requirements.md`, or a
   `specs/SPEC-XXX.md` if that optional convention was used) names the
   `BP-` id back.
5. Any new domain term the process file uses goes in the shared glossary
   (`docs/06-business-processes-and-domain-glossary.md` §4), not
   redefined inline in the process file itself.

## What NOT to do

- Don't inline a process's narrative into `docs/01-po-requirements.md` or
  `docs/06-business-processes-and-domain-glossary.md` — link to its file
  instead.
- Don't skip the index row in `docs/06-...md` §3 — that's what keeps
  "list every business process" a single read instead of a directory
  listing.
- Don't create a process file for a purely technical requirement that has
  no real-world stakeholder, trigger, or business rule — that's just an
  `FR-` in `docs/01`, not a `BP-`.
