variable "department" {
  type        = string
  description = "Name of your department"
}

variable "environment" {
  type        = string
  description = "Type of project environment, e.g. 'dev', 'qa', 'prod' for this project"
}

variable "project_owner" {
  type        = string
  description = "Name of your project Team."
}

variable "private_subnets" {
  type        = list(string)
  description = "List of IPs for private subnets"
}
variable "public_subnets" {
  type        = list(string)
  description = "List of IPs for public subnets"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for vpc"
}

variable "instance_type" {
  type        = string
  description = "Type of EC2 instance."
}

variable "region" {
  type        = string
  description = "AWS region where resources will be deployed"
}

variable "key_name" {
  type        = string
  description = "Name of instance key for logins"
}

variable "aws_zones" {
  type        = list(string)
  description = "Names of availability zones."
}
