# AWS Terraform 인프라 코드

이 저장소는 AWS 인프라를 Terraform으로 관리하는 예제 코드를 포함하고 있습니다.

## 구조

- `modules/`: 재사용 가능한 Terraform 모듈
  - `vpc/`: VPC, 서브넷, 인터넷 게이트웨이 등 네트워크 리소스
  - `ec2/`: EC2 인스턴스 및 보안 그룹
- `environments/`: 환경별 설정
  - `dev/`: 개발 환경 설정

## 사용 방법

### 사전 준비

1. [Terraform](https://www.terraform.io/downloads.html)을 설치합니다.
2. AWS 계정 및 적절한 권한을 가진 IAM 사용자가 필요합니다.
3. AWS CLI를 설치하고 구성합니다:
   ```bash
   aws configure
   ```

### 배포 방법

1. 환경 디렉토리로 이동합니다:
   ```bash
   cd environments/dev
   ```

2. Terraform 초기화:
   ```bash
   terraform init
   ```

3. 배포 계획 확인:
   ```bash
   terraform plan
   ```

4. 인프라 배포:
   ```bash
   terraform apply
   ```

5. 인프라 삭제:
   ```bash
   terraform destroy
   ```

## 보안 고려 사항

이 코드를 실제 환경에서 사용하기 전에 다음 사항을 고려하세요:

1. **SSH 접근 제한**: 기본 설정은 SSH 접근을 제한하지 않습니다. 반드시 `allowed_ssh_cidr_blocks` 변수를 안전한 IP 범위로 설정하세요.

2. **상태 파일 관리**: 프로덕션 환경에서는 상태 파일을 S3와 같은 안전한 백엔드에 저장하세요.

3. **인프라 분리**: 다양한 환경(개발, 테스트, 프로덕션)을 명확하게 분리하세요.

4. **비밀 관리**: AWS Secrets Manager 또는 HashiCorp Vault를 사용하여 비밀을 관리하세요.

## 커스터마이징

`environments/dev/main.tf` 파일을 수정하여 다음과 같은 설정을 변경할 수 있습니다:

1. **SSH 접근 제한**: 예시 코드를 참고하여 현재 IP만 접근할 수 있도록 설정:
   ```hcl
   allowed_ssh_cidr_blocks = [local.my_ip]  # 현재 IP 주소만 허용
   ```

2. **리전 변경**: 필요에 따라 AWS 리전을 변경:
   ```hcl
   provider "aws" {
     region = "원하는_리전"
   }
   ```

3. **인스턴스 타입 변경**: 필요에 따라 EC2 인스턴스 타입 변경:
   ```hcl
   module "ec2" {
     # ...
     instance_type = "원하는_인스턴스_타입"
   }
   ```

## 라이센스

MIT 라이센스 