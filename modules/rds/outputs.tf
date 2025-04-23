output "db_instance_endpoint" {
  description = "RDS 인스턴스 엔드포인트"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDS 인스턴스 주소"
  value       = aws_db_instance.main.address
}

output "db_instance_name" {
  description = "RDS 데이터베이스 이름"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS 데이터베이스 사용자 이름"
  value       = aws_db_instance.main.username
}

output "db_instance_port" {
  description = "RDS 데이터베이스 포트"
  value       = aws_db_instance.main.port
}
