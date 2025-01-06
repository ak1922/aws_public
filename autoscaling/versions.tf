terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      managed_by = "Terraform"
      owner      = var.project_owner
      department = var.department
    }
  }
}
