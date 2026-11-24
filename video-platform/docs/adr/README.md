# Architecture decision records

Short records of important decisions: the context, what was decided, and the consequences.
A decision is never edited after it is accepted; a new record supersedes it.

| # | Decision | Status |
| --- | --- | --- |
| [0001](0001-standard-video-format.md) | Standard video format: H.264 + AAC, 1280×720, 30 fps, 48 kHz, MP4 | Accepted |
| [0002](0002-rust-services.md) | Rust (axum, sqlx, tokio) for all backend services | Accepted |
| [0003](0003-react-typescript-frontends.md) | React + TypeScript for both web apps | Accepted |
| [0004](0004-cognito-authentication.md) | Amazon Cognito for recruiters; invite tokens for candidates | Accepted |
| [0005](0005-ai-services.md) | Bedrock for questions, Polly for question videos, Transcribe for answers | Accepted |
| [0006](0006-gitops-argo-cd.md) | GitOps delivery with Argo CD and a separate GitOps repo | Accepted |
| [0007](0007-aws-multi-account.md) | Five AWS accounts in eu-central-1, no long-lived keys | Superseded for now by 0009 (target setup) |
| [0008](0008-microservices-per-milestone.md) | Add microservices per milestone, start with three deployables | Accepted |
| [0009](0009-single-aws-account-to-start.md) | Start with one AWS account; split prod out before real data | Accepted |

New record: copy the format of an existing one, take the next number.
