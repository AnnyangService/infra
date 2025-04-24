output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "EC2 인스턴스의 퍼블릭 IP"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "EC2 인스턴스의 프라이빗 IP"
  value       = aws_instance.main.private_ip
}

output "private_key_path" {
  description = "로컬에 저장된 프라이빗 키 경로"
  value       = local.key_file_path
}

output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = "ssh -i ${local.key_file_path} ec2-user@${aws_instance.main.public_ip}"
} 