# SSM Parameter Store에 RDS 비밀번호 생성
resource "aws_ssm_parameter" "db_password" {
  name  = "/${local.project_name}/db/password"
  type  = "SecureString"
  value = "initial-password"  # 초기값 설정 - 콘솔에서 변경 필요
  
  # 존재하는 경우 덮어쓰지 않도록 설정
  lifecycle {
    ignore_changes = [value]
  }
}

# 배포에 필요한 변수들을 AWS SSM Parameter Store에 저장
# DB_URL 파라미터 저장 - RDS 모듈에 의존
resource "aws_ssm_parameter" "db_url" {
  name  = "/${local.project_name}/db/url"
  type  = "String"
  value = "jdbc:mariadb://${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
  
  tags = {
    Name = "${local.project_name}-db-url"
  }
  
  # RDS 모듈이 완료된 후에만 생성
  depends_on = [module.rds]
}

# DB_USERNAME 파라미터 저장 - RDS 모듈에 의존
resource "aws_ssm_parameter" "db_username" {
  name  = "/${local.project_name}/db/username"
  type  = "String"
  value = module.rds.db_instance_username
  
  tags = {
    Name = "${local.project_name}-db-username"
  }
  
  # RDS 모듈이 완료된 후에만 생성
  depends_on = [module.rds]
}

# SSH_USER 파라미터 저장
resource "aws_ssm_parameter" "ssh_user" {
  name  = "/${local.project_name}/ssh/user"
  type  = "String"
  value = "ec2-user"  # Amazon Linux 2023의 기본 사용자명
  
  tags = {
    Name = "${local.project_name}-ssh-user"
  }
}

# S3 배포 버킷 파라미터 저장
resource "aws_ssm_parameter" "deployment_bucket" {
  name  = "/${local.project_name}/deploy/api-server/bucket"
  type  = "String"
  value = module.s3-for-codedeploy.deployment_bucket
  
  tags = {
    Name = "${local.project_name}-api-server-deployment-bucket"
  }
  
  depends_on = [module.s3-for-codedeploy]
}

# CodeDeploy 관련 SSM 파라미터 저장
resource "aws_ssm_parameter" "codedeploy_app" {
  name  = "/${local.project_name}/deploy/api-server/app_name"
  type  = "String"
  value = module.codedeploy.codedeploy_app_name
  
  tags = {
    Name = "${local.project_name}-codedeploy-api-server-app"
  }
  
  depends_on = [module.codedeploy]
}

resource "aws_ssm_parameter" "codedeploy_group" {
  name  = "/${local.project_name}/deploy/api-server/group_name"
  type  = "String"
  value = module.codedeploy.codedeploy_deployment_group
  
  tags = {
    Name = "${local.project_name}-codedeploy-api-server-group"
  }
  
  depends_on = [module.codedeploy]
}

# SSM 파라미터 출력값
output "ssm_parameters" {
  description = "배포에 필요한 SSM 파라미터 경로"
  value = {
    db_url      = aws_ssm_parameter.db_url.name
    db_username = aws_ssm_parameter.db_username.name
    db_password = aws_ssm_parameter.db_password.name
    codedeploy_app = aws_ssm_parameter.codedeploy_app.name
    codedeploy_group = aws_ssm_parameter.codedeploy_group.name
    deployment_bucket = aws_ssm_parameter.deployment_bucket.name
  }
}