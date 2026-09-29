output "vpc_id" {
  description = "Application VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs used by the ALBs"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by ECS tasks"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "frontend_alb_dns_names" {
  description = "Frontend ALB DNS names by environment"
  value = {
    for env, alb in aws_lb.frontend : env => alb.dns_name
  }
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value = {
    for key, repo in aws_ecr_repository.app : key => repo.repository_url
  }
}
