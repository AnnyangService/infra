# ALB 보안 그룹 (먼저 정의하여 EC2 보안그룹에서 참조할 수 있도록 함)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  # HTTP 트래픽 허용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP traffic"
  }

  # HTTPS 트래픽 허용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS traffic"
  }

  # 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}

# EC2 보안 그룹
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-api-server-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
    description = "Allow SSH access from admin IP"
  }

  # ALB로부터의 트래픽 허용
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow traffic from ALB to EC2 instance"
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-api-server-ec2-sg"
  }
}

# RDS 보안 그룹
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = var.vpc_id

  # EC2 보안 그룹으로부터의 접근만 허용
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "Allow MariaDB connections only from the EC2 instances"
  }

  # 아웃바운드 트래픽 없음 (프라이빗 서브넷)

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

# AI 서버 보안 그룹
resource "aws_security_group" "ai_server" {
  name        = "${var.project_name}-ai-server-sg"
  description = "Security group for AI Server instances"
  vpc_id      = var.vpc_id

  # API 서버 보안 그룹으로부터만 접속 허용 (API 서버만 AI 서버에 접근 가능)
  ingress {
    from_port       = var.ai_server_port
    to_port         = var.ai_server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
    description     = "Allow traffic from API Server to AI Server"
  }

  # SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
    description = "Allow SSH access from admin IP"
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-ai-server-sg"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}