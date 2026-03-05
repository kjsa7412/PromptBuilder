#!/usr/bin/env bash
# ============================================================
# scripts/guard_prod_commands.sh -- 프로덕션 커맨드 차단
# ALLOW_PROD=1 이 아니면 차단
# ============================================================
set -euo pipefail

COMMAND="${1:-}"

BLOCKED_PATTERNS=(
    "vercel --prod"
    "vercel deploy --prod"
    "railway up"
    "railway deploy"
    "supabase db push"
    "supabase link"
    "terraform apply"
)

if [[ "${ALLOW_PROD:-0}" == "1" ]]; then
    exit 0
fi

for blocked in "${BLOCKED_PATTERNS[@]}"; do
    if echo "${COMMAND}" | grep -q "${blocked}"; then
        echo "BLOCKED: 프로덕션 커맨드 차단됨"
        echo "커맨드: ${COMMAND}"
        echo "PR 승인 후 ALLOW_PROD=1 설정 시에만 허용됩니다."
        exit 1
    fi
done
