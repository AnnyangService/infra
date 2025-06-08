# 기존 S3 버킷을 가져오는 data source
data "aws_s3_bucket" "images" {
  bucket = "${var.project_name}-images"
}

/**
# S3 버킷 최초 생성 시에는 아래 리소스들을 사용하여 설정할 수 있습니다.

resource "aws_s3_bucket" "images" {
  bucket = "${var.project_name}-images"

  tags = {
    Name = "${var.project_name}-images"
  }
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket = aws_s3_bucket.images.id

  block_public_acls       = false  # 이미지 직접 접근을 위해 퍼블릭 접근 허용
  block_public_policy     = false  # 이미지 직접 접근을 위해 퍼블릭 정책 허용
  ignore_public_acls      = false  # 이미지 직접 접근을 위해 퍼블릭 ACL 허용
  restrict_public_buckets = false  # 이미지 직접 접근을 위해 퍼블릭 버킷 허용
}

resource "aws_s3_bucket_ownership_controls" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    object_ownership = "BucketOwnerPreferred"  # ACL 사용 가능하도록 변경
  }
}

resource "aws_s3_bucket_versioning" "images" {
  bucket = aws_s3_bucket.images.id
  versioning_configuration {
    status = "Enabled"  # 파일 버전 관리 유지
  }
}

# 버킷을 퍼블릭으로 설정 (직접 이미지 URL에 접근하기 위해)
resource "aws_s3_bucket_acl" "images" {
  bucket = aws_s3_bucket.images.id
  acl    = "public-read"  # 읽기만 퍼블릭으로 설정
  depends_on = [
    aws_s3_bucket_ownership_controls.images,
    aws_s3_bucket_public_access_block.images
  ]
}

# 웹 애플리케이션에서 이미지 접근을 위한 CORS 설정
resource "aws_s3_bucket_cors_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["*"]  # 프로덕션 환경에서는 특정 도메인으로 제한하는 것이 좋습니다
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
*/
