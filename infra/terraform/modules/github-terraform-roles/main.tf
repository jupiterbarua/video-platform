# Two GitHub Actions roles for one environment, both through OIDC:
#   github-terraform-plan-<env>   read-only, runs `terraform plan` on pull requests
#   github-terraform-apply-<env>  admin, runs `terraform apply` from a GitHub Environment
#
# All environments share one AWS account (ADR 0009), so each role is fenced in:
# it may not touch resources named for another environment, the other
# environments' state files, or the CI roles themselves.
# This stops accidents; it is not a hard security boundary like separate accounts.
# Rule for every stack: names start with <name_prefix>-<environment>, e.g. vip-dev-media.

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

locals {
  other_environments = [for env in var.all_environments : env if env != var.environment]

  # ARN patterns of resources that belong to other environments.
  other_environment_arns = flatten([
    for env in local.other_environments : [
      "arn:aws:*:*:*:*${var.name_prefix}-${env}*",
      "arn:aws:s3:::${var.name_prefix}-${env}*",
    ]
  ])

  # State files this role must never read or change.
  foreign_state_arns = concat(
    [for env in local.other_environments : "arn:aws:s3:::${var.state_bucket}/envs/${env}/*"],
    ["arn:aws:s3:::${var.state_bucket}/bootstrap/*"],
  )
}

data "aws_iam_policy_document" "trust" {
  for_each = {
    plan  = var.plan_subjects
    apply = var.apply_subjects
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = each.value
    }
  }
}

# Applies to both roles.
data "aws_iam_policy_document" "fence" {
  statement {
    sid       = "DenyOtherEnvironments"
    effect    = "Deny"
    actions   = ["*"]
    resources = local.other_environment_arns
  }

  statement {
    sid       = "DenyForeignState"
    effect    = "Deny"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = local.foreign_state_arns
  }

  statement {
    sid    = "DenyChangingCiRoles"
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
    ]
    resources = ["arn:aws:iam::*:role/github-*"]
  }

  statement {
    sid       = "DenyChangingOidcProvider"
    effect    = "Deny"
    actions   = ["iam:*OpenIDConnectProvider*"]
    resources = ["*"]
  }
}

# Plan writes a lock file next to its own state.
data "aws_iam_policy_document" "own_state" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket}/envs/${var.environment}/*"]
  }
}

# --- plan role --------------------------------------------------------------

resource "aws_iam_role" "plan" {
  name                 = "github-terraform-plan-${var.environment}"
  description          = "GitHub Actions: terraform plan in ${var.environment} (read-only)."
  assume_role_policy   = data.aws_iam_policy_document.trust["plan"].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "plan_state" {
  name   = "own-state"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.own_state.json
}

resource "aws_iam_role_policy" "plan_fence" {
  name   = "environment-fence"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.fence.json
}

# --- apply role -------------------------------------------------------------

resource "aws_iam_role" "apply" {
  name                 = "github-terraform-apply-${var.environment}"
  description          = "GitHub Actions: terraform apply in ${var.environment}."
  assume_role_policy   = data.aws_iam_policy_document.trust["apply"].json
  max_session_duration = 3600
}

# AdministratorAccess as a starting point, limited by the fence below.
# Narrow it once the envs stacks are stable.
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy" "apply_fence" {
  name   = "environment-fence"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.fence.json
}
