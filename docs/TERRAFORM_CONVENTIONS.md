# Terraform 코딩 컨벤션 (Terraform Coding Conventions)

이 문서는 Hi-Meow 인프라 프로젝트의 Terraform 코딩 표준과 규칙을 정의합니다.

## 일반 원칙

### 1. 가독성 우선
- Infrastructure as Code는 팀원 모두가 이해할 수 있어야 합니다
- 명확하고 이해하기 쉬운 구조를 유지합니다
- 복잡한 로직보다는 명시적인 구성을 선호합니다

### 2. 일관성 유지
- 프로젝트 전체에서 동일한 네이밍과 구조를 사용합니다
- 모듈 간 인터페이스를 표준화합니다

### 3. 재사용성과 모듈화
- 공통 패턴은 모듈로 추출합니다
- 환경별 차이는 변수로 관리합니다

## 파일 구조 및 네이밍

### 1. 프로젝트 구조
```
.
├── main.tf                    # 메인 설정 및 모듈 호출
├── variables.tf               # 입력 변수 정의 (선택사항)
├── outputs.tf                 # 출력값 정의
├── ssm_parameters.tf          # SSM Parameter Store 관련
├── terraform.tfvars          # 변수 값 설정 (gitignore)
├── .terraform.lock.hcl       # 의존성 잠금 파일
├── generated/                # 생성된 파일들 (gitignore)
├── docs/                     # 문서
└── modules/                  # 재사용 가능한 모듈들
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── iam.tf            # IAM 관련 리소스
    └── ...
```

### 2. 파일 네이밍 규칙
- **main.tf**: 주요 리소스 정의
- **variables.tf**: 입력 변수 정의
- **outputs.tf**: 출력값 정의
- **iam.tf**: IAM 관련 리소스 (모듈별)
- **{service}.tf**: 특정 서비스 전용 파일 (예: ssm_parameters.tf)

## 코딩 스타일

### 1. 들여쓰기 및 포맷팅
- **들여쓰기**: 2개의 공백 사용
- **줄 길이**: 가능한 한 120자 이내
- **정렬**: 인수들을 세로로 정렬하여 가독성 향상

```hcl
# 올바른 예시
resource "aws_instance" "api_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  
  associate_public_ip_address = var.associate_public_ip
  
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    project_name = var.project_name
  }))
  
  tags = {
    Name = "${var.project_name}-api-server"
    Type = "application"
  }
}
```

### 2. 리소스 네이밍 컨벤션
- **리소스명**: snake_case 사용
- **태그**: PascalCase 또는 kebab-case 사용
- **변수명**: snake_case 사용

```hcl
# 리소스 네이밍 패턴
resource "aws_security_group" "api_server_sg" { ... }           # 서비스별
resource "aws_s3_bucket" "deployment_bucket" { ... }           # 용도별
resource "aws_ssm_parameter" "db_password" { ... }             # 데이터별

# 태그 네이밍
tags = {
  Name        = "${var.project_name}-api-server"               # 리소스 식별
  Environment = var.environment                                # 환경 구분
  Service     = "api"                                         # 서비스 구분
  Project     = var.project_name                              # 프로젝트 구분
}
```

## 변수 및 지역값

### 1. 변수 정의
```hcl
# variables.tf
variable "project_name" {
  description = "프로젝트 이름 (리소스 네이밍에 사용)"
  type        = string
  default     = "annyang"
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.project_name))
    error_message = "프로젝트 이름은 소문자, 숫자, 하이픈만 사용 가능합니다."
  }
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "환경은 dev, staging, prod 중 하나여야 합니다."
  }
}
```

### 2. 지역값 사용
```hcl
# main.tf
locals {
  # 공통 설정
  project_name = "annyang"
  app_port     = 8080
  domain_name  = "hi-meow.kro.kr"
  
  # 계산된 값
  my_ip = "${data.http.myip.response_body}/32"
  
  # 공통 태그
  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
  
  # 환경별 설정
  db_config = {
    dev = {
      instance_class    = "db.t3.micro"
      allocated_storage = 20
      multi_az         = false
    }
    prod = {
      instance_class    = "db.t3.small"
      allocated_storage = 100
      multi_az         = true
    }
  }
}
```

## 모듈 설계

### 1. 모듈 구조
```hcl
# modules/ec2/main.tf
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = var.associate_public_ip
  
  iam_instance_profile = aws_iam_instance_profile.this.name
  
  user_data = base64encode(templatefile("${path.module}/scripts/user_data.sh", {
    project_name = var.project_name
  }))
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.server_type}"
  })
}
```

