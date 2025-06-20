output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = data.aws_s3_bucket.images.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = data.aws_s3_bucket.images.arn
}

output "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = data.aws_s3_bucket.images.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = data.aws_s3_bucket.images.bucket_regional_domain_name
}
