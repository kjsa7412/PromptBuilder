#!/usr/bin/env bash
# ============================================================
# scripts/secret_scan.sh -- 민감 정보 패턴 스캔
# ============================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "--- Secret Scan ---"

FOUND=0

scan_pattern() {
    local pattern="$1"
    local label="$2"
    local results
    # .sh/.yaml/.md/.example 제외 (스크립트 기본값 false positive 방지)
    results=$(grep -rEil "${pattern}" "${ROOT_DIR}" \
        --exclude-dir=".git" \
        --exclude-dir="node_modules" \
        --exclude-dir="target" \
        --exclude-dir=".next" \
        --exclude-dir="dist" \
        --exclude-dir="build" \
        --exclude-dir="scripts" \
        --exclude="*.example" \
        --exclude="*.md" \
        --exclude="*.sh" \
        --exclude="*.yaml" \
        --exclude="*.yml" \
        2>/dev/null || true)
    if [[ -n "${results}" ]]; then
        echo "  NG [${label}]:"
        echo "${results}" | head -3
        FOUND=$((FOUND+1))
    fi
}

scan_pattern "-----BEGIN (RSA |EC )?PRIVATE KEY" "PRIVATE KEY"
scan_pattern "aws[_-]?secret[_-]?access[_-]?key\s*[=:]\s*['\"][A-Za-z0-9/+]{20,}" "AWS SECRET"

if [[ ${FOUND} -gt 0 ]]; then
    echo "FAIL: ${FOUND}개 패턴 발견"
    exit 1
else
    echo "PASS: 민감 정보 패턴 없음"
fi
