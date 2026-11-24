output "github_terraform_roles" {
  description = "Role ARNs for the Terraform workflows."
  value = {
    for env, roles in module.roles : env => {
      plan  = roles.plan_role_arn
      apply = roles.apply_role_arn
    }
  }
}
