# AWS 인프라 및 CodeDeploy 배포 설정

## 개요
이 프로젝트는 Terraform을 사용하여 AWS 인프라(VPC, EC2, RDS)를 생성하고 CodeDeploy를 통한 애플리케이션 배포 환경을 구성합니다.

## 인프라 구성요소
- **VPC**: 퍼블릭/프라이빗 서브넷, 인터넷 게이트웨이, 라우팅 테이블
- **EC2**: 애플리케이션 서버 (CodeDeploy 에이전트 자동 설치)
- **RDS**: MariaDB 데이터베이스
- **보안 그룹**: EC2 및 RDS 접근 제어
- **CodeDeploy**: 애플리케이션 배포 자동화
- **S3**: 배포 패키지 저장소

## Terraform 실행 방법

1. 초기화
```bash
terraform init
```

2. 계획 확인
```bash
terraform plan
```

3. 인프라 생성
```bash
terraform apply
```

4. 인프라 삭제
```bash
terraform destroy
```

## EC2 SSH 접속 방법

### SSH 키 생성 및 저장

**로컬 환경에서 SSH 키를 생성하고 저장하려면:**
```bash
# SSH 키를 로컬에 저장하면서 인프라 생성
terraform apply -var="save_private_key_locally=true"
```

### SSH 접속

**생성된 키로 EC2 인스턴스에 접속:**
```bash
# API 서버 접속
ssh -i ./generated/annyang-key.pem ec2-user@<API_SERVER_PUBLIC_IP>

# AI 서버 접속 (AI 모듈이 활성화된 경우)
ssh -i ./generated/annyang-ai-key.pem ec2-user@<AI_SERVER_PUBLIC_IP>
```

### Terraform 출력에서 IP 주소 확인

**EC2 인스턴스의 퍼블릭 IP 주소 확인:**
```bash
# API 서버 IP 확인
terraform output ec2_public_ip

# AI 서버 IP 확인 (AI 모듈이 활성화된 경우)
terraform output ec2_ai_public_ip

# 모든 출력 확인
terraform output
```

### 주의사항

- **GitHub Actions 실행 시**: `save_private_key_locally=false`가 기본값이므로 로컬 키 파일이 생성되지 않습니다.
- **보안**: 생성된 SSH 키 파일(`generated/` 디렉토리)은 `.gitignore`에 포함되어 Git에 커밋되지 않습니다.
- **권한**: SSH 키 파일은 자동으로 적절한 권한(600)으로 설정됩니다.

## CI/CD 배포 통합 방법

### 애플리케이션 프로젝트 준비

1. `appspec.yml`을 프로젝트 루트에 배치
   - CodeDeploy가 배포 단계를 관리하는 데 필요한 파일입니다.

2. 배포 스크립트 준비
   - `scripts/before_install.sh`: 배포 전 준비
   - `scripts/after_install.sh`: 배포 후 설정 (SSM에서 환경 변수 불러오기)
   - `scripts/application_start.sh`: 애플리케이션 시작
   - `scripts/application_stop.sh`: 애플리케이션 중지

### CI/CD 파이프라인 설정 (GitHub Actions, Jenkins, GitLab CI 등)

CI/CD 파이프라인에 다음 단계를 추가합니다:

1. 빌드 단계
```yaml
# 예: GitHub Actions 워크플로우
build:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v3
    # 빌드 단계...
    
    # 배포 패키지 생성
    - name: Create deployment package
      run: |
        zip -r application.zip appspec.yml scripts/ dist/ # 또는 빌드된 파일이 있는 디렉토리
```

2. S3 업로드 단계
```yaml
upload-to-s3:
  runs-on: ubuntu-latest
  needs: build
  steps:
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ap-northeast-2
        
    - name: Upload to S3
      run: |
        aws s3 cp application.zip s3://${BUCKET_NAME}/releases/application-${{ github.sha }}.zip
      env:
        BUCKET_NAME: $(aws ssm get-parameters --names "/annyang/deploy/bucket" --query "Parameters[0].Value" --output text)
```

3. CodeDeploy 배포 시작
```yaml
deploy:
  runs-on: ubuntu-latest
  needs: upload-to-s3
  steps:
    - name: Deploy with CodeDeploy
      run: |
        APP_NAME=$(aws ssm get-parameters --names "/annyang/deploy/app_name" --query "Parameters[0].Value" --output text)
        DEPLOY_GROUP=$(aws ssm get-parameters --names "/annyang/deploy/group_name" --query "Parameters[0].Value" --output text)
        BUCKET_NAME=$(aws ssm get-parameters --names "/annyang/deploy/bucket" --query "Parameters[0].Value" --output text)
        
        aws deploy create-deployment \
          --application-name $APP_NAME \
          --deployment-group-name $DEPLOY_GROUP \
          --s3-location bucket=$BUCKET_NAME,key=releases/application-${{ github.sha }}.zip,bundleType=zip \
          --region ap-northeast-2
```

## SSM 파라미터 스토어 사용

배포된 EC2 인스턴스는 배포 스크립트에서 다음 SSM 파라미터들을 사용합니다:

- `/${PROJECT_NAME}/db/url`: 데이터베이스 JDBC URL
- `/${PROJECT_NAME}/db/username`: 데이터베이스 사용자 이름
- `/${PROJECT_NAME}/db/password`: 데이터베이스 비밀번호 (암호화됨)
- `/${PROJECT_NAME}/deploy/api-server/app_name`: CodeDeploy 애플리케이션 이름
- `/${PROJECT_NAME}/deploy/api-server/group_name`: CodeDeploy 배포 그룹 이름
- `/${PROJECT_NAME}/deploy/api-server/bucket`: 배포 S3 버킷 이름

## 참고사항
- RDS 비밀번호는 AWS SSM Parameter Store에 저장되며, 초기 비밀번호는 배포 후 변경해야 합니다.
- EC2 SSH 키는 `generated/` 디렉토리에 저장됩니다.
- SSH 키 파일은 보안을 위해 Git에 커밋되지 않습니다.
- 애플리케이션이 SSM에서 환경 변수를 가져오기 위해서는 EC2 인스턴스에 적절한 IAM 권한이 필요합니다 (이미 구성됨).