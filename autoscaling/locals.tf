# Project tags
locals {
  tags = {
    environment       = var.environment
    repository        = "aws_public"
    repository_branch = "autoscaling"
    depolyed_by       = data.aws_caller_identity.current.arn
  }

  comman_name = lower(join("", [substr(var.department, 0, 3), var.environment]))
}

locals {
  group_port = {
    ssh = {
      port        = 22
      description = "Allow inbound access for SSH"
    }

    http = {
      port        = 80
      description = "Allow inbound access for HTTP"
    }
  }
}
