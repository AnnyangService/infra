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

# 현재 IP 주소 가져오기
data "http" "myip" {
  url = "https://api.ipify.org"
}

locals {
  my_ip = "${data.http.myip.response_body}/32"
  project_name = "annyang"
}

module "vpc" {
  source = "./modules/vpc"

  project_name = local.project_name
}

# 보안 그룹 모듈 추가
module "sg" {
  source = "./modules/sg"

  project_name = local.project_name
  vpc_id       = module.vpc.vpc_id
  admin_ip     = local.my_ip  # 현재 IP 주소 전달
}

module "rds" {
  source = "./modules/rds"

  project_name = local.project_name
  subnet_ids   = module.vpc.private_subnet_ids
  
  # 보안 그룹 모듈에서 생성된 ID 사용
  rds_security_group_id = module.sg.rds_security_group_id
  
  # RDS 설정
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "mariadb"
  engine_version    = "10.6"
  instance_class    = "db.t3.micro"
  db_name           = "hi_meow"
  username          = "admin"
  password          = aws_ssm_parameter.db_password.value
  parameter_group_name = "default.mariadb10.6"
  multi_az          = false
}

module "ec2" {
  source = "./modules/ec2"

  project_name = local.project_name
  subnet_id    = module.vpc.public_subnet_ids[0]
  associate_public_ip = true
  
  # 보안 그룹 모듈에서 생성된 ID 사용
  security_group_id = module.sg.ec2_security_group_id
}

module "codedeploy" {
  source = "./modules/codedeploy"

  project_name = local.project_name
}

module "s3" {
  source = "./modules/s3"

  project_name = local.project_name
}

# 출력값 정의
output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = module.ec2.ssh_command
}

output "rds_endpoint" {
  description = "RDS 엔드포인트"
  value       = module.rds.db_instance_endpoint
}

output "mysql_connection_command" {
  description = "MariaDB 접속 명령어"
  value       = "mysql -h ${module.rds.db_instance_address} -P ${module.rds.db_instance_port} -u ${module.rds.db_instance_username} -p"
} 