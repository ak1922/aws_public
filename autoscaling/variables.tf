variable "region" {
  type        = string
  description = "AWS region for resources."
}

variable "app" {
  type        = string
  description = "Name of application"
}

variable "owner" {
  type        = string
  description = "Name of project Team"
}

variable "env" {
  type        = string
  description = "Environment for project e.g. prod, dev, qa"

  validation {
    condition     = length(var.env) < 4
    error_message = "The variable env cannot have more than 4 charecters."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet ids from vpc"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet ids from vpc"
}

variable "inst_type" {
  type        = string
  description = "Instance type for launch template"
}

variable "security_rule_elb" {
  description = "Security group rule for security groups."
  type = list(object({
    port        = number
    description = string
  }))

  default = [
    {
      port        = 80
      description = "Allow http traffic"
    },
    {
      port        = 443
      description = "Allow https traffic"
    }
  ]
}

variable "image" {
  type        = string
  description = "AMI for launch template"
  default     = "ami-08a0d1e16fc3f61ea"
}
