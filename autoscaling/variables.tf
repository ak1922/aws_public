variable "vpc_name" {
  type = string
  description = "Name of AWS VPC for autoscaling group"
}

variable "public_subnets" {
  type = list(string)
  description = "List of public subnets from VPC"
}

variable "private_subnets" {
  type = list(string)
  description = "List of private subnets from VPC"
}

variable "instance_type" {
  type = string
  description = "Type of EC2 instance."
}

variable "region" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "key_name" {
  type = string
  description = "Name of instance key for logins"
}
