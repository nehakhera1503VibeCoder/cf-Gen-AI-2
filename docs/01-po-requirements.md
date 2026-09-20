# Product Requirements Document

**Status:** Approved, Product Owner
**Date:** 2026-09-20

## 1. Purpose

This document is the binding scope and acceptance criteria for this
project — a template repo, so it currently carries one small worked
example (`REQ-001`) to demonstrate the convention. Replace this section's
content with your own project's purpose when you adopt this starter; see
`docs/05-ai-native-development-guide.md` §6.

## 2. Scope (current)

In scope: a single REST endpoint exposing basic service info, as a worked
example of the full PO → Tech Lead → Dev → QA cycle this template runs.

Out of scope (for this worked example — not a limitation of the template
itself): persistence, authentication, any business domain. Add your own
via the propose-new-work protocol (`docs/03-spec-driven-development-playbook.md`
§6) once you've replaced this example with your real requirements.

## 3. Personas

See `docs/00-roles-and-responsibilities.md`.

## 4. Functional Requirements

### FR-1 — Service info endpoint (`REQ-001`)

`GET /api/v1/info` returns the service's name, version, and status as
JSON, with no request parameters or authentication. Used as the worked
example for this template's process; also useful as a real health-check
endpoint in any project built from this starter.

## 5. Non-Functional Requirements

### NFR-1 — No external dependencies for the worked example (`REQ-001`)

The info endpoint returns values already known to the running process
(from `pom.xml`/`application.yml`), with no database, cache, or outbound
call — it should work the moment `mvn spring-boot:run` starts, with zero
configuration.

## 6. Acceptance Criteria

- [ ] `GET /api/v1/info` returns HTTP 200 with `name`, `version`, and
      `status` fields, where `status` is `"UP"`.
- [ ] `mvn test` passes, with real, run verification evidence recorded in
      the tracker.

## 7. Open Questions

None open as of `REQ-001`. Resolved:

- **Should `/api/v1/info` require authentication?** No — this template
  has no auth layer; a real project built from it can add one via a new
  `REQ-` if needed.
