# Locals block for project tags.
locals {
  tags = {
    managed_by  = "Terraform"
    application = var.app
    team_owner  = var.owner
    environment = var.env
  }

  common_name = join("", [substr(var.app, 0, 4), var.env, "asapp"])
}
