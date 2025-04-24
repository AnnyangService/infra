# 도메인 관련 출력
output "domain_name" {
  description = "애플리케이션 도메인 이름"
  value       = "hi-meow.kro.kr"
}

output "app_url_domain" {
  description = "도메인을 사용한 애플리케이션 접속 URL"
  value       = "https://hi-meow.kro.kr"
}

output "certificate_arn" {
  description = "메인 도메인 인증서 ARN"
  value       = module.alb.acm_certificate_arn
}

output "wildcard_certificate_arn" {
  description = "와일드카드 도메인 인증서 ARN"
  value       = module.alb.acm_wildcard_certificate_arn
} 