# 출력값 정의
output "codedeploy_app_name" {
  description = "CodeDeploy 애플리케이션 이름"
  value       = aws_codedeploy_app.app.name
}

output "codedeploy_deployment_group" {
  description = "CodeDeploy 배포 그룹 이름"
  value       = aws_codedeploy_deployment_group.app_deploy_group.deployment_group_name
}

output "codedeploy_deployment_command" {
  description = "배포 명령어 예시"
  value       = "aws deploy create-deployment --application-name ${aws_codedeploy_app.app.name} --deployment-group-name ${aws_codedeploy_deployment_group.app_deploy_group.deployment_group_name} --s3-location bucket=YOUR_BUCKET,key=YOUR_APP_BUNDLE.zip,bundleType=zip"
}