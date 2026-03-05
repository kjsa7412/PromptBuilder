#!/usr/bin/env bash
# ============================================================
# scripts/pii_scan.sh -- 개인정보(PII) 패턴 스캔
# ============================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "--- PII Scan ---"

FOUND=0

# 전화번호 패턴 (한국)
PHONE=$(grep -rEo '01[0-9]-[0-9]{3,4}-[0-9]{4}' "${ROOT_DIR}" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir="target" \
    --exclude-dir=".next" \
    --exclude="pii_scan.sh" \
    2>/dev/null || true)
if [[ -n "${PHONE}" ]]; then
    echo "  NG: 전화번호 패턴 발견"
    echo "${PHONE}" | head -3
    FOUND=$((FOUND+1))
fi

# 주민등록번호 패턴
RRN=$(grep -rEo '[0-9]{6}-[1-4][0-9]{6}' "${ROOT_DIR}" \
    --exclude-dir=".git" \
    --exclude-dir="node_modules" \
    --exclude-dir="target" \
    --exclude-dir=".next" \
    --exclude="pii_scan.sh" \
    2>/dev/null || true)
if [[ -n "${RRN}" ]]; then
    echo "  NG: 주민등록번호 패턴 발견"
    echo "${RRN}" | head -3
    FOUND=$((FOUND+1))
fi

if [[ ${FOUND} -gt 0 ]]; then
    echo "FAIL: ${FOUND}개 PII 패턴 발견"
    exit 1
else
    echo "PASS: 개인정보 패턴 없음"
fi
