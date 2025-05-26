variable "repository_name" {
  description = "ECR 저장소 이름"
  type        = string
  default     = "ai-server"
}

variable "image_tag_mutability" {
  description = "이미지 태그 변경 가능 여부 (MUTABLE 또는 IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "이미지 푸시 시 자동 스캔 설정"
  type        = bool
  default     = true
}

variable "environment" {
  description = "환경 설정 (개발, 운영 등)"
  type        = string
  default     = "production"
}

variable "max_image_count" {
  description = "보관할 최대 이미지 개수"
  type        = number
  default     = 30
}

variable "principal_arns" {
  description = "ECR에 접근할 수 있는 IAM 사용자/역할의 ARN 리스트"
  type        = list(string)
  default     = ["*"]
}
