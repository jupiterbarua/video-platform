# Work log

One short entry per work session: what I did, what I learned, what blocks me.
Newest first.

## 2026-11-21 (afternoon)

- Decided to start with a single AWS account (ADR 0009). Multi-account (ADR 0007)
  stays the target for prod before real candidate data.
- Rewrote the bootstrap: `10-foundation` (state, ECR, GitHub OIDC, budgets) and
  `20-ci-roles` (plan/apply roles per environment, fenced by name prefix).
- Learned: how AWS Organizations, OUs, SCPs and OrganizationAccountAccessRole work,
  and how Terraform separates environments with modules + one folder and state file each.
- Next: enable IAM Identity Center, apply the two bootstrap stacks.

## 2026-11-21

- Created the repository layout, README and decision records 0001–0008.
- Wrote the first Terraform bootstrap (multi-account version).