### 2. 모듈 변수 정의
```hcl
# modules/ec2/variables.tf
variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "server_type" {
  description = "서버 타입 (api, ai 등)"
  type        = string
  default     = "api"
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "EC2를 배치할 서브넷 ID"
  type        = string
}

variable "security_group_id" {
  description = "EC2에 적용할 보안 그룹 ID"
  type        = string
}

variable "associate_public_ip" {
  description = "퍼블릭 IP 할당 여부"
  type        = bool
  default     = true
}

variable "save_private_key_locally" {
  description = "SSH 키를 로컬에 저장할지 여부"
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}
```

### 3. 모듈 출력값
```hcl
# modules/ec2/outputs.tf
output "instance_id" {
  description = "EC2 인스턴스 ID"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "EC2 퍼블릭 IP"
  value       = aws_instance.this.public_ip
}

output "private_ip" {
  description = "EC2 프라이빗 IP"
  value       = aws_instance.this.private_ip
}

output "private_key_pem" {
  description = "SSH 프라이빗 키 (민감 정보)"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}

output "ssh_command" {
  description = "SSH 접속 명령어"
  value       = "ssh -i ${var.project_name}-${var.server_type}-key.pem ec2-user@${aws_instance.this.public_ip}"
}
```

## 데이터 소스 활용

### 1. AMI 조회
```hcl
# 최신 Amazon Linux 2023 AMI 조회
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

### 2. 가용 영역 조회
```hcl
# 사용 가능한 가용 영역 조회
data "aws_availability_zones" "available" {
  state = "available"
}
```

### 3. 현재 IP 조회
```hcl
# 현재 IP 주소 조회 (보안 그룹 설정용)
data "http" "myip" {
  url = "https://api.ipify.org"
}
```

## 보안 관련

### 1. 민감 정보 관리
```hcl
# SSM Parameter Store에 민감 정보 저장
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db/password"
  type  = "SecureString"
  value = random_password.db_password.result
  
  tags = {
    Name = "${var.project_name}-db-password"
  }
}

# 랜덤 비밀번호 생성
resource "random_password" "db_password" {
  length  = 16
  special = true
}
```

### 2. SSH 키 관리
```hcl
# SSH 키 쌍 생성
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 키 쌍을 AWS에 등록
resource "aws_key_pair" "this" {
  key_name   = "${var.project_name}-${var.server_type}-key"
  public_key = tls_private_key.this.public_key_openssh
  
  tags = {
    Name = "${var.project_name}-${var.server_type}-keypair"
  }
}

# SSH 키를 SSM에 안전하게 저장
resource "aws_ssm_parameter" "private_key" {
  name  = "/${var.project_name}/${var.server_type}/ssh/private-key"  
  type  = "SecureString"
  value = tls_private_key.this.private_key_pem
  
  tags = {
    Name = "${var.project_name}-${var.server_type}-ssh-key"
  }
}

