output "instance_id" {
  description = "AI 서버 EC2 인스턴스 ID"
  value       = aws_instance.ai_server.id
}

output "private_ip" {
  description = "AI 서버 EC2 인스턴스의 프라이빗 IP"
  value       = aws_instance.ai_server.private_ip
}

output "ai_server_url" {
  description = "AI 서버 URL (퍼블릭 IP)"
  value       = "http://${aws_instance.ai_server.public_ip}:${var.port}"
}

output "ssh_command" {
  description = "SSH 접속 명령어 (API 서버를 통해 접속해야 함)"
  value       = "ssh -i ${local.key_file_path} ec2-user@${aws_instance.ai_server.public_ip}"
}
