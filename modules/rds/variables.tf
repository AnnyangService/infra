variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "allocated_storage" {
  description = "할당할 스토리지 크기 (GB)"
  type        = number
}

variable "storage_type" {
  description = "스토리지 타입"
  type        = string
}

variable "engine" {
  description = "데이터베이스 엔진"
  type        = string
}

variable "engine_version" {
  description = "데이터베이스 엔진 버전"
  type        = string
}

variable "instance_class" {
  description = "인스턴스 클래스"
  type        = string
}

variable "db_name" {
  description = "데이터베이스 이름"
  type        = string
}

variable "username" {
  description = "데이터베이스 사용자 이름"
  type        = string
}

variable "password" {
  description = "데이터베이스 비밀번호"
  type        = string
  sensitive   = true
}

variable "parameter_group_name" {
  description = "파라미터 그룹 이름"
  type        = string
}

variable "subnet_ids" {
  description = "RDS 인스턴스가 생성될 서브넷 IDs"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS 인스턴스에 적용할 보안 그룹 ID"
  type        = string
}

variable "multi_az" {
  description = "다중 가용 영역 배포 여부"
  type        = bool
} 