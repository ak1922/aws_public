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
  name        = "${local.common_name}-targetgroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.network.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 7
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    "Name" = "${local.common_name}_targetgroup"
  }

  depends_on = [
    aws_lb.load_balancer
  ]
}

# Load balance listener
resource "aws_lb_listener" "listener" {
  port              = 80
  protocol          = "HTTP"
  load_balancer_arn = aws_lb.load_balancer.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }

  depends_on = [
    aws_lb_target_group.elb_target_group
  ]
}

# Auto scaling group
resource "aws_autoscaling_group" "scaling" {
  vpc_zone_identifier = var.private_subnets
  target_group_arns   = [aws_lb_target_group.elb_target_group.arn]
  max_size            = 2
  min_size            = 1
  desired_capacity    = 1

  launch_template {
    version = "$Latest"
    id      = aws_launch_template.template.id
  }
}

# Increase policy
resource "aws_autoscaling_policy" "uppolicy" {
  name                   = "uppolicy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.scaling.name
}

# Decrease policy
resource "aws_autoscaling_policy" "dowmpolicy" {
  name                   = "downpolicy"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.scaling.name
  policy_type            = "SimpleScaling"
}

# Scaling attachment
resource "aws_autoscaling_attachment" "attach" {
  autoscaling_group_name = aws_autoscaling_group.scaling.name
  lb_target_group_arn    = aws_lb_target_group.elb_target_group.arn
}
