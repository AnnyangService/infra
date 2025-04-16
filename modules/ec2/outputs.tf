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