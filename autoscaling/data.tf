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

# Data source AMI
data "aws_ami" "linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.7.20250331.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
