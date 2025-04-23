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
  project_name = "annyang"  # 프로젝트 이름 변경
}

# SSM Parameter Store에서 RDS 비밀번호 가져오기
# 이 파라미터는 이미 생성되어 있어야 함 - AWS 콘솔에서 생성 가능
data "aws_ssm_parameter" "db_password" {
  name = "/db/password"  # 경로 변경
  # 파라미터가 없는 경우 자동으로 생성
  depends_on = [aws_ssm_parameter.db_password]
}

# SSM Parameter Store에 RDS 비밀번호 생성 (없는 경우)
resource "aws_ssm_parameter" "db_password" {
  name  = "/db/password"  # 경로 변경
  type  = "SecureString"
  value = "Password123!"  # 초기값 설정 - 나중에 AWS 콘솔에서 변경 가능
  
  # 존재하는 경우 덮어쓰지 않도록 설정
  lifecycle {
    ignore_changes = [value]
  }
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
  password          = data.aws_ssm_parameter.db_password.value
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