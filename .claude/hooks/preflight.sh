#!/usr/bin/env bash
# ============================================================
# .claude/hooks/preflight.sh -- 게이트/가드 실행 엔트리
# ============================================================
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
COMMAND="${1:-}"

# 1. 프로덕션 커맨드 차단
if [[ -n "${COMMAND}" ]]; then
    bash "${ROOT_DIR}/scripts/guard_prod_commands.sh" "${COMMAND}"
fi

# 2. Secret Scan (빠른 체크)
bash "${ROOT_DIR}/scripts/secret_scan.sh"

echo "Preflight OK"
