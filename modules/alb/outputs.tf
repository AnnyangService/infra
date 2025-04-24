output "alb_dns_name" {
  description = "ALB의 DNS 이름"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB의 Route 53 영역 ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ALB 대상 그룹 ARN"
  value       = aws_lb_target_group.main.arn
}

output "http_listener_arn" {
  description = "HTTP 리스너 ARN"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS 리스너 ARN"
  value       = aws_lb_listener.https.arn
}

output "acm_certificate_arn" {
  description = "메인 도메인 ACM 인증서 ARN"
  value       = data.aws_acm_certificate.main_domain.arn
}

output "acm_wildcard_certificate_arn" {
  description = "와일드카드 도메인 ACM 인증서 ARN"
  value       = data.aws_acm_certificate.wildcard_domain.arn
}
