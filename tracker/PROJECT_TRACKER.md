# Project Tracker — AI-Native Spring Boot Starter

Updated after every unit of work: requirement, design, dev, test, review,
or sign-off. Each row is one unit of work, in the writing persona's voice.
Status values: `Drafted`, `In Review`, `Approved`, `In Progress`,
`Complete`, `Blocked`. See `docs/03-spec-driven-development-playbook.md`
§4 for the ID convention and evidence convention this table follows.

| ID | Date | Persona | Work Item | Artifact | Status | Notes |
|----|------|---------|-----------|----------|--------|-------|
| REQ-001 | 2026-09-20 | Product Owner | Draft the worked-example requirement: generate a fixed-rate, fully-amortizing cashflow schedule via `POST /api/v1/cashflows/fixed-schedule`, reject invalid input with 400 (FR-1, FR-2, NFR-1, NFR-2) | `docs/01-po-requirements.md` §4, §5 | Approved | Chosen over a trivial single-endpoint stub specifically so the worked example exercises the full pipeline (2 FRs, 2 NFRs, 2 Dev stories, unit + full-stack tests) — real projects built from this starter replace this row entirely per `docs/05-ai-native-development-guide.md` §6. |
| DES-001 | 2026-09-20 | Tech Lead | Package layout (`domain`, `service`/`service.impl`, `api`/`api.dto`); named design decisions: level-payment amortization, `double`-for-formula/`BigDecimal`-for-money split (explicit demo-precision limitation), last-period rounding-drift correction; 2-story Dev breakdown; testing strategy | `docs/02-techlead-design.md` | Approved | Also rewrote `traceability/TRACEABILITY_MATRIX.md` with one row per FR/NFR ahead of Dev starting, per playbook §6 step 3. |
| DEV-01 | 2026-09-20 | Dev | `CashflowPeriod`, `CashflowSchedule` (domain); `CashflowScheduleGenerator`/`CashflowScheduleGeneratorImpl` — annuity-formula engine with FR-2 input validation and last-period balance correction | `src/main/java/com/example/starter/domain/**`, `src/main/java/com/example/starter/service/**` | Complete | `mvn compile` → `BUILD SUCCESS`. `mvn test` → `CashflowScheduleGeneratorImplTest`: `Tests run: 7, Failures: 0, Errors: 0, Skipped: 0`. |
| DEV-02 | 2026-09-20 | Dev | `CashflowController` (`POST /api/v1/cashflows/fixed-schedule`), request/response DTOs, `ApiExceptionHandler` (400 mapping for `IllegalArgumentException`) | `src/main/java/com/example/starter/api/**` | Complete | **Full suite, this run**: `mvn test` → `Tests run: 11, Failures: 0, Errors: 0, Skipped: 0` (`CashflowApiIntegrationTest` 4, `CashflowScheduleGeneratorImplTest` 7), `BUILD SUCCESS`. **Also**: `mvn clean package` → `BUILD SUCCESS`, produced `target/ai-native-spring-starter-0.1.0-SNAPSHOT.jar`. **Also verified live**: ran the packaged jar standalone (`java -jar ...jar`, no Maven) and curled it — 1-period request (`principal:1000, rate:0.12, periodsPerYear:12, numberOfPeriods:1`) returned exactly `interest:10.00, principal:1000.00, payment:1010.00, remainingBalance:0.00`; a 6-period request (`principal:5000, rate:0.09, periodsPerYear:12`) returned a full schedule whose principal components summed to `5000.00` with the final period's `remainingBalance:0.00`; an invalid request (`principal:0`) correctly returned `400`. |
| TEST-01 | 2026-09-20 | QA/Tester | Independent full-stack verification pass: `CashflowApiIntegrationTest` (`@SpringBootTest` + `TestRestTemplate`) hits the real endpoint, re-deriving expected values from `docs/01-po-requirements.md`'s own wording (the single-period collapse of the annuity formula, and the principal-sums-to-total/zero-final-balance invariant) rather than copying them from `CashflowScheduleGeneratorImpl`, plus both FR-2 400 cases | `src/test/java/com/example/starter/api/CashflowApiIntegrationTest.java` | Complete | Re-ran the full suite independently of the Dev pass: `mvn test` → `Tests run: 11, Failures: 0, Errors: 0, Skipped: 0`, `BUILD SUCCESS`, same run confirms no regression from DEV-01/DEV-02. Cross-checked `traceability/TRACEABILITY_MATRIX.md` row by row against actual test method names — no FR/NFR left without both a unit test and a full-stack test. |
| TECHLEAD-01 | 2026-09-20 | Tech Lead | Build review against `docs/02-techlead-design.md` (DES-001): confirms package layout, the level-payment/last-period-correction decisions, and the API surface all match the design as drafted. No deviations found. | `docs/02-techlead-design.md` §4 | Approved | Reviewed `CashflowScheduleGeneratorImpl`/`CashflowController`/`ApiExceptionHandler` against the actual `src/main/java` tree, not from memory. Confirms `NFR-1` (no I/O in the service layer) and `NFR-2` (HALF_UP rounding, last-period correction) both hold in the shipped code. |
| PO-01 | 2026-09-20 | Product Owner | Worked-example sign-off against `docs/01-po-requirements.md` §6 acceptance criteria | `docs/01-po-requirements.md` §6 | Approved | All 4 acceptance criteria met — see "PO Sign-off" section below. **Worked example accepted.** |

---

## PO Sign-off (PO-01)

Reviewed against `docs/01-po-requirements.md` §6:

- [x] The 1-period case returns the exact hand-computed values (interest
      `10.00`, principal `1000.00`, payment `1010.00`, balance `0.00`).
      Verified: `CashflowScheduleGeneratorImplTest#singlePeriod_...`,
      `CashflowApiIntegrationTest#fixedSchedule_singlePeriod_...`, live
      curl (DEV-01/DEV-02/TEST-01).
- [x] For any valid multi-period request, principal components sum
      exactly to the requested principal and the final balance is
      `0.00`. Verified:
      `CashflowScheduleGeneratorImplTest#multiPeriod_...`,
      `CashflowApiIntegrationTest#fixedSchedule_multiPeriod_...`, live
      curl on a 6-period example (DEV-01/DEV-02/TEST-01).
- [x] Every FR-2 invalid-input case returns HTTP 400. Verified: 4 unit
      tests + 2 full-stack tests + live curl (DEV-01/DEV-02/TEST-01).
- [x] `mvn test` passes with real, run verification evidence recorded for
      every row above. `11/11`, `BUILD SUCCESS` (TEST-01).

**Worked example accepted. Template ready to demo or extend via
`/new-requirement`.**

## Open Items / Blockers

None. Both FRs and both NFRs are fully covered per
`traceability/TRACEABILITY_MATRIX.md`. This is a template — the intended
next step for anyone using it is `docs/05-ai-native-development-guide.md`
§6 (replace the worked example with a real project's requirements), not
further work on `REQ-001` itself.

## Phase Overview

- [x] Phase 0: Requirements (PO) — `REQ-001`
- [x] Phase 1: Architecture & Design (Tech Lead) — `DES-001`
- [x] Phase 2: Domain + Engine (Dev) — `DEV-01`
- [x] Phase 3: REST API (Dev) — `DEV-02`
- [x] Phase 4: Independent Testing (QA) — `TEST-01`
- [x] Phase 5: Build Review (Tech Lead) — `TECHLEAD-01`
- [x] Phase 6: PO Sign-off — `PO-01`, worked example accepted
