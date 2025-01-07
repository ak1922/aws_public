# AWS vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = "${local.comman_name}_vpc" }, local.tags)
}

# Private subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets)

  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.aws_zones[count.index]
  vpc_id            = aws_vpc.vpc.id

  tags = merge({ Name = "${local.comman_name}_vpc_publicsub_${count.index}" }, local.tags)
}

# Public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.private_subnets)

  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.aws_zones[count.index]

  tags = merge({ Name = "${local.comman_name}_vpc_privatesub_${count.index}" }, local.tags)
}

# Internet gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge({ Name = "${local.comman_name}_vpc_igw" }, local.tags)
}

# Public route table
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = merge({ Name = "${local.comman_name}_vpc_publicrt" }, local.tags)
}

# Public route table associations
resource "aws_route_table_association" "public_table_assoc" {
  count = length(var.public_subnets)

  route_table_id = aws_route_table.public_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# Elastic IP
resource "aws_eip" "vpc_eip01" {
  domain = "vpc"
  tags   = merge({ Name = "${local.comman_name}_vpc_eip01" }, local.tags)
}

# Nat Gateway
resource "aws_nat_gateway" "vpc_ngw" {
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.vpc_eip01.id

  tags = merge({ Name = "${local.comman_name}_vpc_ngw" }, local.tags)
}

# Private route table
resource "aws_route_table" "private_table" {
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpc_ngw.id
  }

  vpc_id = aws_vpc.vpc.id
  tags   = merge({ Name = "${local.comman_name}_vpc_privatert" }, local.tags)
}

# Private route table associations
resource "aws_route_table_association" "private_table_assoc" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_table.id
}

# Load balancer security group
resource "aws_security_group" "alb_group" {
  name        = "${local.comman_name}_alb_securitygroup"
  description = "Security group to allow inbound http and ssh access"
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = local.group_port
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.value["description"]
    }
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Autoscaling security group
resource "aws_security_group" "asg_group" {
  name        = "${local.comman_name}_asg_securitygorup"
  description = "Allow inbound access on port 80 for ALB security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    to_port         = 80
    from_port       = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_group.id]
    description     = "Allow access on port 80 for security group"
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
