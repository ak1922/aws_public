variable "address" {
  type        = list(string)
  description = "IP addresses for VPC and internet gateway."
}

variable "private_az" {
  type        = list(string)
  description = "Availability zones for private subnets."
}

variable "public_az" {
  type        = list(string)
  description = "Availability zones for public subnets."
}

variable "private_cidr" {
  type        = list(string)
  description = "IP addresses for private subnets."
}

variable "public_cidr" {
  type        = list(string)
  description = "IP addresses for private subnets."
}
