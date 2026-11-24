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
  description = "Every resource name starts with <name_prefix>-<environment>, e.g. vip-dev-media."
  type        = string
  default     = "vip"
}

variable "github_repository" {
  description = "The app repository as owner/name."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "Use the form owner/name."
  }
}

variable "services" {
  description = "One ECR repository per service. M1 needs these three; add the rest when their milestone starts."
  type        = list(string)
  default = [
    "core-api",
    "ai-service",
    "question-video-generator",
  ]
}

variable "images_to_keep" {
  type    = number
  default = 50
}

variable "noncurrent_version_days" {
  description = "How long old versions of state files are kept."
  type        = number
  default     = 90
}

variable "budget_alert_emails" {
  type = list(string)
}

variable "budget_limits_usd" {
  description = "Monthly budgets: the whole account, and per environment (by the Environment tag)."
  type        = map(number)
  default = {
    account = 250
    dev     = 30
    staging = 60
    prod    = 150
  }
}

variable "activate_cost_allocation_tag" {
  description = "Activate the Environment tag for billing. Set to true only after resources with this tag have existed for about a day; AWS rejects unknown tags."
  type        = bool
  default     = false
}
