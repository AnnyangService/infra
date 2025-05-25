resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# 커스텀 파라미터 그룹 생성
resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-db-params"
  family      = "mariadb${split(".", var.engine_version)[0]}.${split(".", var.engine_version)[1]}"
  description = "Custom parameter group for ${var.project_name} database"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  
  # MariaDB에 추가적인 UTF8 관련 파라미터 설정
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  
  tags = {
    Name = "${var.project_name}-db-params"
  }
}

resource "aws_db_instance" "main" {
  identifier           = "${var.project_name}-db"
  allocated_storage    = var.allocated_storage
  storage_type         = var.storage_type
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  parameter_group_name = aws_db_parameter_group.main.name  # 커스텀 파라미터 그룹 사용
  skip_final_snapshot  = true
  
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # 추가 설정
  multi_az             = var.multi_az
  publicly_accessible  = false  # 프라이빗 서브넷에 위치하므로 false
  
  tags = {
    Name = "${var.project_name}-db"
  }
}