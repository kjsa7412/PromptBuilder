#!/usr/bin/env bash
# ============================================================
# scripts/install_githooks.sh -- git hooks 설치
# ============================================================
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS_DIR="${ROOT_DIR}/.git/hooks"

if [[ ! -d "${HOOKS_DIR}" ]]; then
    echo "ERROR: .git/hooks 없음. git 저장소인지 확인하세요."
    exit 1
fi

cat > "${HOOKS_DIR}/pre-push" << 'HOOK'
#!/usr/bin/env bash
echo "--- pre-push: gate.sh 실행 ---"
ROOT_DIR="$(git rev-parse --show-toplevel)"
bash "${ROOT_DIR}/scripts/gate.sh"
HOOK

chmod +x "${HOOKS_DIR}/pre-push"
echo "PASS: pre-push hook 설치됨"
