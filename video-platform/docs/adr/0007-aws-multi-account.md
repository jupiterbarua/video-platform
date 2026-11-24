# 0007 – AWS multi-account setup in eu-central-1

- Status: Superseded for now by [0009](0009-single-aws-account-to-start.md); this is the target setup
- Date: 2026-11-21

## Context

The platform needs dev, staging and prod environments, a place for shared build
artifacts, and strong isolation of production candidate data.

## Decision

Five accounts in one AWS Organization:

| Account | Purpose |
| --- | --- |
| management | Organization, IAM Identity Center (SSO), billing, SCPs |
| shared | ECR images, Terraform state, GitHub build role |
| dev | One EC2 instance with k3s |
| staging | EKS, a smaller copy of prod |
| prod | EKS, real data |

- Region: eu-central-1 (Frankfurt). eu-west-1 is allowed for backup copies only.
  An SCP denies all other regions except for global services.
- People log in through IAM Identity Center; GitHub Actions through OIDC roles;
  pods through EKS Pod Identity. No long-lived access keys.
- All infrastructure is created with Terraform. The only manual steps are creating the
  management account and enabling IAM Identity Center (see the bootstrap README).

## Consequences

- A mistake in dev or staging cannot touch prod data.
- Images are built once in the shared account and promoted to every environment.
- More accounts to set up at the start; the bootstrap stacks automate it.
