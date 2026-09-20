# Business Processes & Domain Glossary

**Status:** Approved, Product Owner
**Date:** 2026-09-20
**Owned by:** Product Owner (see `docs/00-roles-and-responsibilities.md`)

## 1. Why this doc exists

An `FR-`/`NFR-` entry in `docs/01-po-requirements.md` is a testable
statement about system behavior — "the system does X." It deliberately
doesn't carry: who in the business asked for it, what real-world event
triggers it, how often it runs, what business rules govern it, or what the
domain terms mean. That context is exactly what a new person — or a fresh
AI session with no memory of this conversation — needs when a requirement
says something like "generate the daily cashflow report" and has to know
*why* daily, *why* a report and not just an API response, who reads it,
and what "ledger" means in this business.

That context lives in **its own file per business process**, under
`business-processes/` — not as sections in this doc. This doc is the
**index** (§3) and the **shared domain glossary** (§4): the two things
that genuinely benefit from being centralized, even though each process's
own narrative doesn't.

## 2. How business processes are documented

- Each business process gets its own file:
  `business-processes/BP-<NNN>-<short-slug>.md`, copied from
  `business-processes/TEMPLATE-business-process.md`. See
  `business-processes/README.md` for the full convention.
- A business process file can exist **before** any `REQ-` implements it —
  a known future need, not yet built. Its Status field says
  `Not Implemented` explicitly (see `BP-001` in §3) so nobody mistakes
  documented intent for delivered behavior.
- Every process file names the `REQ-`/`FR-` id(s) that implement it, and
  a requirement that exists to serve a business process cites the `BP-`
  id back — from `docs/01-po-requirements.md`, or a `specs/SPEC-XXX.md`
  if that optional convention was used (`specs/README.md`).
- This is Product Owner's territory (business "what and why"), same as
  `docs/01`. If a business rule turns out to require an architecture
  decision, that's Tech Lead's design doc's job to record, not a business
  process file's — name it as a question for Tech Lead rather than
  deciding it here.

## 3. Business process index

Every `business-processes/BP-*.md` file gets a row here, added or updated
in the same session the file is added or its status changes.

| ID | Name | Status | File | Related Requirements |
|---|---|---|---|---|
| `BP-001` | Daily Cashflow Report for Ledger | `Not Implemented` | [`business-processes/BP-001-daily-cashflow-report-for-ledger.md`](../business-processes/BP-001-daily-cashflow-report-for-ledger.md) | None yet |

## 4. Domain glossary

Shared across every business process file — a term goes here once,
referenced from any process (or requirement) that uses it, not redefined
inline every time.

| Term | Definition |
|---|---|
| **Ledger** | `<the system of record for posted financial transactions that a cashflow report reconciles against — define this precisely for your actual business; this is a placeholder>` |
| **Cashflow Schedule** | The fully-amortizing, level-payment schedule produced by `FR-1` (`docs/01-po-requirements.md`) — see `docs/02-techlead-design.md` for how it's computed. |
| **Reconciliation** | `<definition specific to your business — e.g. matching expected cashflows against actually-posted ledger entries and flagging discrepancies>` |

Add a term here the first time a business process file or requirement
uses it in a way that isn't self-explanatory from plain English — don't
wait for someone to have to ask what it means.

## 5. Keeping this current

- Product Owner adds a new `business-processes/BP-<NNN>-*.md` file (from
  the template) in the same session a business process is identified,
  and adds its index row here (§3) at the same time — the same
  discipline as `docs/03-spec-driven-development-playbook.md` §4's
  "every `REQ-` gets a matrix row the same session," applied to business
  context instead of test coverage.
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
