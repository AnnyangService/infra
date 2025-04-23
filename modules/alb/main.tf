# 애플리케이션 로드 밸런서 생성
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-alb"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}

# ALB 대상 그룹 생성
resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-target-group"
  port     = var.target_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }

  tags = {
    Name        = "${var.project_name}-target-group"
    Application = var.project_name
    ManagedBy   = "terraform"
  }
}

# EC2 인스턴스를 대상 그룹에 등록
resource "aws_lb_target_group_attachment" "main" {
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.instance_id
  port             = var.target_port
}

# ALB 리스너 생성 (HTTP)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}