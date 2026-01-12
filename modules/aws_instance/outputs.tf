output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.this[*].id
}

output "instance_private_ips" {
  description = "Private IP addresses of the instances"
  value       = aws_instance.this[*].private_ip
}
