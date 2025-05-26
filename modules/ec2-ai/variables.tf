variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID (프라이빗 서브넷 권장)"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스의 AMI ID"
  type        = string
  default     = "ami-0a463f27534bdf246"  # Amazon Linux 2023 AMI
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"  # 프리티어 적합하고 모든 가용 영역에서 지원되는 인스턴스 타입
}

variable "associate_public_ip" {
  description = "퍼블릭 IP 할당 여부"
  type        = bool
  default     = true  # NAT Gateway 비용을 절약하기 위해 퍼블릭 IP 할당하고 보안 그룹으로 제한
}

variable "security_group_id" {
  description = "EC2 인스턴스에 적용할 보안 그룹 ID"
  type        = string
}
