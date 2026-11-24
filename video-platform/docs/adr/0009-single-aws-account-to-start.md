# 0009 – Start with a single AWS account

- Status: Accepted
- Date: 2026-11-21
- Supersedes: [0007](0007-aws-multi-account.md) for now

## Context

ADR 0007 planned five AWS accounts. For the first milestones there is one developer, no
customers and no real candidate data. Five accounts add setup work and make costs harder
to watch at the start.

## Decision

All environments run in one AWS account in eu-central-1, built so they can be split later:

- **Login, for now:** an IAM user with MFA and one CLI access key (ideally stored with
  aws-vault, rotated every 90 days). IAM Identity Center is **not** enabled yet: the
  account is on the AWS Free plan, and enabling it creates an AWS Organization, which
  upgrades the account to the paid plan and makes the Free Tier credits expire at once.
- **Login, later:** upgrade to the paid plan the normal way before EKS is created (credits
  carry over), then enable IAM Identity Center once the credits are used or before M2,
  and delete the access key.
- **CI:** GitHub Actions always uses OIDC roles, never access keys.
- **Separation inside the account:**
  - names start with `vip-<env>` and every resource is tagged `Environment`
  - one VPC per environment with non-overlapping ranges (10.10, 10.20, 10.30 /16)
  - one Terraform state file per environment
- **CI roles:** separate plan and apply roles per environment. Dev and staging roles are denied
  resources named for other environments, other state files and the CI roles. Prod apply
  needs approval in the GitHub `production` environment.
- **Safety in prod:** deletion protection on the database and cluster, `prevent_destroy` on
  data resources, S3 versioning, RDS backups.
- **Cost:** one budget for the account and one per environment (by tag).

## When to revisit

Move prod to its own account (following ADR 0007) before real candidate data arrives in
M2, or when the first customer signs up, whichever comes first.

## Consequences

- Faster start: two bootstrap stacks instead of four, no account e-mails to manage.
- Free Tier credits are kept for the first weeks.
- Until Identity Center is enabled, one long-lived access key exists on the laptop; it is
  the main credential risk and must be protected and rotated.
- Weaker isolation: an admin mistake can reach prod. The name fence on CI roles stops
  most accidents but is not a security boundary.
- Moving later is mostly configuration, because modules, names, networks and state are
  already per environment.
