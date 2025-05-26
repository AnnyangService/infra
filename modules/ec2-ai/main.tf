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

# 사용자 데이터 스크립트 - Docker 설치 및 ECR에서 Flask 이미지 가져오기
locals {
  user_data = <<-EOF
#!/bin/bash
# 시스템 업데이트 및 기본 도구 설치
sudo dnf update -y
sudo dnf install -y ruby wget git

# Docker 설치
sudo dnf install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user

# AWS CLI 설치 (ECR 인증에 필요)
sudo dnf install -y awscli

# ECR 로그인 및 이미지 가져오기
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin ${var.ecr_repository_url}

# Flask 도커 이미지 가져오기 및 실행
docker pull ${var.ecr_repository_url}:latest
docker run -d -p ${var.port}:5000 ${var.ecr_repository_url}:latest
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

  # 루트 볼륨 크기 설정 - 프리티어 최대 한도
  root_block_device {
    volume_size           = 30  # 프리티어 최대 한도 30GiB
    volume_type           = "gp3"  # 범용 SSD (프리티어에서 지원)
    encrypted             = true  # 보안을 위한 암호화 적용
    delete_on_termination = true  # 인스턴스 종료 시 볼륨 삭제
    
    # 프리티어에서 무료로 사용 가능한 최적의 성능 설정
    throughput            = 125  # 최대 프리티어 호환 처리량 (MB/s)
    iops                  = 3000 # 최대 프리티어 호환 IOPS
  }

  tags = {
    Name = "${var.project_name}-ai-server-ec2"
    Application = var.project_name
    ManagedBy = "terraform"
  }
}