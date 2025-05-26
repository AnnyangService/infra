output "repository_url" {
  description = "ECR 저장소 URL"
  value       = aws_ecr_repository.ai_server.repository_url
}

output "repository_arn" {
  description = "ECR 저장소 ARN"
  value       = aws_ecr_repository.ai_server.arn
}

output "repository_name" {
  description = "ECR 저장소 이름"
  value       = aws_ecr_repository.ai_server.name
}
