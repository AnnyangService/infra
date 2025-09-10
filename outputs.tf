# SSH 키를 Terraform 출력으로 제공 (필요시 추출 가능)
output "ec2_private_key_pem" {
  description = "API 서버 SSH 프라이빗 키 (임시 접속용)"
  value       = module.ec2.private_key_pem
  sensitive   = true
}

output "ai_server_private_key_pem" {
  description = "AI 서버 SSH 프라이빗 키 (임시 접속용)"
  value       = module.ec2-ai.private_key_pem
  sensitive   = true
}

# IP 주소 정보
output "ec2_public_ip" {
  description = "API 서버 퍼블릭 IP"
  value       = module.ec2.public_ip
}

output "ai_server_public_ip" {
  description = "AI 서버 퍼블릭 IP"
  value       = module.ec2-ai.public_ip
}

# SSM Parameter Store에서 SSH 키 접근 방법 안내
output "ssh_access_guide" {
  description = "SSH 접속 방법 안내 (SSM Parameter Store 활용)"
  value = {
    message = "SSH 키가 SSM Parameter Store에 안전하게 저장되었습니다."
    
    api_server_access = {
      step1 = "aws ssm get-parameter --name '/${local.project_name}/ec2/ssh/private-key' --with-decryption --query 'Parameter.Value' --output text > api_server.pem"
      step2 = "chmod 600 api_server.pem"
      step3 = "ssh -i api_server.pem ec2-user@${module.ec2.public_ip}"
      cleanup = "rm -f api_server.pem"
    }
    
    ai_server_access = {
      step1 = "aws ssm get-parameter --name '/${local.project_name}/ec2-ai/ssh/private-key' --with-decryption --query 'Parameter.Value' --output text > ai_server.pem"
      step2 = "chmod 600 ai_server.pem"
      step3 = "ssh -i ai_server.pem ec2-user@${module.ec2-ai.public_ip}"
      cleanup = "rm -f ai_server.pem"
    }
    
    connection_info = {
      api_server = "aws ssm get-parameter --name '/${local.project_name}/ec2/connection/info' --query 'Parameter.Value' --output text | jq ."
      ai_server = "aws ssm get-parameter --name '/${local.project_name}/ec2-ai/connection/info' --query 'Parameter.Value' --output text | jq ."
    }
    
    session_manager = {
      api_server = "aws ssm start-session --target ${module.ec2.instance_id}"
      ai_server = "aws ssm start-session --target ${module.ec2-ai.instance_id}"
    }
    
    note = "Session Manager를 사용하면 SSH 키 없이도 접속 가능합니다."
  }
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

# output "ai_server_ssh_command" {
#   description = "AI 서버 SSH 접속 명령어 (API 서버를 통한 터널링 필요)"
#   value       = module.ec2-ai.ssh_command
# }

# 프론트엔드 관련 출력값 추가
output "frontend_s3_bucket" {
  description = "프론트엔드 S3 버킷 이름"
  value       = module.frontend.s3_bucket_id
}

output "frontend_cloudfront_domain" {
  description = "프론트엔드 CloudFront 도메인 이름"
  value       = module.frontend.cloudfront_distribution_domain_name
}
