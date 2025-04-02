output "elb_security_group_id" {
  value       = aws_security_group.loadbalancer_group.id
  description = "ID for loadbalancer security group"
}
