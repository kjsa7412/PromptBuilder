# 환경 설정 (ENVIRONMENTS)

## 환경 종류

| 환경 | Front | Back | DB |
|------|-------|------|-----|
| local | localhost:3000 | localhost:8080 | docker postgres |
| staging | Vercel Preview | Railway Preview | Supabase (확인 필요) |
| production | Vercel Prod | Railway Prod | Supabase Prod |

## 환경변수 관리

- local: .env (git 제외)
- staging/prod: Vercel/Railway 대시보드에서 설정

## 로컬 설정

```bash
cp .env.example .env
docker-compose up -d
./scripts/db_apply.sh
```
