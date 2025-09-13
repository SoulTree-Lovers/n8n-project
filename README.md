# N8N CI/CD 자동화 프로젝트

Spring Boot 기반의 웹 애플리케이션으로, GitHub Actions를 통한 CI/CD 자동 배포 파이프라인이 구축되어 있습니다.

## 🚀 주요 기능

- **Spring Boot 3.5.5** 기반 웹 애플리케이션
- **Java 17** 사용
- **PostgreSQL** 데이터베이스 연동
- **Docker** 컨테이너화
- **GitHub Actions** CI/CD 파이프라인
- **자동 테스트, 빌드, 배포**

## 🏗️ 기술 스택

- **Backend**: Spring Boot, Spring Data JPA
- **Database**: PostgreSQL
- **Container**: Docker
- **CI/CD**: GitHub Actions
- **Build Tool**: Gradle
- **Monitoring**: Spring Boot Actuator

## 📋 사전 요구사항

- Java 17+
- Docker & Docker Compose
- PostgreSQL (로컬 개발용)
- Git

## 🛠️ 로컬 개발 환경 설정

### 1. 저장소 클론
```bash
git clone <repository-url>
cd n8n-cicd
```

### 2. PostgreSQL 데이터베이스 설정
```bash
# PostgreSQL 컨테이너 실행
docker run --name postgres-dev -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=n8n -p 5432:5432 -d postgres:15
```

### 3. 애플리케이션 실행
```bash
# Gradle로 실행
./gradlew bootRun

# 또는 Docker Compose로 실행
docker-compose up -d
```

### 4. 애플리케이션 접속
- **애플리케이션**: http://localhost:8080
- **헬스체크**: http://localhost:8080/actuator/health
- **메트릭**: http://localhost:8080/actuator/metrics

## 🐳 Docker 사용법

### 단일 컨테이너 실행
```bash
# 이미지 빌드
docker build -t n8n-cicd .

# 컨테이너 실행
docker run -p 8080:8080 n8n-cicd
```

### Docker Compose 사용
```bash
# 모든 서비스 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f

# 서비스 중지
docker-compose down
```

## 🔄 CI/CD 파이프라인

### GitHub Actions 워크플로우

이 프로젝트는 다음과 같은 자동화된 파이프라인을 포함합니다:

1. **테스트 단계** (`test`)
   - Java 17 환경 설정
   - PostgreSQL 서비스 실행
   - 단위 테스트 실행
   - 테스트 리포트 생성

2. **빌드 단계** (`build`)
   - 애플리케이션 빌드
   - JAR 파일 생성
   - 빌드 아티팩트 업로드

3. **Docker 빌드** (`docker-build`)
   - Docker 이미지 빌드
   - Docker Hub에 푸시
   - 캐시 최적화

4. **배포 단계** (`deploy`)
   - 서버에 SSH 연결
   - 기존 컨테이너 중지
   - 새 이미지로 컨테이너 실행
   - 헬스체크 수행

5. **알림 단계** (`notify`)
   - 배포 상태 Slack 알림

### 트리거 조건

- **main 브랜치 푸시**: 전체 파이프라인 실행 (테스트 → 빌드 → Docker → 배포)
- **develop 브랜치 푸시**: 테스트 및 빌드만 실행
- **Pull Request**: 테스트 및 빌드만 실행

## 🔧 배포 스크립트

### 수동 배포
```bash
# 프로덕션 환경 배포
./scripts/deploy.sh production latest

# 스테이징 환경 배포
./scripts/deploy.sh staging v1.0.0
```

### 롤백
```bash
# 이전 버전으로 롤백
./scripts/rollback.sh production v1.0.0
```

### 헬스체크
```bash
# 애플리케이션 상태 확인
./scripts/health-check.sh production
```

## 🔐 GitHub Secrets 설정

다음 시크릿들을 GitHub 저장소에 설정해야 합니다:

### 필수 시크릿
- `DOCKER_USERNAME`: Docker Hub 사용자명
- `DOCKER_PASSWORD`: Docker Hub 비밀번호
- `HOST`: 배포 서버 IP 주소
- `USERNAME`: 서버 사용자명
- `SSH_KEY`: 서버 SSH 개인키
- `DATABASE_URL`: 프로덕션 데이터베이스 URL
- `DATABASE_USERNAME`: 데이터베이스 사용자명
- `DATABASE_PASSWORD`: 데이터베이스 비밀번호

### 선택적 시크릿
- `SLACK_WEBHOOK`: Slack 알림용 웹훅 URL

## 📊 모니터링

### Actuator 엔드포인트
- **헬스체크**: `/actuator/health`
- **애플리케이션 정보**: `/actuator/info`
- **메트릭**: `/actuator/metrics`

### 로그 확인
```bash
# Docker 컨테이너 로그
docker logs n8n-cicd-app

# Docker Compose 로그
docker-compose logs -f app
```

## 🧪 테스트

### 단위 테스트 실행
```bash
./gradlew test
```

### 통합 테스트 실행
```bash
./gradlew integrationTest
```

### 테스트 커버리지
```bash
./gradlew jacocoTestReport
```

## 📁 프로젝트 구조

```
n8n-cicd/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions 워크플로우
├── scripts/
│   ├── deploy.sh              # 배포 스크립트
│   ├── rollback.sh            # 롤백 스크립트
│   └── health-check.sh        # 헬스체크 스크립트
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/example/n8n_cicd/
│   │   │       └── N8nCicdApplication.java
│   │   └── resources/
│   │       └── application.yaml
│   └── test/
├── Dockerfile                 # Docker 이미지 설정
├── docker-compose.yml         # Docker Compose 설정
├── .dockerignore             # Docker 빌드 제외 파일
└── build.gradle.kts          # Gradle 빌드 설정
```

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 📞 지원

문제가 발생하거나 질문이 있으시면 이슈를 생성해 주세요.

---

**Happy Coding! 🎉**
# CI/CD 자동 배포 테스트
