# Instance private key
resource "tls_private_key" "private_key" {
  rsa_bits  = 4096
  algorithm = "RSA"
}

# Instance login key
resource "aws_key_pair" "key" {
  key_name   = "askey"
  public_key = tls_private_key.private_key.public_key_openssh
}

# Instance key file
resource "local_file" "keyfile" {
  filename = "askeyfile"
  content  = tls_private_key.private_key.private_key_pem
}

# Load balancer security group
resource "aws_security_group" "loadbalancer_group" {
  name   = "${local.common_name}_elb_sg"
  vpc_id = data.aws_vpc.network.id

  dynamic "ingress" {
    for_each = var.security_rule_elb
    content {
      to_port     = ingress.value["port"]
      from_port   = ingress.value["port"]
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${local.common_name}_elb_sg"
  }
}

# EC2 security group
resource "aws_security_group" "ec2_security_group" {
  name   = "${local.common_name}_ec2_sg"
  vpc_id = data.aws_vpc.network.id

  dynamic "ingress" {
    for_each = var.security_rule_elb
    content {
      description     = ingress.value.description
      protocol        = "tcp"
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      security_groups = [aws_security_group.loadbalancer_group.id]
    }
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
  }

  tags = {
    "Name" = "${local.common_name}_ec2_sg"
  }
}
