# Project tags
locals {
  tags = {
    managed_by = "Terraform"
    gitrepo    = "aws_public"
    gitbranch  = "network"
    subbranch  = "network_vpc01"
  }

  common_name = trim(replace(local.tags.gitrepo, "_", ""), "lic")
}
