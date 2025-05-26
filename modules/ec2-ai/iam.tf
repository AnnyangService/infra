# AI 서버에 필요한 IAM 역할 정의
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ai-server-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# AI 서버에 S3 접근 권한 추가 (데이터 및 모델 접근용)
resource "aws_iam_role_policy_attachment" "ec2_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# AI 서버에 SSM 접근 권한 추가 (파라미터 스토어 접근용)
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM 인스턴스 프로파일 생성
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ai-server-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 출력값 정의
output "iam_instance_profile_name" {
  description = "AI 서버용 EC2 인스턴스 프로파일 이름"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "iam_instance_profile_arn" {
  description = "AI 서버용 EC2 인스턴스 프로파일 ARN"
  value       = aws_iam_instance_profile.ec2_profile.arn
}
