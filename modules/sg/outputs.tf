output "ec2_security_group_id" {
  description = "EC2 인스턴스용 보안 그룹 ID"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "RDS 인스턴스용 보안 그룹 ID"
  value       = aws_security_group.rds.id
}

output "alb_security_group_id" {
  description = "ALB용 보안 그룹 ID"
  value       = aws_security_group.alb.id
}

output "ai_server_security_group_id" {
  description = "AI 서버용 보안 그룹 ID"
  value       = aws_security_group.ai_server.id
}