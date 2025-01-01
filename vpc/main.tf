# Virtual private network
resource "aws_vpc" "private_network" {
  cidr_block           = var.address[0]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge({ Name = "${local.common_name}_vpc" }, local.tags)
}

# VPC private subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.private_cidr)

  cidr_block        = var.private_cidr[count.index]
  availability_zone = var.private_az[count.index]
  vpc_id            = aws_vpc.private_network.id

  tags = merge({ Name = join("", [local.common_name, "_vpc_privatesubnet_", count.index]) }, local.tags)
}

# VPC public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.private_network.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = var.public_az[count.index]

  tags = merge({ Name = join("", [local.common_name, "_vpc_publicsubnet_", count.index]) }, local.tags)
}

# EIP
resource "aws_eip" "vpc_eip" {
  domain = "vpc"
  tags   = merge({ Name = "${local.common_name}_vpc_eip" }, local.tags)
}

# Internet gateway
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.private_network.id
  tags   = merge({ Name = "${local.common_name}_vpc_igw" }, local.tags)
}

# Nat gateway
resource "aws_nat_gateway" "vpc_nat" {
  subnet_id     = aws_subnet.public_subnet[0].id
  allocation_id = aws_eip.vpc_eip.id

  tags = merge({ Name = "${local.common_name}_vpc_ngw" }, local.tags)
}

# Private route table
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.private_network.id

  route {
    cidr_block     = var.address[1]
    nat_gateway_id = aws_nat_gateway.vpc_nat.id
  }

  tags = merge({ Name = "${local.common_name}_vpc_private_rt" }, local.tags)
}

# Public route table
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.private_network.id

  route {
    cidr_block = var.address[1]
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = merge({ Name = "${local.common_name}_vpc_public_rt" }, local.tags)
}

# Private route table associations
resource "aws_route_table_association" "private_associations" {
  count = length(var.private_cidr)

  route_table_id = aws_route_table.private_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

# Public route table associations
resource "aws_route_table_association" "public_associations" {
  count = length(var.public_cidr)

  route_table_id = aws_route_table.public_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "logs_role" {
  name = "${local.common_name}_vpc_flowpub"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = "sts:AssumeRole"
          Principal = {
            Service = "vpc-flow-logs.amazonaws.com"
          }
        }
      ]
    }
  )

  tags = merge({ Name = "${local.common_name}_vpc_flowpub" }, local.tags)
}

# IAM role and policy for Flow Logs
resource "aws_iam_role_policy" "flow_role_policy" {
  role = aws_iam_role.logs_role.id
  name = "${local.common_name}_vpc_flow_rolepolicy"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Resource = "*"
          Effect   = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams"
          ]
        }
      ]
    }
  )
}

# Cloudwatch group
resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "${local.common_name}_vpc_cwlg"
  retention_in_days = 7
}

# VPC Flow log
resource "aws_flow_log" "vpc_flow_log" {
  vpc_id          = aws_vpc.private_network.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.logs_role.arn
  log_destination = aws_cloudwatch_log_group.loggroup.arn

  depends_on = [aws_cloudwatch_log_group.loggroup]
}
