output "deployment_bucket" {
  description = "배포를 위한 S3 버킷 이름"
  value       = data.aws_s3_bucket.app_deploy.bucket
}

output "deployment_upload_command" {
  description = "배포 파일 업로드 명령어 예시"
  value       = "aws s3 cp your-app.zip s3://${data.aws_s3_bucket.app_deploy.bucket}/releases/your-app.zip"
}