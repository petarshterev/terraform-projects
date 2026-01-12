output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}