output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "state_bucket" {
  description = "Put this into infra/terraform/bootstrap/backend.hcl."
  value       = aws_s3_bucket.state.bucket
}

output "github_oidc_provider_arn" {
  description = "Input for stack 20-ci-roles."
  value       = aws_iam_openid_connect_provider.github.arn
}

output "ecr_repository_urls" {
  value = { for name, repo in aws_ecr_repository.service : name => repo.repository_url }
}

output "github_build_role_arn" {
  description = "Use in GitHub Actions: aws-actions/configure-aws-credentials role-to-assume."
  value       = aws_iam_role.github_build.arn
}
