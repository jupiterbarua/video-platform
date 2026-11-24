variable "environment" {
  description = "dev, staging or prod."
  type        = string
}

variable "all_environments" {
  description = "Every environment in the account; the role is denied access to the others."
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "name_prefix" {
  description = "Resource names start with <name_prefix>-<environment>."
  type        = string
}

variable "state_bucket" {
  description = "Name of the Terraform state bucket."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (output of bootstrap/10-foundation)."
  type        = string
}

variable "plan_subjects" {
  description = "GitHub OIDC subjects allowed to assume the plan role."
  type        = list(string)
}

variable "apply_subjects" {
  description = "GitHub OIDC subjects allowed to assume the apply role."
  type        = list(string)
}
