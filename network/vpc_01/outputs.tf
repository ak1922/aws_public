output "vpc_arn" {
  value       = aws_vpc.private_network.arn
  description = "ARN for vpc"
}

output "internet_gateway_arn" {
  value       = aws_internet_gateway.vpc_igw.arn
  description = "Internet gateway arn"
}
