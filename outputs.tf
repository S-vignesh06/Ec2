output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app.dns_name
}

output "ec2_private_ip" {
  description = "Private IP of EC2"
  value       = aws_instance.app.private_ip
}

output "s3_bucket_name" {
  description = "S3 bucket used for application logs"
  value       = aws_s3_bucket.logs.bucket
}
