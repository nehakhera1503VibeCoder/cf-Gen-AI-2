# Tech Lead Design

**Status:** Approved, Tech Lead
**Date:** 2026-09-20

## 1. Overview

Minimal Spring Boot MVC service. Base package: `com.example.starter`.

## 2. Package layout

```
com.example.starter
├── StarterApplication.java          # @SpringBootApplication entry point
├── domain/
│   ├── CashflowPeriod.java          # one period's payment/interest/principal/balance
│   └── CashflowSchedule.java        # the full generated schedule
├── service/
│   ├── CashflowScheduleGenerator.java       # interface (FR-1, FR-2)
│   └── impl/
│       └── CashflowScheduleGeneratorImpl.java
└── api/
    ├── CashflowController.java
    ├── ApiExceptionHandler.java     # maps IllegalArgumentException -> 400
    └── dto/
        ├── CashflowScheduleRequestDto.java
        ├── CashflowPeriodDto.java
        ├── CashflowScheduleResponseDto.java
        └── ErrorResponseDto.java
```

This is the same `domain` / `service` / `api` layering larger projects
built from this starter should follow, introduced here because `REQ-001`
actually needs all three layers (a pure computation belongs in `domain`/
`service`, not in the controller). Add `repository/` and `config/` the
same way, only once a requirement needs them.

## 3. Design decisions

- **Level-payment (annuity) amortization, not equal-principal.** Each
  period pays the same total amount; the interest/principal split shifts
  as the balance shrinks. This is the standard "fixed-rate loan schedule"
  shape and what FR-1 asks for.
- **`double` for the annuity formula, `BigDecimal` for money.** The
  payment formula (`P·i / (1 − (1+i)^−n)`) involves exponentiation;
  computing it in `BigDecimal` would need an arbitrary-precision `pow`
  with no material benefit for a demo. The formula is evaluated once in
  `double`, then the result and every subsequent per-period value is
  rounded into `BigDecimal` at 2 decimal places (`HALF_UP`) and all
  further arithmetic (subtracting principal, accumulating balance) stays
  in `BigDecimal`. **Explicit limitation, not glossed over:** this is
  demo-grade precision, not what a production fixed-income system should
  use for regulatory or accounting-grade cashflows — a real system should
  replace this with a decimal-only annuity calculation or a vetted
  financial library.
- **Last period absorbs rounding drift.** Every period's principal
  component is `payment − interest`, rounded to 2dp, *except* the final
  period, which is forced to exactly the remaining balance. Without this,
  per-period rounding could leave the schedule a cent or two short of (or
  over) fully repaying the principal. This is what makes NFR-2's
  "principal components sum exactly to the requested principal, final
  balance exactly `0.00`" invariant hold unconditionally — and it's the
  invariant QA's independent pass verifies (§6 below), rather than
  re-deriving the engine's exact per-period numbers.
- **No Spring Actuator / persistence for this worked example.** Kept
  intentionally minimal — this is a process worked example, not a
  production financial service.

## 4. API surface

| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| POST | `/api/v1/cashflows/fixed-schedule` | `{principal, annualInterestRate, periodsPerYear, numberOfPeriods}` | `200 {principal, annualInterestRate, periodsPerYear, numberOfPeriods, periods: [{periodNumber, payment, interest, principal, remainingBalance}]}` | `FR-1` |
| POST | `/api/v1/cashflows/fixed-schedule` (invalid input) | any field missing/out of range | `400 {message}` | `FR-2` |

## 5. Dev story breakdown

- **DEV-01**: `CashflowPeriod`, `CashflowSchedule` (domain), the
  `CashflowScheduleGenerator` interface and its
  `CashflowScheduleGeneratorImpl` (the annuity formula, per-period
  interest/principal split, last-period balance correction, and all FR-2
  input validation) — with unit tests covering the hand-computable
  single-period case, the zero-rate case, the multi-period invariant, and
  every FR-2 rejection.
- **DEV-02**: `CashflowController`, the four DTOs, and
  `ApiExceptionHandler` — wiring the engine to
  `POST /api/v1/cashflows/fixed-schedule` and mapping
  `IllegalArgumentException` to `400`.

## 6. Testing strategy

**Unit tests** (`CashflowScheduleGeneratorImplTest`, Dev): the engine in
isolation, no Spring context — the single-period case against an
exactly hand-computed expected value, a zero-rate case, and the
multi-period sum/final-balance invariant, plus one test per FR-2
rejection reason.

**Full-stack test** (`CashflowApiIntegrationTest`, QA): the same
requirement, but through the real HTTP endpoint (`@SpringBootTest` +
`TestRestTemplate`), and with expected values re-derived independently
from the PRD's own wording (FR-1's definition of the invariant), not
copied from `CashflowScheduleGeneratorImpl`'s source — per
`docs/00-roles-and-responsibilities.md`'s QA/Tester rule.
