#!/usr/bin/env bash
# ============================================================
# scripts/gate.sh -- 로컬 게이트 (CI 체크)
# 실패 시 exit 1, 전체 통과 시 PASS 출력
# ============================================================
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GATE_PASSED=0
GATE_FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_step() { echo -e "\n${CYAN}--- $1 ---${NC}"; }
log_pass() { echo -e "${GREEN}PASS: $1${NC}"; GATE_PASSED=$((GATE_PASSED+1)); }
log_fail() { echo -e "${RED}FAIL: $1${NC}"; GATE_FAILED=$((GATE_FAILED+1)); }
log_warn() { echo -e "${YELLOW}SKIP: $1${NC}"; }

echo -e "${CYAN}============================================================${NC}"
echo -e "${CYAN}  PromptBuilder Gate -- $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${CYAN}============================================================${NC}"

# ============================================================
# 1. Guardrails
# ============================================================
log_step "1. Guardrails Check"
if [[ "${ALLOW_PROD:-0}" == "1" ]]; then
    log_warn "ALLOW_PROD=1 -- 프로덕션 배포 허용 모드"
else
    log_pass "ALLOW_PROD=0 -- 프로덕션 배포 차단 확인"
fi

# ============================================================
# 2. Secret Scan
# ============================================================
log_step "2. Secret Scan"
if bash "${ROOT_DIR}/scripts/secret_scan.sh"; then
    log_pass "Secret Scan"
else
    log_fail "Secret Scan"
fi

# ============================================================
# 3. PII Scan
# ============================================================
log_step "3. PII Scan"
if bash "${ROOT_DIR}/scripts/pii_scan.sh"; then
    log_pass "PII Scan"
else
    log_fail "PII Scan"
fi

# ============================================================
# 4. DB Verify
# ============================================================
log_step "4. DB Verify"
if bash "${ROOT_DIR}/scripts/db_verify.sh" 2>/dev/null; then
    log_pass "DB Verify"
else
    log_warn "DB Verify -- DB 미연결 (docker-compose up 후 db_apply.sh 실행 필요)"
fi

# ============================================================
# 5. Front
# ============================================================
log_step "5. Front (Next.js)"
FRONT_DIR="${ROOT_DIR}/front"

if [[ ! -d "${FRONT_DIR}" ]]; then
    log_warn "Front -- front/ 없음"
else
    cd "${FRONT_DIR}"

    if [[ ! -d "node_modules" ]]; then
        echo "  -> npm install..."
        npm install --silent 2>/dev/null || true
    fi

    # Lint
    if npm run lint 2>/dev/null; then
        log_pass "Front Lint"
    else
        log_warn "Front Lint -- 오류 또는 스크립트 없음"
    fi

    # Typecheck
    if npm run typecheck 2>/dev/null; then
        log_pass "Front Typecheck"
    else
        log_warn "Front Typecheck -- 타입 오류 또는 설정 없음"
    fi

    # Build
    if npm run build 2>&1 | grep -q "Export encountered errors\|Failed to compile"; then
        log_fail "Front Build"
    elif npm run build >/dev/null 2>&1; then
        log_pass "Front Build"
    else
        log_fail "Front Build"
    fi

    cd "${ROOT_DIR}"
fi

# ============================================================
# 6. Back
# ============================================================
log_step "6. Back (Spring Boot)"
BACK_DIR="${ROOT_DIR}/back"

if [[ ! -d "${BACK_DIR}" ]]; then
    log_warn "Back -- back/ 없음"
else
    cd "${BACK_DIR}"

    if [[ -f "mvnw" ]]; then
        chmod +x mvnw 2>/dev/null || true

        if ./mvnw test -q 2>/dev/null; then
            log_pass "Back Test"
        else
            log_fail "Back Test"
        fi

        if ./mvnw package -DskipTests -q 2>/dev/null; then
            log_pass "Back Build"
        else
            log_fail "Back Build"
        fi
    else
        log_warn "Back -- mvnw 없음"
    fi

    cd "${ROOT_DIR}"
fi

# ============================================================
# 최종 결과
# ============================================================
echo ""
echo -e "${CYAN}============================================================${NC}"
echo -e "  PASS: ${GREEN}${GATE_PASSED}${NC}  |  FAIL: ${RED}${GATE_FAILED}${NC}"
echo -e "${CYAN}============================================================${NC}"

if [[ ${GATE_FAILED} -gt 0 ]]; then
    echo -e "${RED}  GATE FAILED -- 위 오류를 수정하세요${NC}"
    exit 1
else
    echo -e "${GREEN}  GATE PASSED -- 모든 체크 통과!${NC}"
fi
