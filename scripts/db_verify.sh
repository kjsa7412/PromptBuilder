#!/usr/bin/env bash
# ============================================================
# scripts/db_verify.sh -- DB 검증 (테이블/뷰 존재 여부)
# ============================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "${ROOT_DIR}/.env" ]]; then
    set -a; source "${ROOT_DIR}/.env"; set +a
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-promptbuilder}"
DB_USER="${DB_USER:-promptbuilder}"
export PGPASSWORD="${DB_PASSWORD:-changeme}"

REQUIRED_TABLES=(
    "profiles" "prompts" "prompt_versions"
    "prompt_variables" "bookmarks" "likes" "usage_events"
)

FAILED=0

echo "--- DB Verify: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME} ---"

if ! command -v psql &>/dev/null; then
    echo "WARN: psql 없음 -- SKIP"
    exit 0
fi

if ! psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
     -c "SELECT 1" -q >/dev/null 2>&1; then
    echo "WARN: DB 연결 실패 -- SKIP (docker-compose up 필요)"
    exit 0
fi

for table in "${REQUIRED_TABLES[@]}"; do
    EXISTS=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
        -tAc "SELECT COUNT(*) FROM information_schema.tables
              WHERE table_schema='public' AND table_name='${table}'" 2>/dev/null)
    if [[ "${EXISTS}" == "1" ]]; then
        echo "  OK: ${table}"
    else
        echo "  NG: ${table} -- 없음"
        FAILED=$((FAILED+1))
    fi
done

for view in "v_trending_scores" "v_public_prompts"; do
    EXISTS=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
        -tAc "SELECT COUNT(*) FROM information_schema.views
              WHERE table_schema='public' AND table_name='${view}'" 2>/dev/null)
    if [[ "${EXISTS}" == "1" ]]; then
        echo "  OK: VIEW ${view}"
    else
        echo "  NG: VIEW ${view} -- 없음"
        FAILED=$((FAILED+1))
    fi
done

echo ""
if [[ ${FAILED} -gt 0 ]]; then
    echo "FAIL: ${FAILED}개 항목 없음 (db_apply.sh 실행 필요)"
    exit 1
else
    echo "PASS: 모든 테이블/뷰 존재"
fi
