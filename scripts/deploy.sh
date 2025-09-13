#!/bin/bash

# 배포 스크립트
# 사용법: ./deploy.sh [environment] [version]

set -e

ENVIRONMENT=${1:-production}
VERSION=${2:-latest}
APP_NAME="n8n-cicd"
DOCKER_IMAGE="$APP_NAME:$VERSION"

echo "🚀 Starting deployment..."
echo "Environment: $ENVIRONMENT"
echo "Version: $VERSION"
echo "Docker Image: $DOCKER_IMAGE"

# 환경별 설정
case $ENVIRONMENT in
  "production")
    PORT=8082
    DATABASE_URL="jdbc:postgresql://postgres:5432/n8n"
    ;;
  "staging")
    PORT=8083
    DATABASE_URL="jdbc:postgresql://postgres:5432/n8n_staging"
    ;;
  *)
    echo "❌ Unknown environment: $ENVIRONMENT"
    exit 1
    ;;
esac

# Docker 이미지 빌드
echo "🔨 Building Docker image..."
docker build -t $DOCKER_IMAGE .

# 기존 컨테이너 중지 및 제거
echo "🛑 Stopping existing container..."
docker stop $APP_NAME-$ENVIRONMENT 2>/dev/null || true
docker rm $APP_NAME-$ENVIRONMENT 2>/dev/null || true

# 새 컨테이너 실행
echo "▶️ Starting new container..."
docker run -d \
  --name $APP_NAME-$ENVIRONMENT \
  --restart unless-stopped \
  -p $PORT:8080 \
    -e SPRING_DATASOURCE_URL="jdbc:postgresql://host.docker.internal:5433/n8n" \
    -e SPRING_DATASOURCE_USERNAME="postgres" \
    -e SPRING_DATASOURCE_PASSWORD="postgres" \
  -e SPRING_PROFILES_ACTIVE="$ENVIRONMENT" \
  $DOCKER_IMAGE

# 헬스체크
echo "🏥 Performing health check..."
sleep 30

for i in {1..10}; do
  if curl -f http://localhost:$PORT/actuator/health >/dev/null 2>&1; then
    echo "✅ Health check passed!"
    break
  else
    echo "⏳ Health check attempt $i/10 failed, retrying in 10 seconds..."
    sleep 10
  fi
  
  if [ $i -eq 10 ]; then
    echo "❌ Health check failed after 10 attempts"
    echo "📋 Container logs:"
    docker logs $APP_NAME-$ENVIRONMENT
    exit 1
  fi
done

echo "🎉 Deployment completed successfully!"
echo "🌐 Application is running at: http://localhost:$PORT"
echo "📊 Health check: http://localhost:$PORT/actuator/health"
