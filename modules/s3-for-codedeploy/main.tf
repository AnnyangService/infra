# 현재 AWS 계정 ID 가져오기
data "aws_caller_identity" "current" {}

# 현재 타임스탬프를 가져와 버킷 이름에 추가 (고유성 확보용)
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 애플리케이션 배포를 위한 S3 버킷
resource "aws_s3_bucket" "app_deploy" {
  bucket = "${var.project_name}-api-server-deploy-${data.aws_caller_identity.current.account_id}-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name = "${var.project_name}-api-server-deploy"
  }

  force_destroy = true
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
