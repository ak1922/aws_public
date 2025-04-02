# Locals block for project tags.
locals {
  tags = {
    managed_by  = "Terraform"
    department  = var.dept
    team_owner  = var.owner
    environment = var.env
  }
}
