output "s3_bucket_id" {
  description = "생성된 S3 버킷 ID"
  value       = aws_s3_bucket.frontend.id
}

output "s3_bucket_arn" {
  description = "생성된 S3 버킷 ARN"
  value       = aws_s3_bucket.frontend.arn
}

output "s3_bucket_domain_name" {
  description = "S3 버킷 도메인 이름"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront 배포 ID"
  value       = aws_cloudfront_distribution.frontend.id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront 도메인 이름"
  value       = aws_cloudfront_distribution.frontend.domain_name
}

output "cloudfront_distribution_arn" {
  description = "CloudFront 배포 ARN"
  value       = aws_cloudfront_distribution.frontend.arn
} 