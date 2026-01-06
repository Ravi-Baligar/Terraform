############################################
# ALB Outputs
############################################
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_sg_id" {
  description = "Security Group ID for ALB"
  value       = aws_security_group.alb_sg.id
}

############################################
# Target Group Outputs
############################################
output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.app_tg.arn
}

############################################
# ASG Outputs
############################################
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}

############################################
# App Security Group
############################################
output "app_sg_id" {
  description = "Security Group ID for app instances"
  value       = aws_security_group.app_sg.id
}
