# AWS bootstrap (single account)

One-time setup of the AWS foundation in **one AWS account** (ADR 0009). Run from your
laptop, in order. Everything after step 1 is Terraform.

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
- Your AWS account, root user with MFA and **no access keys**

## Step 1 – log in without access keys (manual, about 15 minutes)

IAM Identity Center gives you a login with MFA and short-lived credentials. Enabling it
creates an AWS Organization that contains only your account; that is free and adds no
accounts. Signed in as root:

1. Switch the console region to **Europe (Frankfurt) eu-central-1**.
2. Open **IAM Identity Center** → **Enable** (with AWS Organizations).
3. **Users** → add yourself and set up MFA.
4. **Permission sets** → create the predefined `AdministratorAccess` permission set.
5. **AWS accounts** → select your account → assign your user with `AdministratorAccess`.
6. Note the **AWS access portal URL** (`https://d-xxxxxxxxxx.awsapps.com/start`).
7. Sign out of root and stop using it.

```bash
aws configure sso --profile vip
#   SSO session name: vip
#   SSO start URL:    https://d-xxxxxxxxxx.awsapps.com/start
#   SSO region:       eu-central-1
#   choose your account, AdministratorAccess, region eu-central-1
aws sso login --sso-session vip
aws sts get-caller-identity --profile vip
```

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

## Moving to separate accounts later

Before real candidate data arrives (M2) or the first customer, prod should move to its
own account. Because every environment already has its own VPC, names, tags and state
file, that means: create the account, point `envs/prod` at it, and restore the database
from a snapshot. The multi-account design is described in ADR 0007.
