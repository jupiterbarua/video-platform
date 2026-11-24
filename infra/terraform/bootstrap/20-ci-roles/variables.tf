variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile (IAM Identity Center, AdministratorAccess)."
  type        = string
  default     = "vip"
}

variable "project" {
  type    = string
  default = "video-platform"
}

variable "name_prefix" {
  type    = string
  default = "vip"
}

variable "github_repository" {
  description = "The app repository as owner/name."
  type        = string
}

variable "state_bucket" {
  description = "Output state_bucket of stack 10-foundation."
  type        = string
}

variable "oidc_provider_arn" {
  description = "Output github_oidc_provider_arn of stack 10-foundation."
  type        = string
}
