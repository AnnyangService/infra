# 출력값 정의
output "codedeploy_app_name" {
  description = "CodeDeploy 애플리케이션 이름"
  value       = aws_codedeploy_app.server-app.name
}

output "codedeploy_api_server_deployment_group" {
  description = "API 서버 CodeDeploy 배포 그룹 이름"
  value       = aws_codedeploy_deployment_group.api_server_deploy_group.deployment_group_name
}

output "codedeploy_ai_server_deployment_group" {
  description = "AI 서버 CodeDeploy 배포 그룹 이름"
  value       = aws_codedeploy_deployment_group.ai_server_deploy_group.deployment_group_name
}
