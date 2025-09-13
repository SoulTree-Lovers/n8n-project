#!/bin/bash

# 헬스체크 스크립트
# 사용법: ./health-check.sh [environment]

set -e

ENVIRONMENT=${1:-production}

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

APP_NAME="n8n-cicd"
CONTAINER_NAME="$APP_NAME-$ENVIRONMENT"

echo "🏥 Performing health check for $ENVIRONMENT environment..."
echo "Container: $CONTAINER_NAME"
echo "Port: $PORT"

# 컨테이너 상태 확인
if ! docker ps | grep -q $CONTAINER_NAME; then
  echo "❌ Container $CONTAINER_NAME is not running"
  exit 1
fi

# 애플리케이션 헬스체크
HEALTH_URL="http://localhost:$PORT/actuator/health"
echo "🔍 Checking health endpoint: $HEALTH_URL"

for i in {1..5}; do
  if curl -f $HEALTH_URL >/dev/null 2>&1; then
    echo "✅ Health check passed!"
    
    # 상세 정보 출력
    echo "📊 Health details:"
    curl -s $HEALTH_URL | jq '.' 2>/dev/null || curl -s $HEALTH_URL
    
    # 메모리 사용량 확인
    echo "💾 Memory usage:"
    docker stats $CONTAINER_NAME --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
    
    exit 0
  else
    echo "⏳ Health check attempt $i/5 failed, retrying in 5 seconds..."
    sleep 5
  fi
done

echo "❌ Health check failed after 5 attempts"
echo "📋 Container logs (last 50 lines):"
docker logs --tail 50 $CONTAINER_NAME

exit 1
