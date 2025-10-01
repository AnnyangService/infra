# 인프라 프로젝트 이슈 트래킹 문서

이 문서는 Hi-Meow 인프라 프로젝트를 진행하며 마주쳤던 주요 기술적 문제들과 해결 과정을 기록합니다.

<br>

## 1: AWS 프리티어 과금 문제 및 IaC 도입

**라벨**: `Cost`, `Infrastructure`, `Terraform`

### 문제 상황
Classic Load Balancer의 Public IP 사용으로 월 $4-5의 예상치 못한 과금이 발생했습니다. 로드밸런서 자체는 프리티어에 포함되지만 **Public IP 사용량은 별도 과금**됨을 발견했습니다.

### 해결책
**Infrastructure as Code(IaC) 도입**으로 테스트 시에만 인프라를 생성/삭제하는 체계를 구축했습니다.

```hcl
# 비용 최적화를 위한 조건부 리소스 생성
resource "aws_lb" "main" {
  count = var.enable_load_balancer ? 1 : 0
  
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"  # ALB로 변경 (기능 우수)
  subnets            = var.public_subnet_ids
  
  tags = {
    Environment = var.environment
    CostCenter  = "development"
  }
}
```

### 배운 점
- 프리티어 정책의 세부사항 정확한 파악 필요
- IaC를 통한 효율적인 비용 관리 가능
- 테스트 환경을 필요시에만 생성하는 운영 모델의 효과

<br>

## 2: GitHub Actions SSH 접속 보안 그룹 이슈

**라벨**: `CI/CD`, `Security`, `GitHub Actions`

### 문제 상황
GitHub Actions 러너의 IP가 매번 변경되어 EC2 SSH 접속이 실패했습니다.

### 해결책
**AWS OpenID Connect + SSM Parameter Store** 활용으로 안전한 배포 파이프라인을 구축했습니다.

```yaml
# GitHub Actions에서 OIDC 사용
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v1
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: ap-northeast-2

- name: Deploy to EC2
  run: |
    # SSM에서 SSH 키와 인스턴스 IP 동적 조회
    aws ssm get-parameter --name "/annyang/ec2/ssh/private-key" \
        --with-decryption --query 'Parameter.Value' --output text > key.pem
    
    INSTANCE_IP=$(aws ssm get-parameter --name "/annyang/ec2/public-ip" \
        --query 'Parameter.Value' --output text)
    
    # 배포 실행
    scp -i key.pem app.jar ec2-user@$INSTANCE_IP:/app/
    ssh -i key.pem ec2-user@$INSTANCE_IP "sudo systemctl restart my-app"
```

### 배운 점
- OIDC를 통한 보안성 강화된 클라우드 인증
- 동적 IP 문제 해결을 위한 SSM Parameter Store 활용
- IMDSv2를 사용한 메타데이터 보안 강화

<br>

## 3: AI 서버 아키텍처 재설계

**라벨**: `Architecture`, `Microservices`, `API Design`

### 문제 상황
초기 설계에서 AI 서버가 추론과 데이터베이스 관리를 모두 담당하여, 테이블 공유 구조가 복잡하고 테스트가 어려웠습니다.

### 해결책
**책임 분리 원칙** 적용으로 각 서버의 역할을 명확히 분리했습니다.

**AI 서버 (내부 전용)**
- ✅ 이미지 분석 및 추론 결과 제공
- ❌ 인증 로직 제외
- ❌ 데이터베이스 Write 연산 제외

**API 서버 (외부 공개)**
- ✅ 사용자 인증 및 데이터 관리
- ✅ AI 서버와의 통신 및 결과 저장

```python
# AI 서버 - 추론만 담당
POST /diagnosis/step1/
{
    "image_url": "https://s3.bucket/path/to/image.jpg"
}
Response: {
    "success": true,
    "data": {
        "is_normal": false,
        "confidence": 0.90
    }
}
```

### 배운 점
- 단일 책임 원칙의 중요성
- 콜백 패턴을 통한 비동기 처리 관리
- 테스트 용이성을 고려한 API 설계

<br>

## 4: Docker 기반 AI 서버 배포 최적화

**라벨**: `Docker`, `Optimization`, `AI/ML`

### 문제 상황
Python 기반 AI 서버의 Docker 이미지가 3GB 이상으로 매우 크고, EC2 t3.micro에서 메모리 부족으로 서버가 다운되었습니다.

### 해결책
**멀티스테이지 빌드 + PyTorch 경량화**로 이미지 크기를 50% 이상 절약했습니다.

```dockerfile
# 멀티스테이지 빌드
FROM python:3.9-slim as builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc g++
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.9-slim as production
WORKDIR /app
RUN apt-get update && apt-get install -y libglib2.0-0 libgomp1
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
```

```txt
# PyTorch CPU 전용 버전 사용
torch==1.12.0+cpu -f https://download.pytorch.org/whl/torch_stable.html
torchvision==0.13.0+cpu -f https://download.pytorch.org/whl/torch_stable.html
```

### 배운 점
- Docker 멀티스테이지 빌드의 효과
- AI/ML 워크로드의 정확한 리소스 요구사항 파악 필요
- 환경별 설정 분리의 중요성

<br>

## 5: Terraform 상태 관리 S3 백엔드 전환

**라벨**: `Terraform`, `State Management`, `CI/CD`

### 문제 상황
로컬 상태 파일로 인한 개발자 간 동기화 문제와 팀 협업의 어려움이 있었습니다.

### 해결책
**S3 원격 백엔드 + GitHub Actions** 통합으로 협업 환경을 구축했습니다.

```hcl
# S3 백엔드 설정
terraform {
  backend "s3" {
    bucket = "annyang-terraform-state-abc12345"
    key    = "terraform.tfstate"
    region = "ap-northeast-2"
  }
}
```

```yaml
# GitHub Actions Terraform 워크플로우
name: Terraform CI/CD
on:
  pull_request:
    paths: ['**/*.tf']
  push:
    branches: [main]
    paths: ['**/*.tf']

jobs:
  terraform-plan:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ap-northeast-2
      - name: Terraform Plan
        run: terraform plan -no-color
```

### 배운 점
- 원격 백엔드를 통한 안전한 상태 관리
- Terraform과 SSO의 호환성 문제와 우회 방법
- Pull Request를 통한 인프라 변경 리뷰 프로세스의 가치

<br>

## 기타 개선 사항

### 보안 강화
- **ID 생성**: 순차적 Long → ULID로 변경하여 추측 불가능한 ID 생성
- **API 문서**: Swagger UI에 ADMIN 권한 접근 제어 추가

### 배포 자동화
- **SystemD 서비스**: 애플리케이션을 시스템 서비스로 등록하여 안정적 관리
- **CodeDeploy 통합**: S3 + CodeDeploy를 통한 자동화된 배포 파이프라인

### 아키텍처 개선
- **프론트엔드**: Next.js CSR 모드로 S3 + CloudFront 정적 호스팅
- **컨테이너화**: Docker Compose를 통한 서비스 오케스트레이션

<br>

## 향후 계획

- **AutoScaling**: 트래픽 기반 자동 확장/축소
- **무중단 배포**: Blue-Green 또는 Rolling Update 구현
- **모니터링**: CloudWatch 기반 종합 모니터링 체계
- **컨테이너 오케스트레이션**: ECS/EKS 마이그레이션 검토