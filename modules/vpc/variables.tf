variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type = map(object({
    az   = string
    cidr = string
  }))
  default = {
    "subnet-a" = {
      az   = "ap-northeast-2a"
      cidr = "10.0.1.0/24"
    }
    "subnet-b" = {
      az   = "ap-northeast-2b"
      cidr = "10.0.2.0/24"
    }
  }
}

variable "private_subnets" {
  type = map(object({
    az   = string
    cidr = string
  }))
  default = {
    "subnet-a" = {
      az   = "ap-northeast-2a"
      cidr = "10.0.3.0/24"
    }
    "subnet-b" = {
      az   = "ap-northeast-2b"
      cidr = "10.0.4.0/24"
    }
  }
}
