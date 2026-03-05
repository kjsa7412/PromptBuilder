# 테스트 계획 (TESTPLAN)

## 게이트 조건 (gate.sh)

| 체크 항목 | 조건 |
|---------|------|
| front lint | ESLint 오류 없음 |
| front typecheck | tsc --noEmit 통과 |
| front build | next build 성공 |
| back test | ./mvnw test (최소 1개 PASS) |
| back build | ./mvnw package -DskipTests |
| db verify | db_verify.sh PASS |
| secret scan | secret_scan.sh PASS |
| pii scan | pii_scan.sh PASS |
