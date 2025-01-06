# Project tags
locals {
  tags = {
    managed_by = "Terraform"
    gitrepo    = "aws_public"
    gitbranch  = "autoscaling"
  }

  common_name = trim(replace(local.tags.gitrepo, "_", ""))
}
