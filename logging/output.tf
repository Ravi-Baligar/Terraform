output "logs_bucket_name" {
  value       = aws_s3_bucket.alb_logs.bucket
  description = "S3 bucket for ALB and VPC Flow logs"
}