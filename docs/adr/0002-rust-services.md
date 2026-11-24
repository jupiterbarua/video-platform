# 0002 – Rust for all backend services

- Status: Accepted
- Date: 2026-11-21

## Context

The platform needs REST services and CPU-heavy background workers that call ffmpeg and
AWS services. Rust is the main language of the author; C# is the alternative.

## Decision

All backend services and workers are written in Rust:

- Web framework: `axum` on `tokio`
- Database: PostgreSQL through `sqlx` (compile-time checked queries, migrations)
- AWS: official AWS SDK for Rust
- Observability: `tracing` + OpenTelemetry, Prometheus metrics
- One Cargo workspace; shared crates in `crates/`

## Consequences

- Small, fast container images (distroless) and low memory use, which matters on spot nodes.
- Slower compile times; CI needs dependency caching (`cargo-chef`, sccache).
- Fewer ready-made examples than for C#/.NET in some AWS areas.
