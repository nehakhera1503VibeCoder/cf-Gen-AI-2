# Requirement Traceability Matrix

Maintained by: Tech Lead (created), all personas (kept current).
Update this file in the same unit of work that adds/changes the
`REQ-`/`DES-`/`DEV-`/`TEST-` row it references — never as a later cleanup
pass. See `docs/03-spec-driven-development-playbook.md` §4, §6.

**How to read a row:** given a requirement, this tells you exactly which
design section, which source files, and which test methods implement and
verify it, right now — so "what would changing FR-1 affect?" is a lookup,
not a codebase-wide search.

| Requirement | Description | Design | Implementation | Tests | Status |
|---|---|---|---|---|---|
| `FR-1` (REQ-001) | Generate a fully-amortizing, level-payment cashflow schedule | `docs/02-techlead-design.md` §3, §4 (`POST /api/v1/cashflows/fixed-schedule`) | `domain/CashflowPeriod.java`, `domain/CashflowSchedule.java`, `service/CashflowScheduleGenerator.java`, `service/impl/CashflowScheduleGeneratorImpl.java` (DEV-01); `api/CashflowController.java`, `api/dto/**` (DEV-02) | `CashflowScheduleGeneratorImplTest#singlePeriod_computesInterestAndPrincipalExactly`, `#zeroRate_distributesPrincipalEvenlyAcrossPeriods`, `#multiPeriod_principalComponentsSumToOriginalPrincipalAndBalanceReachesZero` (DEV-01); `CashflowApiIntegrationTest#fixedSchedule_singlePeriod_returnsIndependentlyHandComputedInterestAndPrincipal`, `#fixedSchedule_multiPeriod_principalComponentsSumToRequestedPrincipal` (TEST-01) | Done |
| `FR-2` (REQ-001) | Reject invalid input (non-positive principal, negative rate, missing/non-positive periods) with 400 | `docs/02-techlead-design.md` §4 | `service/impl/CashflowScheduleGeneratorImpl.java` (validation), `api/ApiExceptionHandler.java` (DEV-01, DEV-02) | `CashflowScheduleGeneratorImplTest#rejectsNonPositivePrincipal`, `#rejectsNegativeRate`, `#rejectsNonPositivePeriods`, `#rejectsMissingPeriodsPerYear` (DEV-01); `CashflowApiIntegrationTest#fixedSchedule_nonPositivePrincipal_returns400`, `#fixedSchedule_missingPeriodsPerYear_returns400` (TEST-01) | Done |
| `NFR-1` (REQ-001) | No external dependency; works with zero configuration | `docs/02-techlead-design.md` §3 | `service/impl/CashflowScheduleGeneratorImpl.java` (pure computation, no I/O) (DEV-01) | Implicitly exercised by every test above (no test fixture requires external state) | Done |
| `NFR-2` (REQ-001) | Deterministic HALF_UP rounding; last period corrects drift so principal sums exactly and balance reaches 0.00 | `docs/02-techlead-design.md` §3 | `service/impl/CashflowScheduleGeneratorImpl.java` (last-period balance correction) (DEV-01) | `CashflowScheduleGeneratorImplTest#multiPeriod_principalComponentsSumToOriginalPrincipalAndBalanceReachesZero` (DEV-01); `CashflowApiIntegrationTest#fixedSchedule_multiPeriod_principalComponentsSumToRequestedPrincipal` (TEST-01) | Done |

## Coverage summary (as of `TEST-01` / `PO-01`)

- 2/2 functional requirements: unit-tested and full-stack-tested.
- 2/2 non-functional requirements: satisfied and verified.
- 0 requirements with a design or test gap.

Add a new row here in the same unit of work that adds the `REQ-` tracker
row for it (`docs/03-spec-driven-development-playbook.md` §4) — a `REQ-`
row with no corresponding matrix row is itself a process defect worth
flagging in the next Tech Lead review.
