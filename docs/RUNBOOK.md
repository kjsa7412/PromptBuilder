# 운영 런북 (RUNBOOK)

## 로컬 개발 환경 시작

```bash
# 1. DB 시작
docker-compose up -d

# 2. DB 마이그레이션
./scripts/db_apply.sh

# 3. 백엔드 시작
cd back && ./mvnw spring-boot:run

# 4. 프론트엔드 시작
cd front && npm run dev
```

## 게이트 실행

```bash
./scripts/gate.sh
```

## 배포 (ALLOW_PROD=1 필요)

```bash
export ALLOW_PROD=1
cd front && vercel --prod
cd back && railway up
```

## 트러블슈팅

### DB 연결 실패
```bash
docker-compose ps
docker-compose logs postgres
```

### JWT 검증 실패
- SUPABASE_JWKS_URL 환경변수 확인
- 토큰 만료 여부 확인 (exp 클레임)
