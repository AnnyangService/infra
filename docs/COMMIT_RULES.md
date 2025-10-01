# 커밋 규칙 (Commit Rules)

이 문서는 Hi-Meow 백엔드 프로젝트의 Git 커밋 메시지 작성 규칙과 브랜치 전략을 정의합니다.

## 커밋 메시지 규칙

### 기본 원칙
1. **한글로 작성**: 프로젝트 특성상 한글 커밋 메시지 사용
2. **명확하고 간결하게**: 변경 사항을 한 눈에 알 수 있도록 작성
3. **일관성 유지**: 정해진 형식을 준수
4. **현재형으로 작성**: "추가했다"가 아닌 "추가"로 작성

### 커밋 메시지 길이
- **제목**: 50자 이내
- **본문**: 72자마다 줄바꿈
- **한 커밋은 하나의 기능**: 여러 기능을 한 번에 커밋하지 않음

## 커밋 메시지 구조

```
<타입>: <제목>

<본문 (선택사항)>

<푸터 (선택사항)>
```

### 예시
```
feat: 진단 첫 번째 단계 API 추가

사용자가 고양이 이미지를 업로드하여 첫 번째 진단을 받을 수 있는 
API를 구현했습니다.

- DiagnosisController에 POST /diagnosis/step1 엔드포인트 추가
- PostFirstStepDiagnosisRequest DTO 생성
- AI 서버 연동을 위한 임시 모킹 데이터 추가

Closes #54
```

## 커밋 타입

프로젝트에서 사용하는 커밋 타입과 설명:

| 타입 | 설명 | 예시 |
|------|------|------|
| `feat` | 새로운 기능 추가 | `feat: 진단 결과 목록 조회 API 추가` |
| `fix` | 버그 수정 | `fix: JWT 토큰 만료 시간 오류 수정` |
| `refactor` | 코드 리팩토링 (기능 변경 없음) | `refactor: 진단 서비스 로직 간소화` |
| `docs` | 문서 수정 | `docs: README에 Swagger UI 접속 정보 추가` |
| `style` | 코드 스타일 변경 (포매팅, 세미콜론 등) | `style: import 문 정리` |
| `test` | 테스트 코드 추가/수정 | `test: 진단 컨트롤러 단위 테스트 추가` |
| `chore` | 빌드, 패키지 설정 변경 | `chore: gradle 의존성 업데이트` |
| `build` | 빌드 시스템 변경 | `build: CI/CD 파이프라인 구축` |
| `perf` | 성능 개선 | `perf: 데이터베이스 쿼리 최적화` |
| `revert` | 이전 커밋 되돌리기 | `revert: "feat: 진단 API 추가" 커밋 되돌리기` |


## 커밋 메시지 예시

### 1. 기능 개발 커밋
```bash
# 좋은 예시
feat: 진단 목록 조회 API 추가
feat: 챗봇 세션 생성 기능 추가
feat: AWS S3 프리사인드 URL 생성 기능 추가

# 피해야 할 예시
feat: 기능 추가  # 너무 모호함
add feature      # 타입 없음, 영어 사용
```

### 2. 버그 수정 커밋
```bash
# 좋은 예시
fix: JWT 토큰 만료 시간 오류 수정
fix: 3단계 진단 중복 생성 방지
fix: DB_URL에 문자 인코딩 및 시간대 설정 추가

# 피해야 할 예시
fix: 버그 수정     # 어떤 버그인지 불명확
bug fix           # 타입 형식 미준수
```

### 3. 리팩토링 커밋
```bash
# 좋은 예시
refactor: 진단 서비스 로직 간소화
refactor: 폴더 구조 정리
refactor: 불필요한 주석 제거 및 UUID 임시 비밀번호 생성 로직 수정

# 피해야 할 예시
refactor: 코드 정리  # 구체적이지 않음
clean up code       # 영어 사용
```

### 4. 문서 작업 커밋
```bash
# 좋은 예시
docs: README에 Swagger UI 접속 정보 추가
docs: API 명세서 업데이트
docs: 로그인/회원가입 예시값 추가

# 피해야 할 예시
docs: 문서 수정    # 어떤 문서인지 불명확
update docs       # 영어 사용
```

### 5. 빌드 관련 커밋
```bash
# 좋은 예시
build: CI/CD 파이프라인 구축
build: Dockerfile 구조 개선 및 의존성 다운로드 단계 추가
chore: gradle 의존성 업데이트

# 피해야 할 예시
build: 빌드 수정   # 구체적이지 않음
update build      # 영어 사용
```

## 커밋 메시지 체크리스트

커밋하기 전에 다음 사항들을 확인하세요:

- [ ] 커밋 타입이 올바르게 지정되었는가?
- [ ] 제목이 50자 이내인가?
- [ ] 제목이 한글로 작성되었는가?
- [ ] 제목이 현재형으로 작성되었는가?
- [ ] 변경 사항이 명확하게 설명되었는가?
- [ ] 하나의 커밋에 하나의 논리적 변경만 포함되었는가?
- [ ] 관련 이슈 번호가 포함되었는가? (있는 경우)

## 브랜치 전략

### 브랜치 종류

#### 1. 메인 브랜치
- **`main`**: 프로덕션에 배포되는 안정된 코드

#### 2. 기능 브랜치
- **`feat/기능명`**: 새로운 기능 개발
- **`fix/버그명`**: 버그 수정
- **`refactor/리팩토링명`**: 코드 리팩토링
- **`docs/문서명`**: 문서 작업
- **`build/빌드명`**: 빌드 관련 작업

### 브랜치 명명 규칙

```bash
# 기능 개발
feat/diagnosis-step1
feat/user-authentication
feat/#54/diagnosis-step1  # 이슈 번호 포함

# 버그 수정
fix/jwt-token-expiration
fix/#123/login-error

# 리팩토링
refactor/diagnosis-service
refactor/project-structure

# 문서 작업
docs/api-documentation
docs/swagger

# 빌드 작업
build/ci-cd-pipeline
build/deployment
```

## Pull Request 규칙

### PR 제목 규칙
커밋 메시지와 동일한 구조로 작성합니다:

```
타입: 간단한 설명
```

**예시:**
- `feat: 진단 첫 번째 단계 API 추가`
- `fix: JWT 토큰 만료 시간 오류 수정`
- `docs: README에 Swagger UI 접속 정보 추가`
- `refactor: 진단 서비스 로직 간소화`

## 기본 워크플로우

1. **기능 브랜치에서 작업**
   ```bash
   git checkout -b feat/diagnosis-step1
   ```

2. **커밋 후 원격 브랜치에 푸시**
   ```bash
   git commit -m "feat: 진단 첫 번째 단계 API 추가"
   git push origin feat/diagnosis-step1
   ```

3. **GitHub에서 Pull Request 생성**
   - PR 제목: 커밋 메시지와 동일한 형식 사용
   - 코드 리뷰 후 병합

4. **병합 후 브랜치 삭제**
   ```bash
   git branch -d feat/diagnosis-step1
   ```


## 참고 자료

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git 브랜치 전략](https://nvie.com/posts/a-successful-git-branching-model/)
- [좋은 커밋 메시지 작성법](https://chris.beams.io/posts/git-commit/)