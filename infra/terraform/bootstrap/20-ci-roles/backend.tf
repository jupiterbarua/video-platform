# terraform init -backend-config=../backend.hcl
terraform {
  backend "s3" {
    key = "bootstrap/20-ci-roles.tfstate"
  }
}
