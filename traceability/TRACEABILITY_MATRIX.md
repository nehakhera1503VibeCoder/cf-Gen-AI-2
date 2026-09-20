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
| `FR-1` (REQ-001) | `GET /api/v1/info` returns name, version, status | `docs/02-techlead-design.md` §4 | `api/InfoController.java`, `api/dto/InfoResponseDto.java` (DEV-01) | `InfoControllerTest#info_returnsNameVersionAndUpStatus` (TEST-01) | Done |
| `NFR-1` (REQ-001) | No external dependency; works with zero configuration | `docs/02-techlead-design.md` §3 | `api/InfoController.java` (reads only `application.yml` placeholders) (DEV-01) | `InfoControllerTest` (TEST-01) | Done |

## Coverage summary (as of `TEST-01` / `PO-01`)

- 1/1 functional requirement: unit-tested.
- 1/1 non-functional requirement: satisfied and verified.
- 0 requirements with a design or test gap.

Add a new row here in the same unit of work that adds the `REQ-` tracker
row for it (`docs/03-spec-driven-development-playbook.md` §4) — a `REQ-`
row with no corresponding matrix row is itself a process defect worth
flagging in the next Tech Lead review.
