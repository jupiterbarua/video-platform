locals {
  repo = var.github_repository

  # Plan runs on every pull request and on main.
  plan_subjects = [
    "repo:${local.repo}:pull_request",
    "repo:${local.repo}:ref:refs/heads/main",
  ]

  # Apply runs only inside the GitHub Environment of the same name.
  # Protect "production" with yourself as required reviewer.
  environments = {
    dev     = "dev"
    staging = "staging"
    prod    = "production"
  }
}

module "roles" {
  source   = "../../modules/github-terraform-roles"
  for_each = local.environments

  environment       = each.key
  name_prefix       = var.name_prefix
  state_bucket      = var.state_bucket
  oidc_provider_arn = var.oidc_provider_arn
  plan_subjects     = local.plan_subjects
  apply_subjects    = ["repo:${local.repo}:environment:${each.value}"]
}
