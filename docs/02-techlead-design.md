# Tech Lead Design

**Status:** Approved, Tech Lead
**Date:** 2026-09-20

## 1. Overview

Minimal Spring Boot MVC service. Base package: `com.example.starter`.

## 2. Package layout

```
com.example.starter
├── StarterApplication.java     # @SpringBootApplication entry point
└── api/
    ├── InfoController.java     # REST layer
    └── dto/
        └── InfoResponseDto.java
```

As real requirements replace the worked example, follow this pattern:
`domain/` for entities, `repository/` for persistence interfaces,
`service/` for business logic, `api/` for controllers + DTOs,
`config/` for `@ConfigurationProperties` — the same layering used by
larger projects built from this starter, introduced only once a
requirement actually needs a layer (don't pre-create empty packages).

## 3. Design decisions

- **Version comes from `pom.xml`, not hardcoded.** `InfoController`
  reads `${project.version}`/`${project.artifactId}` injected via
  `application.yml` placeholders resolved from Maven's `pom.xml`
  properties at build time (`@Value`), so the info endpoint never drifts
  from the actual build. See `src/main/resources/application.yml`.
- **No Spring Actuator dependency for this worked example.** A one-field
  hardcoded `"UP"` status is intentionally trivial — this is a process
  worked example, not a real health-check implementation. A real project
  built from this starter should replace `FR-1` with Actuator's
  `/actuator/health` via a new `REQ-` instead of extending this
  hand-rolled endpoint.

## 4. API surface

| Method | Path | Request | Response | Notes |
|---|---|---|---|---|
| GET | `/api/v1/info` | none | `200 { name, version, status }` | `FR-1` |

## 5. Dev story breakdown

- **DEV-01**: `InfoResponseDto`, `InfoController`, `application.yml`
  wiring for name/version, unit test for the controller.

## 6. Testing strategy

One unit test (`@WebMvcTest` or a plain unit test calling the controller
directly) proving `FR-1`'s response shape, plus an independent QA pass
per `docs/00-roles-and-responsibilities.md`. As real requirements are
added, follow the same pattern: one unit test class per service/
controller, one full-stack (`@SpringBootTest` + `MockMvc` or
`TestRestTemplate`) test class covering the FRs end to end, per
`docs/03-spec-driven-development-playbook.md` §4's evidence convention.
