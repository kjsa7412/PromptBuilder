# 패치 프로토콜 (PATCH_PROTOCOL)

> 수정 요청 시 Claude가 따라야 하는 표준 실행 절차.
> 이 문서는 모든 패치 작업의 공통 지시사항으로, 요청마다 별도로 언급하지 않아도 항상 적용된다.

---

## 1. 실행 원칙

### 1.1 병렬 에이전트 분할

수정 항목이 2개 이상인 경우 반드시 Agent 도구로 병렬 실행한다.

| 에이전트 분류 기준 | 설명 |
|---|---|
| **backend** | Java/Spring, MyBatis XML, DB 마이그레이션 |
| **frontend** | Next.js 컴포넌트, 페이지, api.ts |
| **db** | 스키마 변경, 인덱스, 뷰, 마이그레이션 파일 |
| **test** | 테스트 케이스 작성 및 풀 시나리오 실행 |

- 백엔드/프론트엔드 수정이 독립적이면 동시에 에이전트 실행.
- DB 스키마 변경이 있으면 **DB 에이전트가 먼저 완료**된 후 백엔드/프론트 에이전트 실행.
- 테스트 에이전트는 **모든 수정 에이전트 완료 후** 실행.

### 1.2 DB 스키마 변경 처리

DB 변경이 포함된 경우:

1. `db/migrations/NNN_설명.sql` 마이그레이션 파일 작성
2. `docs/DB.md` 업데이트 (테이블/컬럼 변경 내역 반영)
3. 로컬 Docker DB에 즉시 적용:
   ```bash
   docker cp db/migrations/NNN_설명.sql promptbuilder_db:/tmp/NNN.sql
   docker exec promptbuilder_db psql -U promptbuilder -d promptbuilder -f /tmp/NNN.sql
   ```
4. 적용 결과 확인 후 백엔드/프론트 작업 시작

**DB 반영 없이 테스트를 진행하지 않는다.**

### 1.3 TypeScript 타입 검사

프론트엔드 수정이 포함된 모든 패치 후:

```bash
cd front && npx tsc --noEmit
```

오류가 있으면 수정 후 재검사. 통과 후 다음 단계 진행.

### 1.4 백엔드 빌드

백엔드 수정이 포함된 모든 패치 후:

```bash
cd back && ./mvnw package -q -DskipTests
```

---

## 2. 테스트 프로토콜

### 2.1 테스트 케이스 작성

패치된 각 기능에 대해 테스트 케이스를 `docs/TEST_SCENARIOS.md`에 추가한다.

테스트 케이스 형식:
```
### TC-NNN: 기능명
- **전제조건**: 테스트 수행 전 필요한 상태
- **입력**: API 호출 또는 UI 행동
- **기대 결과**: 정상 동작 기준
- **실패 기준**: 무엇이 일어나면 실패로 간주
```

### 2.2 풀 테스트 시나리오 실행

테스트는 실제 데이터로 API를 직접 호출하여 수행한다.

**실행 순서:**
1. 테스트용 유저 세션 획득 (Supabase 토큰)
2. 테스트 데이터 생성 (프롬프트, 포스트프롬프트 등)
3. 각 TC를 `curl` 또는 `fetch`로 실행
4. 응답 검증 (status code, 응답 바디 구조, 필드 값)
5. 부작용 검증 (DB 카운트 변화, 관련 API 응답 변화)
6. 테스트 데이터 정리 (선택)

**검증 기준:**
- HTTP 상태 코드가 기대값과 일치
- 응답 JSON에 필요한 필드가 모두 존재
- 실서비스 동작과 동일한 결과

### 2.3 테스트 결과 기록

테스트 완료 후 반드시 `docs/TEST_RESULTS.md`에 기록:

```markdown
## YYYY-MM-DD 패치명 테스트 결과

| TC | 기능 | 결과 | 비고 |
|---|---|---|---|
| TC-001 | ... | PASS/FAIL | ... |

### 실패 항목
- TC-XXX: 실패 원인 및 수정 내용
```

결과 기록이 부실하면 (PASS/FAIL 여부만 기록하는 등) **재작성**한다.

---

## 3. 서비스 재시작

모든 수정 및 테스트 완료 후:

```bash
# 백엔드 재시작
pkill -f "promptbuilder" 2>/dev/null
cd back && nohup java -jar target/promptbuilder-0.0.1-SNAPSHOT.jar > /tmp/back.log 2>&1 &

# 프론트엔드 재시작
pkill -f "next" 2>/dev/null
cd front && nohup npm run dev > /tmp/front.log 2>&1 &

# 헬스체크
sleep 8 && curl -s 'http://localhost:8080/api/public/prompts/trending?limit=1'
```

---

## 4. 작업 결과 문서화

패치 작업이 완료되면 아래 문서를 업데이트한다.

| 문서 | 업데이트 조건 |
|---|---|
| `docs/TEST_RESULTS.md` | 매 패치마다 테스트 결과 추가 |
| `docs/TEST_SCENARIOS.md` | 새 기능 TC 추가 |
| `docs/DB.md` | DB 스키마 변경 시 |
| `docs/API.yaml` | API 변경 시 |
| `docs/RELEASE.md` | 주요 기능 변경 시 릴리즈 노트 추가 |

**기록이 부실하거나 누락된 경우, 해당 섹션을 보완하고 이 프로토콜 문서에 누락된 지시사항을 추가한다.**

---

## 5. 공통 체크리스트

패치 완료 후 아래를 순서대로 확인:

- [ ] DB 마이그레이션 파일 작성 및 로컬 DB 적용 완료
- [ ] 백엔드 빌드 성공 (`mvnw package -DskipTests`)
- [ ] TypeScript 타입 검사 통과 (`tsc --noEmit`)
- [ ] 테스트 케이스 문서화 (`TEST_SCENARIOS.md`)
- [ ] 풀 테스트 시나리오 실행 완료
- [ ] 테스트 결과 기록 (`TEST_RESULTS.md`)
- [ ] 서비스 재시작 및 헬스체크
- [ ] 관련 문서 업데이트

---

## 6. 이 프로토콜의 업데이트 규칙

작업 중 이 프로토콜로 커버되지 않는 상황이 발생하면:

1. 해당 상황을 처리하고
2. 이 문서에 해당 케이스를 추가

예: DB stdin 적용이 실패하는 경우 → `docker cp` 방식을 이 문서에 명시.
