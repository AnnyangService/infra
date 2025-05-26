# SSH 키 페어 생성
locals {
  key_name = "${var.project_name}-ai-key"
  key_file_path = "${path.cwd}/generated/${local.key_name}"
  key_dir = "${path.cwd}/generated"
  should_create_key = !fileexists(local.key_file_path)
}

# generated 디렉토리 생성
resource "local_file" "ensure_directory" {
  count    = local.should_create_key ? 1 : 0
  filename = "${local.key_dir}/.keep"
  content  = ""

  provisioner "local-exec" {
    command = "mkdir -p ${local.key_dir}"
  }
}

resource "tls_private_key" "ssh" {
  count     = local.should_create_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096

  depends_on = [local_file.ensure_directory]
}

# 로컬에 PEM 파일 저장
resource "local_file" "private_key" {
  count    = local.should_create_key ? 1 : 0
  content  = local.should_create_key ? tls_private_key.ssh[0].private_key_pem : ""
  filename = local.key_file_path

  # 파일 권한 설정 (0600: 소유자만 읽기/쓰기 가능)
  file_permission = "0600"

  depends_on = [tls_private_key.ssh]
}

# AWS 키 페어 생성
resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = file("${local.key_file_path}.pub")

  depends_on = [local_file.private_key]
}

# CodeDeploy 에이전트 설치를 위한 사용자 데이터 스크립트
locals {
  user_data = <<-EOF
#!/bin/bash
# 시스템 업데이트 및 기본 도구 설치
sudo dnf update -y
sudo dnf install -y ruby wget git

# Python 및 관련 도구 설치
sudo dnf install -y python3 python3-pip python3-devel
sudo pip3 install virtualenv

# Flask 및 관련 패키지 설치
sudo pip3 install flask gunicorn

# 환경 변수 설정
echo "export PATH=$PATH:/usr/local/bin" | sudo tee -a /etc/profile.d/python.sh
sudo chmod +x /etc/profile.d/python.sh
source /etc/profile.d/python.sh

cd /home/ec2-user

# 리전에 따른 CodeDeploy 에이전트 다운로드 URL 설정 (IMDSv2 호환)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
region=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)
wget https://aws-codedeploy-$region.s3.$region.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo systemctl enable codedeploy-agent
sudo systemctl start codedeploy-agent
EOF
}

resource "aws_instance" "ai_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  
  # 키 페어 연결
  key_name               = aws_key_pair.key_pair.key_name
  
  # IAM 인스턴스 프로파일 연결
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  # 사용자 데이터 스크립트 추가
  user_data              = local.user_data
  
  # 공개 IP 할당
  associate_public_ip_address = var.associate_public_ip

  tags = {
    Name = "${var.project_name}-ai-server-ec2"
    Application = var.project_name
    ManagedBy = "terraform"
  }
}