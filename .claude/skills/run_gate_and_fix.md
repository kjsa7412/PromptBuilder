# Skill: run_gate_and_fix

## 목적
게이트 실행 → 실패 트리아지 → 수정 루프

## 실행 순서

```bash
# 1. 실행 권한 부여
chmod +x scripts/*.sh

# 2. 게이트 실행
./scripts/gate.sh 2>&1 | tee /tmp/gate_output.txt

# 3. 실패 항목 확인
grep "FAIL:" /tmp/gate_output.txt

# 4. 항목별 수정
# - Secret Scan FAIL: 민감 정보 제거/env 변수화
# - PII Scan FAIL: 실제 PII 데이터 제거
# - Front Build FAIL: TypeScript 오류/빌드 설정 수정
# - Back Test FAIL: 테스트 코드 수정
# - Back Build FAIL: 컴파일 오류 수정

# 5. 재실행
./scripts/gate.sh
```

## 수정 가이드

### TypeScript 오류
```bash
cd front && npx tsc --noEmit 2>&1 | head -50
```

### Spring 빌드 오류
```bash
cd back && ./mvnw test 2>&1 | tail -50
```

### 테스트 실패
- 테스트 코드 검토
- mock 설정 확인
- 환경변수 확인
