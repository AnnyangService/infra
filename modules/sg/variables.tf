variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "admin_ip" {
  description = "관리자 IP 주소 (SSH 접근용)"
  type        = string
  default     = "0.0.0.0/0"  # 기본값은 모든 IP 허용, 실제 환경에서는 특정 IP로 제한 필요
} 