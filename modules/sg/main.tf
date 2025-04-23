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
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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