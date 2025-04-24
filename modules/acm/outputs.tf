output "certificate_arn" {
  description = "메인 도메인 인증서 ARN"
  value       = data.aws_acm_certificate.main_domain.arn
}

output "certificate_id" {
  description = "메인 도메인 인증서 ID"
  value       = data.aws_acm_certificate.main_domain.id
}

output "wildcard_certificate_arn" {
  description = "와일드카드 도메인 인증서 ARN"
  value       = data.aws_acm_certificate.wildcard_domain.arn
}

output "wildcard_certificate_id" {
  description = "와일드카드 도메인 인증서 ID"
  value       = data.aws_acm_certificate.wildcard_domain.id
}