# Data source aws vpc
data "aws_vpc" "network" {
  id = "vpc-01239247ef59e721f"
}

# Data source private subnets
data "aws_subnet" "private_subnetid" {
  for_each = toset(var.private_subnets)
  id       = each.value
}

# Data source public subnets
data "aws_subnet" "public_subnetid" {
  for_each = toset(var.public_subnets)
  id       = each.value
}
