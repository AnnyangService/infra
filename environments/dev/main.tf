terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

# 현재 IP 주소 가져오기 (사용자가 직접 구성해야 함)
data "http" "myip" {
  url = "https://api.ipify.org"
}

locals {
  my_ip = "${data.http.myip.response_body}/32"
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = "dev"
}

module "ec2" {
  source = "../../modules/ec2"

  project_name = "dev"
  vpc_id       = module.vpc.vpc_id
  subnet_id    = module.vpc.public_subnet_ids[0]
  allowed_ssh_cidr_blocks = [local.my_ip]  # 기본값은 빈 리스트로 설정 - 사용자가 직접 구성해야 함
  associate_public_ip     = true
}

# 출력값 정의
output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = module.ec2.ssh_command
} 