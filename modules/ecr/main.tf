resource "aws_ecr_repository" "ai_server" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = var.repository_name
    Environment = var.environment
  }
}

# ECR 저장소 정책 설정 (선택적)
resource "aws_ecr_repository_policy" "ai_server_policy" {
  repository = aws_ecr_repository.ai_server.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowPushPull",
        Effect = "Allow",
        Principal = {
          "AWS" : var.principal_arns
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# ECR 수명주기 정책 설정 (선택적)
resource "aws_ecr_lifecycle_policy" "ai_server_lifecycle_policy" {
  repository = aws_ecr_repository.ai_server.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep only the last 30 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = var.max_image_count
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
