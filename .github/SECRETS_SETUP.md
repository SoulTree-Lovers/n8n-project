# GitHub Secrets 설정 가이드

이 문서는 CI/CD 파이프라인을 위한 GitHub Secrets 설정 방법을 안내합니다.

## 🔐 필수 Secrets 설정

GitHub 저장소의 Settings > Secrets and variables > Actions에서 다음 시크릿들을 설정하세요.

### 1. Docker Hub 인증
```
DOCKER_USERNAME: your-dockerhub-username
DOCKER_PASSWORD: your-dockerhub-password
```

### 2. 서버 접속 정보
```
HOST: your-server-ip-address
USERNAME: your-server-username
SSH_KEY: your-private-ssh-key
```

### 3. 데이터베이스 연결 정보
```
DATABASE_URL: jdbc:postgresql://your-db-host:5432/your-database
DATABASE_USERNAME: your-db-username
DATABASE_PASSWORD: your-db-password
```

## 🔧 선택적 Secrets 설정

### Slack 알림 (선택사항)
```
SLACK_WEBHOOK: https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
```

## 📋 설정 단계별 가이드

### 1. Docker Hub 설정
1. [Docker Hub](https://hub.docker.com)에 가입
2. 저장소 생성 (예: `your-username/n8n-cicd`)
3. GitHub Secrets에 Docker Hub 인증 정보 추가

### 2. 서버 설정
1. 배포할 서버에 Docker 설치
2. SSH 키 생성 및 서버에 공개키 등록
3. GitHub Secrets에 서버 접속 정보 추가

### 3. 데이터베이스 설정
1. PostgreSQL 데이터베이스 생성
2. 데이터베이스 사용자 생성 및 권한 부여
3. GitHub Secrets에 데이터베이스 연결 정보 추가

### 4. SSH 키 생성 방법
```bash
# SSH 키 생성
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# 공개키를 서버에 복사
ssh-copy-id -i ~/.ssh/id_rsa.pub username@your-server-ip

# 개인키를 GitHub Secrets에 추가
cat ~/.ssh/id_rsa
```

## ✅ 설정 확인

모든 Secrets가 올바르게 설정되었는지 확인하려면:

1. GitHub Actions 탭에서 워크플로우 실행 상태 확인
2. 로그에서 인증 오류가 없는지 확인
3. 배포가 성공적으로 완료되는지 확인

## 🚨 보안 주의사항

- Secrets는 절대 코드에 하드코딩하지 마세요
- SSH 키는 적절한 권한(600)으로 설정하세요
- 정기적으로 Secrets를 업데이트하세요
- 불필요한 Secrets는 삭제하세요
