variable "region" {
  type        = string
  description = "AWS region for resources."
}

variable "dept" {
  type        = string
  description = "Name of department for this project"
}

variable "owner" {
  type        = string
  description = "Name of project Team"
}

variable "env" {
  type        = string
  description = "Environment for project e.g. prod, dev"
}
