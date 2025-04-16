variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "서브넷 ID"
  type        = string
}

variable "ami_id" {
  description = "EC2 인스턴스의 AMI ID"
  type        = string
  default     = "ami-0c9c942bd7bf113a2"  # Amazon Linux 2 AMI in ap-northeast-2
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_cidr_blocks" {
  description = "SSH 접근을 허용할 CIDR 블록 목록"
  type        = list(string)
  default     = []  # 기본값은 빈 리스트로 설정
}

variable "associate_public_ip" {
  description = "퍼블릭 IP 할당 여부"
  type        = bool
  default     = false
} 