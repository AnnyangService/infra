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

# CloudFront용 인증서 출력값 (us-east-1 리전)
output "cloudfront_certificate_arn" {
  description = "CloudFront용 인증서 ARN (us-east-1 리전)"
  value       = data.aws_acm_certificate.cloudfront_main_domain.arn
}