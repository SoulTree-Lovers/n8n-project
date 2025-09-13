#!/bin/bash

# 롤백 스크립트
# 사용법: ./rollback.sh [environment] [previous_version]

set -e

ENVIRONMENT=${1:-production}
PREVIOUS_VERSION=${2:-previous}

if [ "$PREVIOUS_VERSION" = "previous" ]; then
  echo "❌ Please specify the previous version to rollback to"
  echo "Usage: ./rollback.sh [environment] [previous_version]"
  exit 1
fi

APP_NAME="n8n-cicd"
DOCKER_IMAGE="$APP_NAME:$PREVIOUS_VERSION"

echo "🔄 Starting rollback..."
echo "Environment: $ENVIRONMENT"
echo "Rolling back to version: $PREVIOUS_VERSION"

# 환경별 설정
case $ENVIRONMENT in
  "production")
    PORT=8080
    ;;
  "staging")
    PORT=8081
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# 기존 컨테이너 중지 및 제거
echo "🛑 Stopping current container..."
docker stop $APP_NAME-$ENVIRONMENT 2>/dev/null || true
docker rm $APP_NAME-$ENVIRONMENT 2>/dev/null || true

# 이전 버전으로 컨테이너 실행
echo "▶️ Starting previous version container..."
docker run -d \
  --name $APP_NAME-$ENVIRONMENT \
  --restart unless-stopped \
  -p $PORT:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:postgresql://postgres:5432/n8n" \
  -e SPRING_DATASOURCE_USERNAME="postgres" \
  -e SPRING_DATASOURCE_PASSWORD="postgres" \
  -e SPRING_PROFILES_ACTIVE="$ENVIRONMENT" \
  $DOCKER_IMAGE

# 헬스체크
echo "🏥 Performing health check..."
sleep 30

for i in {1..10}; do
  if curl -f http://localhost:$PORT/actuator/health >/dev/null 2>&1; then
    echo "✅ Rollback completed successfully!"
    echo "🌐 Application is running at: http://localhost:$PORT"
    break
  else
    echo "⏳ Health check attempt $i/10 failed, retrying in 10 seconds..."
    sleep 10
  fi
  
  if [ $i -eq 10 ]; then
    echo "❌ Rollback failed - health check failed after 10 attempts"
    echo "📋 Container logs:"
    docker logs $APP_NAME-$ENVIRONMENT
    exit 1
  fi
done
