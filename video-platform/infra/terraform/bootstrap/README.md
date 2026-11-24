# AWS bootstrap (single account)

One-time setup of the AWS foundation in **one AWS account** (ADR 0009), on the AWS Free
plan. Run from your laptop, in order. Everything after step 1 is Terraform.

| Stack | Creates |
| --- | --- |
| `10-foundation` | Terraform state bucket, ECR repositories, GitHub OIDC provider, `github-build` role, budgets (account + per environment), account-wide S3 public access block and EBS encryption |
| `20-ci-roles` | Per environment: `github-terraform-plan-<env>` and `github-terraform-apply-<env>`, each fenced away from the other environments |

Cost: close to zero (cents per month for the bucket and ECR). AWS Budgets charges a
small daily fee for each budget beyond the first two; check current pricing.

## How three environments share one account

- **Names:** every resource of an environment starts with `vip-<env>`, for example
  `vip-dev-media`, `vip-prod-db`. The CI roles rely on this.
- **Tags:** every resource carries `Environment = dev | staging | prod` (set with
  `default_tags` in each stack). Budgets and the cost report use it.
- **Networks:** one VPC per environment (10.10/16, 10.20/16, 10.30/16).
- **State:** one bucket, one file per environment: `envs/<env>/terraform.tfstate`.
- **CI roles:** dev and staging roles are denied anything named for another environment,
  other environments' state files, and the CI roles themselves. Prod apply runs only from
  the GitHub `production` environment, after your approval.

## Before you start

- AWS CLI v2 and Terraform >= 1.10 installed
- Your AWS account, root user with MFA and **no root access keys**
- Optional but recommended: [aws-vault](https://github.com/99designs/aws-vault) to keep
  your access key encrypted instead of in plain text

## Free plan: do NOT enable IAM Identity Center or AWS Organizations yet

The account is on the AWS **Free plan** with Free Tier credits. Joining or creating an
AWS Organization – which enabling IAM Identity Center does – upgrades the account to the
paid plan and makes the remaining credits expire immediately. So for now you log in with
an IAM user. See "Later: paid plan and IAM Identity Center" at the end.

## Step 1 – CLI access with your IAM user (manual, about 10 minutes)

In the console, as your IAM user (not root):

1. **IAM → Users → your user**: MFA is assigned, and the user has the
   `AdministratorAccess` policy (directly or through a group).
2. **Security credentials → Create access key → Command Line Interface (CLI)**.
   Copy the key ID and secret; the secret is shown only once.
3. If root has access keys (root → Security credentials), delete them.

Configure the `vip` profile that every stack uses:

```bash
aws configure --profile vip
#   AWS Access Key ID:     from step 2
#   AWS Secret Access Key: from step 2
#   Default region name:   eu-central-1
#   Default output format: json
aws sts get-caller-identity --profile vip
```

Or, with aws-vault (the key is stored encrypted in your system keychain):

```bash
aws-vault add vip                                   # paste key ID and secret
aws-vault exec vip -- aws sts get-caller-identity
aws-vault exec vip -- terraform plan                # how you then run Terraform
```

With aws-vault, Terraform must read the credentials from the environment instead of a
profile. Two small changes:

- in each stack's `terraform.tfvars`, add `aws_profile = null`
- in `backend.hcl`, delete the `profile = "vip"` line

Rules for the access key:

- Never put it in the repo, a ticket, a chat or a screenshot.
- Rotate it every 90 days (create the new key, switch, delete the old one).
- GitHub Actions never uses it: CI logs in with OIDC roles (stacks 10 and 20).

## Step 2 – foundation

```bash
cd infra/terraform/bootstrap/10-foundation
cp terraform.tfvars.example terraform.tfvars   # your GitHub repo and alert e-mail
terraform init
terraform plan
terraform apply
terraform output
```

Create `backend.hcl` and move this stack's state into the new bucket:

```bash
cp ../backend.hcl.example ../backend.hcl       # put the state_bucket output into it
mv backend.tf.disabled backend.tf
terraform init -migrate-state -backend-config=../backend.hcl
rm -f terraform.tfstate terraform.tfstate.backup   # after the copy succeeded
```

## Step 3 – CI roles

```bash
cd ../20-ci-roles
cp terraform.tfvars.example terraform.tfvars   # values from the 10-foundation outputs
terraform init -backend-config=../backend.hcl
terraform apply
```

In GitHub → **Settings → Environments**, create `dev`, `staging` and `production`.
Add yourself as a required reviewer on `production`.

## Step 4 – check that it works

```bash
aws s3 ls --profile vip | grep tfstate
aws ecr describe-repositories --profile vip --query "repositories[].repositoryName"
aws iam list-roles --profile vip --query "Roles[?starts_with(RoleName, 'github-')].RoleName"
```

## A day later

Once resources with the `Environment` tag exist, activate it for billing so the
per-environment budgets work: set `activate_cost_allocation_tag = true` in
`10-foundation/terraform.tfvars` and apply again.

## Later: paid plan and IAM Identity Center

The Free plan ends after 6 months or when the credits are used up, and then the account
closes unless it is upgraded. EKS (from weeks 5–8) uses credits quickly, so:

1. **Before creating EKS: upgrade the normal way** (Billing → Upgrade plan). Remaining
   Free Tier credits then keep applying to your bills until they expire.
2. **After the credits are used (or before M2): enable IAM Identity Center** and switch the
   `vip` profile to `aws configure sso`. Ask AWS billing support first whether enabling
   Organizations on the paid plan affects leftover credits.
3. **Then delete the IAM user's access key.** From then on, nobody uses long-lived keys.

## Moving to separate accounts later

Before real candidate data arrives (M2) or the first customer, prod should move to its
own account. Because every environment already has its own VPC, names, tags and state
file, that means: create the account, point `envs/prod` at it, and restore the database
from a snapshot. The multi-account design is described in ADR 0007.
