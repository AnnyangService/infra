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
  description = "SSH 키 페어 이름"
  value       = aws_key_pair.key_pair.key_name
}

output "private_key_pem" {
  description = "프라이빗 키 (PEM 형식)"
  value       = tls_private_key.ssh.private_key_pem
  sensitive   = true
}