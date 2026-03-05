#!/usr/bin/env bash
# ============================================================
# scripts/db_apply.sh -- DB 마이그레이션 적용
# ============================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="${ROOT_DIR}/db/migrations"

if [[ -f "${ROOT_DIR}/.env" ]]; then
    set -a; source "${ROOT_DIR}/.env"; set +a
fi

DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-promptbuilder}"
DB_USER="${DB_USER:-promptbuilder}"
export PGPASSWORD="${DB_PASSWORD:-changeme}"

echo "--- DB Apply: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME} ---"

if ! command -v psql &>/dev/null; then
    echo "ERROR: psql 없음. postgresql-client 설치 필요"
    exit 1
fi

for sql_file in $(ls "${MIGRATIONS_DIR}"/*.sql 2>/dev/null | sort); do
    echo "-> 적용: $(basename ${sql_file})"
    psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" \
         -f "${sql_file}" --set=ON_ERROR_STOP=1 -q
    echo "   완료"
done

echo ""
echo "PASS: 모든 마이그레이션 적용 완료"
