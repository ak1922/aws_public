# Launch template
resource "aws_launch_template" "template" {
  name                   = "${local.common_name}_launchtemplate"
  image_id               = data.aws_ami.linux_ami.id
  instance_type          = var.inst_type
  key_name               = "askey"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
  }
  tags = {
    "Name" = "${local.common_name}_launchtemplate"
  }
}

# Load balancer
resource "aws_lb" "load_balancer" {
  name                             = "${local.common_name}-lb"
  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  security_groups                  = [aws_security_group.loadbalancer_group.id]
  subnets                          = var.public_subnets

  depends_on = [
    aws_security_group.ec2_security_group,
    aws_security_group.loadbalancer_group
  ]

  tags = {
    "Name" = "${local.common_name}-lb"
  }
}

# Load balancer target group
resource "aws_lb_target_group" "elb_target_group" {

}
