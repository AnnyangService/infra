# 애플리케이션 배포를 위한 S3 버킷
data "aws_s3_bucket" "app_deploy" {
  bucket = "${var.project_name}-for-codedeploy"
}

/**
# S3 버킷 최초 생성 시에는 아래 리소스들을 사용하여 설정할 수 있습니다.

resource "aws_s3_bucket" "app_deploy" {
  bucket = "${var.project_name}-for-codedeploy"
  
  tags = {
    Name = "${var.project_name}-for-codedeploy"
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
*/
