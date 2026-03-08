#!/bin/bash
# 백엔드 로컬 실행 (Supabase DB 사용)
cd "$(dirname "$0")/../back"

SPRING_DATASOURCE_URL="jdbc:postgresql://aws-1-ap-southeast-2.pooler.supabase.com:6543/postgres?sslmode=require" \
SPRING_DATASOURCE_USERNAME="postgres.etrjyirxrjquuidytxhp" \
SPRING_DATASOURCE_PASSWORD="An44mFybigZyuFwU" \
JWT_JWKS_URL="https://etrjyirxrjquuidytxhp.supabase.co/auth/v1/.well-known/jwks.json" \
JWT_ISSUER="https://etrjyirxrjquuidytxhp.supabase.co/auth/v1" \
JWT_AUDIENCE="authenticated" \
CORS_ALLOWED_ORIGINS="https://prompt-builder-tawny.vercel.app,http://localhost:3000" \
./mvnw spring-boot:run
