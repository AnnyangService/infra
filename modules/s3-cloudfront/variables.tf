variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "frontend_domain_name" {
  description = "프론트엔드 사용자 정의 도메인 이름"
  type        = string
}

variable "certificate_arn" {
  description = "사용자 정의 도메인을 위한 ACM 인증서 ARN"
  type        = string
} 