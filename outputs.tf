output "ssh_command" {
  description = "EC2 instance SSH 접속 명령어"
  value       = module.ec2.ssh_command
}

output "mysql_connection_command" {
  description = "MariaDB 접속 명령어"
  value       = "mysql -h ${module.rds.db_instance_address} -P ${module.rds.db_instance_port} -u ${module.rds.db_instance_username} -p"
}

output "alb_dns_name" {
  description = "ALB DNS 이름 (외부 DNS 설정에 필요)"
  value       = module.alb.alb_dns_name
}

# AI 서버 관련 출력값 추가
output "ai_server_private_ip" {
  description = "AI 서버 프라이빗 IP 주소"
  value       = module.ec2-ai.private_ip
}

output "ai_server_ssh_command" {
  description = "AI 서버 SSH 접속 명령어 (API 서버를 통한 터널링 필요)"
  value       = module.ec2-ai.ssh_command
}

# 프론트엔드 관련 출력값 추가
output "frontend_s3_bucket" {
  description = "프론트엔드 S3 버킷 이름"
  value       = module.frontend.s3_bucket_id
}

output "frontend_cloudfront_domain" {
  description = "프론트엔드 CloudFront 도메인 이름"
  value       = module.frontend.cloudfront_distribution_domain_name
}

# ECR 저장소 관련 출력값 추가
output "ecr_ai_server_repository_url" {
  description = "AI 서버 ECR 저장소 URL"
  value       = module.ecr_ai_server.repository_url
}

output "ecr_push_commands" {
  description = "ECR 로그인 및 이미지 푸시 명령어 예시"
  value       = <<-EOT
    # AWS ECR 로그인
    aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${module.ecr_ai_server.repository_url}
    
    # Docker 이미지 태깅
    docker tag ai-server:latest ${module.ecr_ai_server.repository_url}:latest
    
    # Docker 이미지 푸시
    docker push ${module.ecr_ai_server.repository_url}:latest
  EOT
}
