# SSH 키 페어 생성
locals {
  key_name = "${var.project_name}-ai-key"
}

# TLS 프라이빗 키 생성
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# AWS 키 페어 생성 (퍼블릭 키는 tls_private_key 리소스에서 직접 가져옴)
resource "aws_key_pair" "key_pair" {
  key_name   = local.key_name
  public_key = tls_private_key.ssh.public_key_openssh
}

# 로컬 환경에서만 PEM 파일 저장 (GitHub Actions에서는 실행되지 않음)
resource "local_file" "private_key" {
  count = var.save_private_key_locally ? 1 : 0
  
  content  = tls_private_key.ssh.private_key_pem
  filename = "${path.cwd}/generated/${local.key_name}.pem"
  
  file_permission = "0600"
  
  # 디렉토리 생성
  provisioner "local-exec" {
    command = "mkdir -p ${path.cwd}/generated"
  }
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

# Docker compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

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

# SSH 키를 SSM Parameter Store에 저장 (안전한 접근을 위해)
resource "aws_ssm_parameter" "ai_server_private_key" {
  name  = "/${var.project_name}/ec2-ai/ssh/private-key"
  type  = "SecureString"
  value = tls_private_key.ssh.private_key_pem
  
  description = "AI 서버 SSH 프라이빗 키"
  
  tags = {
    Name        = "${var.project_name}-ai-server-ssh-key"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}

# AI 서버 접속 정보도 함께 저장
resource "aws_ssm_parameter" "ai_server_connection_info" {
  name  = "/${var.project_name}/ec2-ai/connection/info"
  type  = "String"
  value = jsonencode({
    public_ip    = aws_instance.ai_server.public_ip
    private_ip   = aws_instance.ai_server.private_ip
    instance_id  = aws_instance.ai_server.id
    key_name     = aws_key_pair.key_pair.key_name
    user         = "ec2-user"
    ssh_command  = "ssh -i <key_file> ec2-user@${aws_instance.ai_server.public_ip}"
  })
  
  description = "AI 서버 접속 정보"
  
  tags = {
    Name        = "${var.project_name}-ai-server-connection-info"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}