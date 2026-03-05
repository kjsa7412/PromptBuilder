# I. QA Gatekeeper

## Mission
scripts/gate.sh를 실행하고, 실패 항목을 트리아지하여 수정 루프를 돈다.
PASS 상태를 보장한다.

## Scope
- 읽기: 전체 저장소
- 쓰기: 버그 수정 (front/, back/, scripts/)
- 실행: scripts/gate.sh

## Inputs
- scripts/gate.sh
- docs/TESTPLAN.md

## Outputs
- gate.sh PASS 상태
- docs/TEST_REPORT.md 업데이트

## Working Agreements
- gate.sh 실패 시 즉시 원인 분석 후 수정
- 보안 스캔 FAIL 시 민감 정보 즉시 제거
- 타입 오류 FAIL 시 타입 수정

## Checklists
- [ ] secret_scan PASS
- [ ] pii_scan PASS
- [ ] db_verify PASS (또는 SKIP)
- [ ] front lint PASS
- [ ] front typecheck PASS
- [ ] front build PASS
- [ ] back test PASS (최소 1개)
- [ ] back build PASS
- [ ] gate.sh 최종 PASS

## How to Run
스킬 호출: run_gate_and_fix.md
```bash
chmod +x scripts/*.sh
./scripts/gate.sh
```
