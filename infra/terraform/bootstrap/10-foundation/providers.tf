# Your single AWS account, through your IAM Identity Center admin profile.
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
