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

# 프론트엔드 관련 출력값 추가
output "frontend_s3_bucket" {
  description = "프론트엔드 S3 버킷 이름"
  value       = module.frontend.s3_bucket_id
}

output "frontend_cloudfront_domain" {
  description = "프론트엔드 CloudFront 도메인 이름"
  value       = module.frontend.cloudfront_distribution_domain_name
}
