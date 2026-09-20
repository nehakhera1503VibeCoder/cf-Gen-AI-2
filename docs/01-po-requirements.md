# Product Requirements Document

**Status:** Approved, Product Owner
**Date:** 2026-09-20

## 1. Purpose

This document is the binding scope and acceptance criteria for this
project — a template repo, so it currently carries one worked example
(`REQ-001`: fixed-rate cashflow generation) sized to actually exercise the
full PO → Tech Lead → Dev → QA pipeline (multiple requirements, multiple
Dev stories, unit tests, an independent full-stack pass) rather than a
one-line stub. Replace this document's content with your own project's
requirements when you adopt this starter — see
`docs/05-ai-native-development-guide.md` §6.

## 2. Scope (current)

In scope: generating a fully-amortizing, level-payment cashflow schedule
for a fixed-rate loan/bond-style instrument, given principal, annual
interest rate, payment frequency, and number of periods — as the worked
example of the full PO → Tech Lead → Dev → QA cycle this template runs.

Out of scope (for this worked example — not a limitation of the template
itself): variable/floating rates, day-count conventions, business-day
adjustment, multi-currency, persistence, authentication. A real project
built from this starter adds any of these via the propose-new-work
protocol (`docs/03-spec-driven-development-playbook.md` §6), the same way
`docs/04-new-requirement-intake.md`'s example does.

## 3. Personas

See `docs/00-roles-and-responsibilities.md`.

## 4. Functional Requirements

### FR-1 — Generate a fixed-rate cashflow schedule (`REQ-001`)

`POST /api/v1/cashflows/fixed-schedule` accepts a principal, an annual
interest rate (as a decimal, e.g. `0.12` for 12%), the number of payment
periods per year, and the total number of periods, and returns a
fully-amortizing, level-payment schedule: for each period, the payment,
its interest and principal components, and the remaining balance —
computed so that the principal components across all periods sum exactly
to the requested principal and the final period's remaining balance is
`0.00`.

### FR-2 — Reject invalid input (`REQ-001`)

The endpoint rejects, with HTTP 400 and a message naming the problem: a
non-positive principal, a negative interest rate, a missing/non-positive
periods-per-year, or a missing/non-positive number-of-periods.

## 5. Non-Functional Requirements

### NFR-1 — No external dependencies (`REQ-001`)

Schedule generation is a pure computation with no database, cache, or
outbound call — it works the moment `mvn spring-boot:run` starts, with
zero configuration.

### NFR-2 — Deterministic rounding, stated explicitly (`REQ-001`)

All monetary values are rounded to 2 decimal places using `HALF_UP`, and
any rounding drift accumulated across periods is corrected in the final
period so the schedule always reaches exactly a `0.00` balance — this
rule is named explicitly in the design doc, not left implicit in the
arithmetic.

## 6. Acceptance Criteria

- [ ] `POST /api/v1/cashflows/fixed-schedule` with a 1-period request
      returns the exact, hand-computable single-period case: for
      principal `1000`, rate `0.12`, `periodsPerYear=12`,
      `numberOfPeriods=1` → interest `10.00`, principal `1000.00`,
      payment `1010.00`, remaining balance `0.00`.
- [ ] For any valid multi-period request, the sum of all periods'
      principal components equals the requested principal exactly, and
      the final period's remaining balance is `0.00`.
- [ ] Each of the FR-2 invalid-input cases returns HTTP 400.
- [ ] `mvn test` passes with real, run verification evidence recorded for
      every row in the tracker.

## 7. Open Questions

None open as of `REQ-001`. Resolved:

- **Should the rate be supplied per-period or annualized?** Annualized —
  the request carries `annualInterestRate` and `periodsPerYear`
  separately, and the service divides internally, matching how loan/bond
  terms are normally quoted.
- **Should `/api/v1/cashflows/fixed-schedule` require authentication?**
  No — this template has no auth layer; a real project built from it can
  add one via a new `REQ-` if needed.
