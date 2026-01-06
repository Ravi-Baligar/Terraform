output "alb_dns_name" {
  description = "Public DNS of ALB"
  value       = module.compute.alb_dns_name
}

output "asg_name" {
  description = "Auto Scaling Group Name"
  value       = module.compute.asg_name
}

output "alr_arn" {
  value = module.compute.alb_arn
}
