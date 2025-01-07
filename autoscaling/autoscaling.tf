terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}
# RSA private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Define key pair
resource "aws_key_pair" "keypair" {
  key_name   = "${local.comman_name}-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# Local file for private key
resource "local_file" "private_key" {
  filename = "${local.comman_name}-privatekey"
  content  = tls_private_key.rsa_key.private_key_pem
}

# Launch template
resource "aws_launch_template" "template" {
  name                   = "${local.comman_name}-lt"
  instance_type          = var.instance_type
  key_name               = "${local.comman_name}-key"
  image_id               = data.aws_ami.ami.id
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.alb_group.id]
  user_data              = file("apache.sh")
  tag_specifications {
    resource_type = "instance"
  }

  monitoring {
    enabled = true
  }
}

# Load balancer
resource "aws_lb" "load_balancer" {
  name               = "${local.comman_name}-lb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb_group.id]
  subnets            = [for i in aws_subnet.public_subnet : i.id]
}

# Target group
resource "aws_lb_target_group" "target_group" {
  port     = 80
  protocol = "HTTP"
  name     = "${local.comman_name}-tg"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    enabled             = true
    interval            = 300
    timeout             = 60
    matcher             = 200
    path                = "/"
    unhealthy_threshold = 5
    healthy_threshold   = 5
  }
}

# Load balancer listener
resource "aws_lb_listener" "lb_listener" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.load_balancer.id

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

# Autoscaling group
resource "aws_autoscaling_group" "scaling_group" {
  name                = "${local.comman_name}_asg"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 2
  force_delete        = true
  health_check_type   = "ELB"
  vpc_zone_identifier = [for i in aws_subnet.private_subnet : i.id]
  target_group_arns   = [aws_lb_target_group.target_group.arn]

  launch_template {
    id      = aws_launch_template.template.id
    version = aws_launch_template.template.latest_version
  }
}
