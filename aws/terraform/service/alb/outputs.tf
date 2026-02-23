output "alb_id" {
  description = "ID of the ALB"
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Map of target group ARNs"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}

output "target_group_names" {
  description = "Map of target group names"
  value       = { for k, v in aws_lb_target_group.this : k => v.name }
}

output "listener_arns" {
  description = "Map of listener ARNs"
  value       = { for k, v in aws_lb_listener.this : k => v.arn }
}

