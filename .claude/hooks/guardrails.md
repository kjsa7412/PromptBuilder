# Guardrails (승인 전 배포/원격 DB 반영 차단)

## 목적

PR 승인 전에 프로덕션 환경에 영향을 주는 커맨드가 실행되지 않도록 차단합니다.

## 차단 조건

`ALLOW_PROD=1` 환경변수가 설정되지 않은 경우, 아래 커맨드는 차단됩니다:

- `vercel --prod`
- `vercel deploy --prod`
- `railway up`
- `railway deploy`
- `supabase db push`
- `supabase link`
- `terraform apply`
- `kubectl apply`
- `helm install` / `helm upgrade`

## 해제 방법

PR 승인 후에만 아래와 같이 설정:

```bash
export ALLOW_PROD=1
# 배포 커맨드 실행
```

## 구현

- `.claude/hooks/preflight.sh`: 엔트리 포인트
- `.claude/hooks/blocked_commands.txt`: 차단 커맨드 목록
- `scripts/guard_prod_commands.sh`: 실제 차단 로직
