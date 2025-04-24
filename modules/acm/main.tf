# 기존 메인 도메인 인증서 가져오기
data "aws_acm_certificate" "main_domain" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# 기존 와일드카드 도메인 인증서 가져오기
data "aws_acm_certificate" "wildcard_domain" {
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}