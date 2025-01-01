terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.47.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
  alias  = "source"
}

provider "aws" {
  region = "us-east-2"
  alias  = "dest"
}
