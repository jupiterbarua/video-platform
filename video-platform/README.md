# Video Interview Platform

Asynchronous video interviews: a recruiter turns a job description into interview
questions with AI (as text and as generated question videos), invites candidates, and
gets back one merged video with transcripts. Candidates record their answers in the
browser, one question at a time.

Built as a portfolio project with a production setup: Rust services on Amazon EKS,
everything in Terraform, GitOps delivery with Argo CD, and dev, staging and prod
environments in Frankfurt (eu-central-1) – in one AWS account to start, built to be split
into separate accounts later (ADR 0009).

## Status

Sprint 1 of 9 – foundations. See the milestones below.

| Milestone | Scope | Live in prod |
| --- | --- | --- |
| M1 | Recruiter registration, AI questions from a job description, question videos | Week 8 |
| M2 | Candidate invite, recording, upload, validation | Week 12 |
| M3 | Transcode, transcribe, merge, recruiter review | Week 16 |
| M4 | GDPR delete and retention, monitoring, beta users | Week 18 |

## Repository layout

```
video-platform/
  services/            Rust services (core-api, ai-service, question-video-generator, ...)
  crates/              Shared Rust libraries (messaging, auth, telemetry, storage)
  web/                 recruiter-app and candidate-app (React + TypeScript)
  deploy/helm/         Helm charts for the services
  infra/terraform/
    bootstrap/         One-time AWS foundation: state bucket, ECR, CI roles
    modules/           Reusable modules (network, rds, eks, ...)  – Sprint 2+
    envs/              dev, staging, prod stacks                  – Sprint 2+
  docs/
    adr/               Architecture decision records
    log.md             Work log
  .github/workflows/   CI
```

Deployments live in a second repository, `video-platform-gitops`, watched by Argo CD
(see ADR 0006). It is created in Phase 4 (weeks 5–6).

## Getting started

1. Read the decision records in [`docs/adr`](docs/adr).
2. Set up the AWS foundation: [`infra/terraform/bootstrap/README.md`](infra/terraform/bootstrap/README.md).
3. Install the pre-commit hooks: `pip install pre-commit && pre-commit install`.

## Planning documents

The full plans (development plan, DevOps roadmap, microservice and infrastructure
architecture) are kept outside this repo and summarised in the ADRs.

## Architecture in one paragraph

Browsers reach four REST services through CloudFront, AWS WAF and an ALB. Services talk
to each other with events (SNS → SQS). Background workers – question video generator,
media worker, transcription worker – scale on queue depth with KEDA, down to zero.
A processing orchestrator owns the video pipeline from submit to ready. Each service owns
its own PostgreSQL schema. Candidates upload videos straight to S3 with presigned URLs.
