# Work log

One short entry per work session: what I did, what I learned, what blocks me.
Newest first.

## 2026-11-24

- Found out: enabling IAM Identity Center creates an AWS Organization, and on the Free
  plan that upgrades the account and makes the Free Tier credits expire.
- Changed the login plan: IAM user with MFA and one CLI access key (aws-vault) for now;
  normal upgrade to the paid plan before EKS; Identity Center after that (ADR 0009).
- Next: configure the `vip` profile, apply the two bootstrap stacks.

## 2026-11-21 (afternoon)

- Decided to start with a single AWS account (ADR 0009). Multi-account (ADR 0007)
  stays the target for prod before real candidate data.
- Rewrote the bootstrap: `10-foundation` (state, ECR, GitHub OIDC, budgets) and
  `20-ci-roles` (plan/apply roles per environment, fenced by name prefix).
- Learned: how AWS Organizations, OUs, SCPs and OrganizationAccountAccessRole work,
  and how Terraform separates environments with modules + one folder and state file each.
- Next: set up CLI access, apply the two bootstrap stacks.

## 2026-11-21

- Created the repository layout, README and decision records 0001–0008.
- Wrote the first Terraform bootstrap (multi-account version).
