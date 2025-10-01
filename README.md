# Hi-Meow AWS 인프라

Terraform을 사용하여 AWS 인프라를 관리하고 CodeDeploy를 통해 애플리케이션을 배포하는 프로젝트입니다.

<br>

## 🏗️ 인프라 구성

### 핵심 서비스
| 서비스 | 용도 | 설명 |
|--------|------|------|
| **EC2** | API/AI 서버 | Spring Boot + AI 추론 서버 |
| **RDS** | 데이터베이스 | MariaDB (프라이빗 서브넷) |
| **ALB** | 로드밸런서 | HTTPS 지원, 도메인 연결 |
| **S3** | 스토리지 | 배포 패키지, 이미지, 프론트엔드 |
| **CloudFront** | CDN | 프론트엔드 배포 |
| **CodeDeploy** | 배포 | 자동화된 애플리케이션 배포 |

### 네트워크 구성
- **VPC**: 퍼블릭/프라이빗 서브넷 (다중 AZ)
- **도메인**: hi-meow.kro.kr (ACM SSL 인증서)
- **보안**: IAM 역할, 보안 그룹, SSM Parameter Store

<br>

## 🚀 빠른 시작

### 1. 인프라 생성
```bash
# AWS 로그인
aws sso login

# Terraform 실행
terraform init
terraform plan
terraform apply
```

### 2. 도메인 설정
```bash
# ALB DNS 주소 확인
terraform output alb_dns_name

# 도메인 CNAME 설정 (예: 내도메인.한국)
# api.hi-meow.kro.kr → ALB DNS 주소
# hi-meow.kro.kr → CloudFront 도메인
```

### 3. 접속 확인
```bash
# 웹사이트 접속
open https://hi-meow.kro.kr

# API 서버 상태 확인
curl https://api.hi-meow.kro.kr/health
```

<br>

## 🔌 접속 방법

### SSH 서버 접속

**권장 방법 (SSM 사용):**
```bash
# API 서버 접속
aws ssm get-parameter --name '/annyang/ec2/ssh/private-key' --with-decryption --query 'Parameter.Value' --output text > temp-key.pem
chmod 600 temp-key.pem
ssh -i temp-key.pem ec2-user@$(terraform output -raw ec2_public_ip)
rm temp-key.pem

# AI 서버 접속
aws ssm get-parameter --name '/annyang/ec2-ai/ssh/private-key' --with-decryption --query 'Parameter.Value' --output text > temp-key.pem
chmod 600 temp-key.pem
ssh -i temp-key.pem ec2-user@$(terraform output -raw ai_server_public_ip)
rm temp-key.pem
```

**간편한 방법 (Session Manager):**
```bash
# SSH 키 없이 접속
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
aws ssm start-session --target $(terraform output -raw ai_server_instance_id)
```

### 데이터베이스 접속
```bash
# API 서버를 통한 터널링 후 접속
mysql -h $(terraform output -raw rds_endpoint) -P 3306 -u admin -p
```

### 주요 접속 정보
```bash
# 모든 접속 정보 확인
terraform output

# 개별 정보 확인
terraform output ec2_public_ip           # API 서버 IP
terraform output ai_server_public_ip     # AI 서버 IP
terraform output alb_dns_name            # 로드밸런서 주소
terraform output rds_endpoint            # 데이터베이스 엔드포인트
```

<br>


## 🔧 SSM Parameter Store

자주 사용하는 설정값들이 SSM Parameter Store에 저장되어 있습니다:

### 데이터베이스 연결
```bash
aws ssm get-parameter --name "/annyang/db/url" --query "Parameter.Value" --output text
aws ssm get-parameter --name "/annyang/db/password" --with-decryption --query "Parameter.Value" --output text
```

### 배포 설정
```bash
aws ssm get-parameter --name "/annyang/server-deploy/bucket" --query "Parameter.Value" --output text
aws ssm get-parameter --name "/annyang/ai-server/url" --query "Parameter.Value" --output text
```

### SSH 키 (보안)
```bash
aws ssm get-parameter --name "/annyang/ec2/ssh/private-key" --with-decryption --query "Parameter.Value" --output text
```

<br>

## 💡 주요 특징

- **💰 비용 최적화**: 필요시에만 인프라 생성/삭제 가능
- **🔐 보안 강화**: SSH 키 SSM 저장, HTTPS 강제, IAM 역할 기반 접근
- **🚀 자동 배포**: CodeDeploy + GitHub Actions 통합
- **📊 모니터링**: CloudWatch 로그, ALB Health Check
- **🔄 확장성**: 독립적인 API/AI 서버, 다중 AZ 구성


<br>

## 🆘 문제 해결

### 자주 발생하는 문제들

**인프라 생성 실패**
```bash
# Terraform 상태 초기화
terraform destroy
rm -rf .terraform terraform.tfstate*
terraform init
```

**SSH 접속 실패**
```bash
# Session Manager로 대체 접속
aws ssm start-session --target INSTANCE_ID
```

**배포 실패**
```bash
# CodeDeploy 로그 확인
aws logs tail /aws/codedeploy-agent/codedeploy-agent --follow
```


<br>

## 🗂️ 참고 문서

### 개발 가이드
- 📝 [Terraform 코딩 컨벤션](docs/TERRAFORM_CONVENTIONS.md)
- 🔀 [커밋 규칙](docs/COMMIT_RULES.md)

### 프로젝트 문서  
- 📖 [이슈 추적 히스토리](docs/ISSUES.md)

### 관련 링크
- 🌐 **웹사이트**: https://hi-meow.kro.kr
- 🔧 **AWS 콘솔**: [CodeDeploy](https://console.aws.amazon.com/codedeploy/) | [EC2](https://console.aws.amazon.com/ec2/) | [RDS](https://console.aws.amazon.com/rds/)
