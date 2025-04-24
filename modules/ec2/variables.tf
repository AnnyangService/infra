variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID"
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
  default     = "t2.micro"
}

variable "associate_public_ip" {
  description = "퍼블릭 IP 할당 여부"
  type        = bool
  default     = false
}

variable "security_group_id" {
  description = "EC2 인스턴스에 적용할 보안 그룹 ID"
  type        = string
}
