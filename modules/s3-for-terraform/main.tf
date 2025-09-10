# Terraform 상태 파일 저장을 위한 S3 버킷

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${var.project_name}-terraform-state"
  
#   tags = {
#     Name        = "${var.project_name}-terraform-state"
#     Purpose     = "Terraform Backend"
#     Environment = "prod"
#   }
# }

# # 암호화 설정
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# # 버킷 퍼블릭 액세스 차단 (보안 강화)
# resource "aws_s3_bucket_public_access_block" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }
