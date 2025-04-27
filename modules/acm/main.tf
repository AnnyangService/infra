# 기존 메인 도메인 인증서 가져오기 (ap-northeast-2 리전)
data "aws_acm_certificate" "main_domain" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

# 기존 와일드카드 도메인 인증서 가져오기 (ap-northeast-2 리전)
data "aws_acm_certificate" "wildcard_domain" {
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

# CloudFront용 인증서 (us-east-1 리전)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# us-east-1 리전에서 기존 인증서 가져오기
data "aws_acm_certificate" "cloudfront_main_domain" {
  provider    = aws.us_east_1
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}