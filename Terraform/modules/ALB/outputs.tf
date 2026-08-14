output "target_group_arn" {
  description = "The ARN of the ALB target group for ECS service binding"
  value       = aws_lb_target_group.alb_tg.arn
}

output "alb_dns_name" {
  description = "The public DNS of the ALB"
  value       = aws_lb.main_alb.dns_name
}

output "alb_zone_id" {
  description = "ALB zone id so Route 53 can identify"
  value       = aws_lb.main_alb.zone_id
}

output "alb_security_group_id" {
  description = "The id of the ALB security Group"
  value       = aws_security_group.alb_sg.id
}
