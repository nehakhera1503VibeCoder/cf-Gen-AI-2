# Project Tracker — AI-Native Spring Boot Starter

Updated after every unit of work: requirement, design, dev, test, review,
or sign-off. Each row is one unit of work, in the writing persona's voice.
Status values: `Drafted`, `In Review`, `Approved`, `In Progress`,
`Complete`, `Blocked`. See `docs/03-spec-driven-development-playbook.md`
§4 for the ID convention and evidence convention this table follows.

| ID | Date | Persona | Work Item | Artifact | Status | Notes |
|----|------|---------|-----------|----------|--------|-------|
| REQ-001 | 2026-09-20 | Product Owner | Draft the worked-example requirement: `GET /api/v1/info` returns name/version/status, with no auth or external dependency (FR-1, NFR-1) | `docs/01-po-requirements.md` §4, §5 | Approved | Deliberately trivial — this is the template's worked example of the full pipeline, not a real project's requirement. Real projects built from this starter replace this row entirely per `docs/05-ai-native-development-guide.md` §6. |
| DES-001 | 2026-09-20 | Tech Lead | Package layout (`api`, `api/dto`), the version-from-pom (not hardcoded) design decision, 1-story Dev breakdown, testing strategy | `docs/02-techlead-design.md` | Approved | Also created `traceability/TRACEABILITY_MATRIX.md` with one row per FR/NFR ahead of Dev starting, per playbook §6 step 3. |
| DEV-01 | 2026-09-20 | Dev | `InfoResponseDto`, `InfoController` (`GET /api/v1/info`), `application.yml` wiring for name/version from Maven properties | `src/main/java/com/example/starter/api/**`, `src/main/resources/application.yml` | Complete | `mvn compile` → `BUILD SUCCESS`. `mvn test` → `Tests run: 1, Failures: 0, Errors: 0, Skipped: 0`, `BUILD SUCCESS`. |
| TEST-01 | 2026-09-20 | QA/Tester | Independent verification pass: re-ran `mvn test` independently of the Dev pass and confirmed `InfoControllerTest` asserts all three response fields (`name`, `version`, `status`) against independently-derived expected values (the actual `pom.xml` artifactId/version, not copied from the controller source) | `src/test/java/com/example/starter/api/InfoControllerTest.java` | Complete | `mvn test` → `Tests run: 1, Failures: 0, Errors: 0, Skipped: 0`, `BUILD SUCCESS`. Cross-checked the traceability matrix row for `FR-1`/`NFR-1` — both covered, no gap. |
| TECHLEAD-01 | 2026-09-20 | Tech Lead | Build review against `docs/02-techlead-design.md` (DES-001): confirms package layout and the version-from-pom decision match the design as drafted. No deviations found. | `docs/02-techlead-design.md` §4 | Approved | Reviewed `InfoController`/`InfoResponseDto` against the actual `src/main/java` tree, not from memory. |
| PO-01 | 2026-09-20 | Product Owner | Worked-example sign-off against `docs/01-po-requirements.md` §6 acceptance criteria | `docs/01-po-requirements.md` §6 | Approved | Both acceptance criteria met — see "PO Sign-off" section below. **Worked example accepted; template ready to use.** |

---

## PO Sign-off (PO-01)

Reviewed against `docs/01-po-requirements.md` §6:

- [x] `GET /api/v1/info` returns HTTP 200 with `name`, `version`, and
      `status` fields, `status` = `"UP"`. Verified: `InfoControllerTest`
      (DEV-01/TEST-01).
- [x] `mvn test` passes with real, run verification evidence recorded for
      every row above. `1/1` pass, `BUILD SUCCESS` (TEST-01).

**Worked example accepted. Template ready to demo or extend via
`/new-requirement`.**

## Open Items / Blockers

None. The worked example (`REQ-001`) is fully covered per
`traceability/TRACEABILITY_MATRIX.md`. This is a template — the intended
next step for anyone using it is `docs/05-ai-native-development-guide.md`
§6 (replace the worked example with a real project's requirements), not
further work on `REQ-001` itself.

## Phase Overview

- [x] Phase 0: Requirements (PO) — `REQ-001`
- [x] Phase 1: Architecture & Design (Tech Lead) — `DES-001`
- [x] Phase 2: Implementation (Dev) — `DEV-01`
- [x] Phase 3: Independent Testing (QA) — `TEST-01`
- [x] Phase 4: Build Review (Tech Lead) — `TECHLEAD-01`
- [x] Phase 5: PO Sign-off — `PO-01`, worked example accepted
