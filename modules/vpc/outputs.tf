output "vpc_id" {
  description = "생성된 VPC의 ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "퍼블릭 서브넷 ID 목록"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "프라이빗 서브넷 ID 목록"
  value       = [for subnet in aws_subnet.private : subnet.id]
} 