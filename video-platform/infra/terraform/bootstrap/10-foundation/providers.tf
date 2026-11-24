# Your single AWS account, through the vip CLI profile (IAM user for now, see ADR 0009).
provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = var.project
      Environment = "shared"
      ManagedBy   = "terraform"
      Stack       = "bootstrap/10-foundation"
    }
  }
}

data "aws_caller_identity" "current" {}
