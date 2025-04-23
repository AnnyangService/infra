# SSH 키 페어 생성
resource "tls_private_key" "ssh" {
  count     = var.create_key_pair ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 로컬에 PEM 파일 저장
resource "local_file" "private_key" {
  count    = var.create_key_pair ? 1 : 0
  content  = tls_private_key.ssh[0].private_key_pem
  filename = "${path.cwd}/generated/${var.project_name}-key.pem"

  # 파일 권한 설정 (0600: 소유자만 읽기/쓰기 가능)
  file_permission = "0600"
}

# AWS 키 페어 생성
resource "aws_key_pair" "key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh[0].public_key_openssh
}

resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  
  # 키 페어 연결
  key_name               = var.create_key_pair ? aws_key_pair.key_pair[0].key_name : var.key_name
  
  # 공개 IP 할당
  associate_public_ip_address = var.associate_public_ip

  tags = {
    Name = "${var.project_name}-ec2"
  }
} 