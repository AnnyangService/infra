variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "ALB가 배포될 VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB가 배포될 퍼블릭 서브넷 ID 목록"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB에 할당할 보안 그룹 ID"
  type        = string
}

variable "instance_id" {
  description = "대상 그룹에 등록할 EC2 인스턴스 ID"
  type        = string
}

variable "target_port" {
  description = "대상 그룹이 트래픽을 전달할 포트"
  type        = number
}

variable "health_check_path" {
  description = "ALB 헬스 체크 경로"
  type        = string
}

variable "domain_name" {
  description = "ALB에 연결할 도메인 이름"
  type        = string
}
