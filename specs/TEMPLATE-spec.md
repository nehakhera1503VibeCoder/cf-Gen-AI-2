<!--
Copy this file to specs/SPEC-<REQ-ID>-<short-slug>.md (e.g.
specs/SPEC-002-floating-rate-schedule.md) and fill it in. See
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
docs/00-roles-and-responsibilities.md's QA/Tester rule (not values copied
from the implementation).>`

---

## Tracker cross-references

Fill these in as the work proceeds — this section is the same
information the tracker holds, kept here too so this file is a complete
record on its own without needing the tracker open side-by-side.

| ID | Persona | Status | Notes |
|----|---------|--------|-------|
| `REQ-<NNN>` | Product Owner | | |
| `DES-<NNN>` | Tech Lead | | |
| `DEV-<NN>` | Dev | | |
| `TEST-<NN>` | QA/Tester | | |
| `TECHLEAD-<NN>` | Tech Lead | | |
| `PO-<NN>` | Product Owner | | |
