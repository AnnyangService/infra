# CodeDeploy 애플리케이션 생성 (API 서버와 AI 서버 공용)
resource "aws_codedeploy_app" "server-app" {
  name             = "${var.project_name}-server-app"
  compute_platform = "Server"  # EC2/온프레미스 서버를 위한 플랫폼
}

# CodeDeploy 서비스 역할
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_name}-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

# CodeDeploy 역할에 필요한 정책 연결
resource "aws_iam_role_policy_attachment" "codedeploy_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# CodeDeploy 배포 그룹 설정 (API 서버용)
resource "aws_codedeploy_deployment_group" "api_server_deploy_group" {
  app_name              = aws_codedeploy_app.server-app.name
  deployment_group_name = "${var.project_name}-api-server-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

    # EC2 태그 기반 배포 대상 설정
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.project_name}-api-server-ec2"
    }
  }

  # 자동 롤백 설정
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # 배포 설정 (한 번에 모든 인스턴스 업데이트)
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

# CodeDeploy 배포 그룹 설정 (AI 서버용)

resource "aws_codedeploy_deployment_group" "ai_server_deploy_group" {
  app_name              = aws_codedeploy_app.server-app.name
  deployment_group_name = "${var.project_name}-ai-server-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  # EC2 태그 기반 배포 대상 설정
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.project_name}-ai-server-ec2"
    }
  }

  # 자동 롤백 설정
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  # 배포 설정 (한 번에 모든 인스턴스 업데이트)
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
}

# CodeDeploy 배포 구성 설정
resource "aws_codedeploy_deployment_config" "custom_config" {
  deployment_config_name = "${var.project_name}-deploy-config"
  
  # 최소 정상 호스트 수를 백분율로 지정
  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 0
  }
}