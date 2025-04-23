# 애플리케이션 배포를 위한 S3 버킷
resource "aws_s3_bucket" "app_deploy" {
  bucket = "${local.project_name}-api-server-deploy-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name = "${local.project_name}-api-server-deploy"
  }
}

# 버킷 액세스 관련 설정
resource "aws_s3_bucket_ownership_controls" "app_deploy" {
  bucket = aws_s3_bucket.app_deploy.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 버킷 액세스 블록 설정
resource "aws_s3_bucket_public_access_block" "app_deploy" {
  bucket = aws_s3_bucket.app_deploy.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "app_deploy" {
  bucket = aws_s3_bucket.app_deploy.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "app_deploy" {
  bucket = aws_s3_bucket.app_deploy.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 현재 AWS 계정 ID 가져오기
data "aws_caller_identity" "current" {}

# 출력값 정의
output "deployment_bucket" {
  description = "배포를 위한 S3 버킷 이름"
  value       = aws_s3_bucket.app_deploy.bucket
}

output "deployment_upload_command" {
  description = "배포 파일 업로드 명령어 예시"
  value       = "aws s3 cp your-app.zip s3://${aws_s3_bucket.app_deploy.bucket}/releases/your-app.zip"
} 