# Skill: add_gate_scripts

## 목적
scripts/gate.sh 및 하위 스크립트를 생성한다.

## 파일 목록
- scripts/gate.sh: 메인 게이트
- scripts/db_apply.sh: DB 마이그레이션 적용
- scripts/db_verify.sh: DB 검증
- scripts/secret_scan.sh: 민감 정보 스캔
- scripts/pii_scan.sh: PII 스캔
- scripts/guard_prod_commands.sh: 프로덕션 차단
- scripts/install_githooks.sh: git hooks 설치

## 실행
```bash
chmod +x scripts/*.sh
./scripts/gate.sh
```

## gate.sh 체크 항목
1. Guardrails (ALLOW_PROD 체크)
2. Secret Scan
3. PII Scan
4. DB Verify
5. Front: lint + typecheck + build
6. Back: test + build
