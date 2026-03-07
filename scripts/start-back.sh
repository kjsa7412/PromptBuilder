#!/usr/bin/env bash
# back/.env 환경변수 로드 후 Spring Boot 실행
set -a
ENV_FILE="$(dirname "$0")/../back/.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
else
    echo "[WARN] back/.env 파일이 없습니다. .env.example에서 복사하세요."
fi
set +a
cd "$(dirname "$0")/../back"
./mvnw spring-boot:run