# 로컬 저장 (선택사항)
resource "local_file" "private_key" {
  count = var.save_private_key_locally ? 1 : 0
  
  content         = tls_private_key.this.private_key_pem
  filename        = "${path.root}/generated/${var.project_name}-${var.server_type}-key.pem"
  file_permission = "0600"
}
```

## 태그 전략

### 1. 필수 태그
모든 리소스에는 다음 태그를 반드시 포함해야 합니다:

```hcl
tags = {
  Name        = "${var.project_name}-${var.resource_type}"
  Project     = var.project_name
  Environment = var.environment
  ManagedBy   = "terraform"
}
```

### 2. 선택적 태그
```hcl
tags = merge(local.common_tags, {
  Service     = "api"                    # 서비스 구분
  Owner       = "backend-team"           # 담당 팀
  CostCenter  = "engineering"            # 비용 센터
  Backup      = "daily"                  # 백업 정책
})
```

## 상태 관리

### 1. 원격 백엔드 설정
```hcl
terraform {
  # S3 백엔드 설정
  backend "s3" {
    bucket  = "annyang-terraform-state"
    key     = "terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    
    # DynamoDB를 이용한 상태 잠금 (선택사항)
    # dynamodb_table = "terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  
  required_version = ">= 1.5"
}
```

### 2. 프로바이더 설정
```hcl
provider "aws" {
  region = "ap-northeast-2"
  
  default_tags {
    tags = {
      Project   = "annyang"
      ManagedBy = "terraform"
    }
  }
}
```

## 의존성 관리

### 1. 명시적 의존성
```hcl
resource "aws_ssm_parameter" "db_url" {
  name  = "/${var.project_name}/db/url"
  type  = "String"
  value = "jdbc:mariadb://${module.rds.db_instance_endpoint}/${module.rds.db_instance_name}"
  
  # 명시적 의존성 선언
  depends_on = [module.rds]
}
```

### 2. 모듈 간 의존성
```hcl
# VPC 먼저 생성
module "vpc" {
  source = "./modules/vpc"
  
  project_name = local.project_name
}

# VPC 생성 후 보안 그룹 생성
module "sg" {
  source = "./modules/sg"
  
  project_name = local.project_name
  vpc_id       = module.vpc.vpc_id
  admin_ip     = local.my_ip
}

# 보안 그룹 생성 후 EC2 생성
module "ec2" {
  source = "./modules/ec2"
  
  project_name      = local.project_name
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.sg.ec2_security_group_id
}
```

## 주석 및 문서화

### 1. 주석 작성 원칙
```hcl
# 복잡한 로직에 대한 설명
locals {
  # 현재 IP를 CIDR 형태로 변환 (보안 그룹에서 사용)
  my_ip = "${data.http.myip.response_body}/32"
  
  # 환경별 데이터베이스 설정
  # dev: 비용 절약을 위해 최소 사양
  # prod: 고가용성을 위해 Multi-AZ 활성화
  db_config = var.environment == "prod" ? {
    instance_class = "db.t3.small"
    multi_az      = true
  } : {
    instance_class = "db.t3.micro"
    multi_az      = false
  }
}
```

### 2. 모듈 문서화
```hcl
# modules/ec2/main.tf

# EC2 인스턴스 생성
# - CodeDeploy 에이전트 자동 설치
# - SSM Session Manager 지원
# - CloudWatch 로그 에이전트 설치
resource "aws_instance" "this" {
  # ... 설정
}
```

## 에러 처리 및 검증

### 1. 변수 검증
```hcl
variable "environment" {
  description = "배포 환경"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "환경은 dev, staging, prod 중 하나여야 합니다."
  }
}

variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  
  validation {
    condition     = can(regex("^[tm][0-9]", var.instance_type))
    error_message = "인스턴스 타입은 t 또는 m 계열이어야 합니다."
  }
}
```

### 2. 조건부 리소스 생성
```hcl
# AI 서버는 필요할 때만 생성
resource "aws_instance" "ai_server" {
  count = var.enable_ai_server ? 1 : 0
  
  # ... 설정
}

# 개발 환경에서만 생성되는 리소스
resource "aws_instance" "bastion" {
  count = var.environment == "dev" ? 1 : 0
  
  # ... 설정
}
```

## 성능 및 비용 최적화

### 1. 리소스 생명주기 관리
```hcl
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db/password"
  type  = "SecureString"
  value = "initial-password"  # 초기값만 설정
  
  # 존재하는 경우 값 변경 무시 (수동 변경 허용)
  lifecycle {
    ignore_changes = [value]
  }
}
```

### 2. 조건부 생성으로 비용 절약
```hcl
# 개발 환경에서는 NAT Gateway 대신 NAT Instance 사용
resource "aws_nat_gateway" "main" {
  count = var.environment == "prod" ? length(var.public_subnets) : 0
  
  # ... 설정
}

resource "aws_instance" "nat" {
  count = var.environment != "prod" ? 1 : 0
  
  # ... NAT Instance 설정
}
```

## 체크리스트

Terraform 코드 작성 완료 후 다음 사항들을 확인하세요:

### 📋 코드 품질
- [ ] 네이밍 컨벤션을 준수했는가?
- [ ] 들여쓰기와 포맷팅이 일관성 있는가?
- [ ] 복잡한 로직에 적절한 주석이 있는가?
- [ ] 변수 검증이 추가되어 있는가?

### 🔒 보안
- [ ] 민감 정보가 하드코딩되지 않았는가?
- [ ] SSH 키가 SSM Parameter Store에 저장되는가?
- [ ] 보안 그룹 규칙이 최소 권한 원칙을 따르는가?
- [ ] 태그가 일관성 있게 적용되었는가?

### 🏗️ 구조
- [ ] 모듈화가 적절히 되어 있는가?
- [ ] 의존성이 명확히 정의되어 있는가?
- [ ] 출력값이 다른 모듈에서 사용하기 적합한가?
- [ ] 재사용 가능한 구조인가?

### 📊 운영
- [ ] 백엔드 설정이 되어 있는가?
- [ ] 프로바이더 버전이 고정되어 있는가?
- [ ] 생명주기 규칙이 적절히 설정되어 있는가?
- [ ] 비용 최적화가 고려되었는가?

## 참고 자료

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Module Registry](https://registry.terraform.io/)