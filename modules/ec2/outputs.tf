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

output "key_pair_name" {
  description = "사용된 키 페어의 이름"
  value       = var.create_key_pair ? aws_key_pair.key_pair[0].key_name : var.key_name
}

output "private_key_path" {
  description = "로컬에 저장된 프라이빗 키 경로"
  value       = var.create_key_pair ? local_file.private_key[0].filename : "기존 키 사용 중"
}

output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = var.create_key_pair ? "ssh -i ${local_file.private_key[0].filename} ec2-user@${aws_instance.main.public_ip}" : "ssh -i <your-key-path> ec2-user@${aws_instance.main.public_ip}"
} 