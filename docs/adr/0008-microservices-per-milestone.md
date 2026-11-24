# 0008 – Microservices added per milestone

- Status: Accepted
- Date: 2026-11-21

## Context

The target architecture has ten services. Building and running all ten from day one
would slow a single developer down without adding value early.

## Decision

Services are added when a milestone needs them; module boundaries come first:

| Milestone | Deployables |
| --- | --- |
| M1 | core-api (organization, question, interview, notification modules), ai-service, question-video-generator |
| M2 | + candidate-session, + media-worker (validate) |
| M3 | + orchestrator, + transcription-worker; media-worker gains transcode and merge |
| Later | Split core-api modules into services when one needs its own scaling or release pace |

Rules: one PostgreSQL schema and database user per module; modules talk through message
types or a Rust trait, never through each other's tables; events go through a
transactional outbox.

## Consequences

- Fewer deployables to run early, while later splits stay cheap.
- Discipline is needed to keep module boundaries inside core-api.
