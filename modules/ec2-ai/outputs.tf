output "instance_id" {
  description = "AI 서버 EC2 인스턴스 ID"
  value       = aws_instance.ai_server.id
}

output "public_ip" {
  description = "AI 서버 EC2 인스턴스의 퍼블릭 IP"
  value       = aws_instance.ai_server.public_ip
}

output "private_ip" {
  description = "AI 서버 EC2 인스턴스의 프라이빗 IP"
  value       = aws_instance.ai_server.private_ip
}

output "ai_server_url" {
  description = "AI 서버 URL (API 서버 내부 통신용)"
  value       = "http://${aws_instance.ai_server.private_ip}:${var.port}"
}

output "key_pair_name" {
  description = "AI 서버 SSH 키 페어 이름"
  value       = aws_key_pair.key_pair.key_name
}

output "private_key_pem" {
  description = "AI 서버 프라이빗 키 (PEM 형식)"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}
