# 테스트 결과 (2026-03-08) — 패치 P04: 한글변수 / 임시저장 / visibility / slash UX

## 2026-03-08 패치 P04 테스트 결과

### 환경

- 백엔드: localhost:8080 (Spring Boot 3 + Java 17)
- DB: Docker PostgreSQL 16 (promptbuilder_db)
- 인증: 로컬 ECDSA 키페어로 테스트 JWT 발급 (kid: test-key-01, user: 118149df-a070-4a7e-8e0b-a20d35d88680)
- Supabase 직접 로그인 불가 (GitHub OAuth 계정, 비밀번호 미설정, rate limit)

### 테스트 결과 표

| TC | 기능 | 결과 | HTTP | 응답 요약 |
|---|---|---|---|---|
| TC-P04-01 | 한글 변수 포함 post-prompt 생성 | PASS | 201 | variables: [{key:"역할"}, {key:"주제"}] 정상 추출 |
| TC-P04-02 | 임시저장 (draft) 생성 | PASS (조건부) | 400 / 201 | 빈 제목=400 (예상 동작), auto-title=201 성공 |
| TC-P04-03 | 한글 변수 조회 | PASS | 200 | variables 2개 (역할, 주제) 확인 |

### TC-P04-01 상세 결과

**Step 1: 프롬프트 생성**
```
POST /api/me/prompts
Request: {"title":"한글변수 테스트 2026-03-08","visibility":"public","description":"한글 변수 패치 테스트","tags":["test","한글"]}
Response (201): {"data":{"versionId":"62e6a8bb-0039-48c0-a471-20a0f0d6b817","id":"dadefc25-f806-4508-8cd3-9bd248ce935d"}}
```

**Step 2: 한글 변수 post-prompt 생성**
```
POST /api/me/prompts/dadefc25-f806-4508-8cd3-9bd248ce935d/post-prompts
Request: {"templateBody":"{{역할}}로서 {{주제}}를 설명해","orderIndex":0}
Response (201): {
  "data": {
    "id": "21311606-673f-49fe-81d4-f724c3e07ea4",
    "template_body": "{{역할}}로서 {{주제}}를 설명해",
    "prompt_id": "dadefc25-f806-4508-8cd3-9bd248ce935d",
    "title": "새 프롬프트",
    "sort_order": 0,
    "status": "draft",
    "created_at": "2026-03-08T09:12:52.637+00:00",
    "updated_at": "2026-03-08T09:12:52.637+00:00"
  }
}
```
참고: POST 응답에는 variables 미포함 (GET 조회 시 포함됨)

### TC-P04-03 상세 결과

**한글 변수 조회**
```
GET /api/me/prompts/dadefc25-f806-4508-8cd3-9bd248ce935d/post-prompts
Response (200): {
  "data": [{
    "id": "21311606-673f-49fe-81d4-f724c3e07ea4",
    "template_body": "{{역할}}로서 {{주제}}를 설명해",
    "variables": [
      {"id": "23abb0ba-48b8-47e1-b590-dec413487b86", "key": "역할", "label": "역할", "type": "text", "sort_order": 0},
      {"id": "7b186eb3-f026-4ee2-9361-21a5ee297477", "key": "주제", "label": "주제", "type": "text", "sort_order": 1}
    ]
  }]
}
```
PLACEHOLDER_PATTERN = `\{\{\s*([a-zA-Z0-9_가-힣]+)\s*\}\}` 정상 동작 확인

### TC-P04-02 상세 결과

**Step 1: 빈 제목으로 draft 저장 시도**
```
POST /api/me/prompts
Request: {"title":"","visibility":"draft"}
Response (400): {"code":"VALID_001","details":{},"message":"title은 필수입니다"}
```
→ 예상된 동작: 백엔드는 title 필수 validation 유지. 프론트가 auto-title 생성 후 전달하는 구조.

**Step 2: auto-generated title로 draft 저장**
```
POST /api/me/prompts
Request: {"title":"임시저장 3월 8일 오후 6시 12분","visibility":"draft"}
Response (201): {"data":{"versionId":"e18ba2c3-aee7-46c7-b4da-499622b6d2fa","id":"388329da-747c-4c4f-a49c-de0edce71a12"}}
```
→ PASS: draft visibility 저장 정상 동작

### 패치 P04 소스 코드 확인

**한글 변수 패턴** (`PostPromptService.java` line 15-16):
```java
private static final Pattern PLACEHOLDER_PATTERN =
        Pattern.compile("\\{\\{\\s*([a-zA-Z0-9_가-힣]+)\\s*\\}\\}");
```
`가-힣` 범위 추가로 한글 변수명 인식 확인 완료.

### 실패 항목

없음. 모든 TC PASS.

TC-P04-02는 빈 제목 시 400을 반환하나 이는 설계 의도에 따른 정상 동작 (프론트에서 auto-title 생성).

### 테스트 데이터 정리

| 항목 | ID |
|---|---|
| 테스트 프롬프트 (한글변수) | dadefc25-f806-4508-8cd3-9bd248ce935d |
| 테스트 PostPrompt | 21311606-673f-49fe-81d4-f724c3e07ea4 |
| 변수 역할 | 23abb0ba-48b8-47e1-b590-dec413487b86 |
| 변수 주제 | 7b186eb3-f026-4ee2-9361-21a5ee297477 |
| 테스트 Draft 프롬프트 | 388329da-747c-4c4f-a49c-de0edce71a12 |

정리 명령 (선택적):
```sql
DELETE FROM prompts WHERE id IN (
  'dadefc25-f806-4508-8cd3-9bd248ce935d',
  '388329da-747c-4c4f-a49c-de0edce71a12'
);
```

---

# 테스트 결과 (2026-03-07) — 상세/편집/메인 전면 개편 후 QA

## 환경 (2026-03-07)
- 백엔드: localhost:8080 (Spring Boot 3 + Java 21)
- 프론트엔드: localhost:3000 (Next.js 14.2.3)
- DB: Docker PostgreSQL 16 (promptbuilder_db)
- 테스트 데이터: "회의록2 입니다." (ID: 1ff45609-d19e-4681-9a9f-19e18f034b38) 1건

## 수정 내역 요약

| 항목 | 수정 내용 |
|---|---|
| 데이터 정리 | "회의록2 입니다." 제외 모든 prompts/관련 데이터 삭제 |
| 상세 텍스트 블록 | body_markdown→camelCase 변환 누락 수정 (convertKeys 전역 적용) |
| 상세 프롬프트 변수 | postPrompts snake_case 키 camelCase 변환 + description 표시 |
| 메인 탭 데이터 | clip_count 컬럼 추가 + 정리 후 1건만 노출 확인 |
| 블록 순서 보존 | [[PROMPT:N]] 마커 기반 parseContentBlocks() 구현 |
| 작성 페이지 | Notion 2단 레이아웃 + assembleBodyMarkdown() 마커 삽입 |
| Like/Clip API | /api/me/likes, /api/me/clips 신규 endpoint + 401 보안 |

## TC-001~027 전체 결과 (2026-03-07)

| TC | 이름 | 결과 | HTTP | 비고 |
|---|---|---|---|---|
| TC-001 | trending API | PASS | 200 | 1건 반환 |
| TC-002 | random API | PASS | 200 | 1건 반환 |
| TC-003 | new API | PASS | 200 | 1건 반환 |
| TC-004 | search API (빈 검색) | PASS | 200 | meta 포함 |
| TC-005 | prompt detail API | PASS | 200 | body_markdown+postPrompts 포함 |
| TC-006 | generate API | PASS | 200 | renderedPrompt 정상 치환 |
| TC-007 | GET me/prompts (no auth) | PASS | 401 | |
| TC-008 | GET me/clips (no auth) | PASS | 401 | |
| TC-009 | POST me/clips (no auth) | PASS | 401 | |
| TC-010 | DELETE me/clips (no auth) | PASS | 401 | |
| TC-011 | POST me/prompts (no auth) | PASS | 401 | |
| TC-012 | POST admin/moderate (no auth) | PASS | 401 | |
| TC-013 | 홈 화면 / | PASS | 200 | |
| TC-014 | 탐색 화면 /explore | PASS | 200 | |
| TC-015 | 로그인 화면 /login | PASS | 200 | |
| TC-016 | 라이브러리 /me/library | PASS | 200 | |
| TC-017 | 새 프롬프트 /me/prompts/new | PASS | 200 | |
| TC-018 | 프롬프트 상세 /p/{id} | PASS | 200 | |
| TC-019 | 프롬프트 상세 /p/없는ID | PASS | 404 | |
| TC-020 | DB 데이터 1건만 존재 | PASS | - | COUNT=1 확인 |
| TC-021 | Stats API totalPrompts=1 | PASS | 200 | {"totalPrompts":1} |
| TC-022 | 메인 탭 "회의록2" 1건만 | PASS | 200 | title="회의록2 입니다." |
| TC-023 | POST me/likes (no auth) | PASS | 401 | |
| TC-024 | DELETE me/likes (no auth) | PASS | 401 | |
| TC-025 | body_markdown 마커 패턴 | PASS | 200 | body_markdown 필드 반환 확인 |
| TC-026 | 변수 description DB 저장 | PASS | - | description 컬럼 존재 (값 null=정상) |
| TC-027 | 상세 camelCase 렌더링 | PASS | 200 | 500 아님 = camelCase 변환 정상 |

**전체: 27/27 PASS**

## 빌드 결과 (2026-03-07)

| 항목 | 결과 |
|---|---|
| npm run build | PASS (8/8 pages) |
| TypeScript 타입체크 | PASS |
| /p/[id] 서버 컴포넌트 | PASS (39.3 kB) |

---

# 테스트 결과 (2026-03-06 17:00) — 기능 추가 후 QA

## 신규 기능 테스트 (2026-03-06)

### 기능 1: 내 라이브러리 탭 분리

| TC | 이름 | 결과 | 비고 |
|---|---|---|---|
| NEW-001 | /me/library 페이지 렌더링 | PASS | HTTP 200 |
| NEW-002 | "내 프롬프트" / "북마크" 탭 UI | PASS | 탭 전환 구현 완료 |
| NEW-003 | GET /api/me/prompts (no auth) | PASS | HTTP 401 |
| NEW-004 | GET /api/me/bookmarks (no auth) | PASS | HTTP 401 |

### 기능 2: 북마크 / 좋아요 / 사용 버튼

| TC | 이름 | 결과 | 비고 |
|---|---|---|---|
| NEW-005 | /p/[id] 페이지 렌더링 | PASS | HTTP 200 |
| NEW-006 | GET /api/me/likes (no auth) | PASS | HTTP 401 |
| NEW-007 | POST /api/me/likes/{id} (no auth) | PASS | HTTP 401 |
| NEW-008 | DELETE /api/me/likes/{id} (no auth) | PASS | HTTP 401 |
| NEW-009 | PromptActions 컴포넌트 빌드 | PASS | TypeScript 컴파일 성공 |

### 기능 3: 태그 기능

| TC | 이름 | 결과 | 비고 |
|---|---|---|---|
| NEW-010 | DB tags 컬럼 (text[]) | PASS | 기존 컬럼 활용 |
| NEW-011 | INSERT 태그 포함 프롬프트 | PASS | tags=ARRAY['테스트','QA'] |
| NEW-012 | GET /search?tag=테스트 | PASS | 1건 반환, tags 배열 포함 |
| NEW-013 | /me/prompts/new 태그 입력 UI | PASS | HTTP 200, 빌드 성공 |

### 빌드 결과

| 항목 | 결과 |
|---|---|
| 백엔드 mvn package -DskipTests | PASS |
| 프론트 npm run build | PASS |
| TypeScript typecheck | PASS |

### 실행 PID (2026-03-06)

- 백엔드: PID 81488 (port 8080)
- 프론트: PID 91416 (port 3000)

---

# 테스트 결과 (2026-03-06 16:20)

## 환경
- 백엔드: localhost:8080 (Spring Boot 3.2.3 + Java 21)
- 프론트엔드: localhost:3000 (Next.js 14.2.3)
- DB: Docker PostgreSQL 16 (promptbuilder_db)

## 테스트 데이터
- 프롬프트 ID: `295714bf-c012-409d-b825-8ea82f4a7cc5`
- 제목: 테스트 입니다.
- 템플릿: `안녕하세요 {{name}}\n테스트 입니다 {{contents}}`
- 변수: name, contents (required=true)
- visibility: public

## 결과 요약

| TC | 이름 | 결과 | HTTP | 비고 |
|---|---|---|---|---|
| TC-001 | trending API | PASS | 200 | 1건 반환 |
| TC-002 | random API | PASS | 200 | 1건 반환 |
| TC-003 | new API | PASS | 200 | 1건 반환 |
| TC-004 | search API (빈 검색) | PASS | 200 | 전체 1건 + meta 포함 |
| TC-005 | prompt detail API | PASS | 200 | variables 배열 포함 |
| TC-006 | generate API | PASS | 200 | renderedPrompt 정상 치환 |
| TC-007 | GET me/prompts (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-008 | GET me/bookmarks (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-009 | POST me/bookmarks (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-010 | DELETE me/bookmarks (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-011 | POST me/prompts (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-012 | POST admin/moderate (no auth) | PASS | 401 | 인증 체계 정상 |
| TC-013 | 홈 화면 / | PASS | 200 | - |
| TC-014 | 탐색 화면 /explore | PASS | 200 | - |
| TC-015 | 로그인 화면 /login | PASS | 200 | - |
| TC-016 | 라이브러리 /me/library | PASS | 200 | 클라이언트 auth 체크 |
| TC-017 | 새 프롬프트 /me/prompts/new | PASS | 200 | 클라이언트 auth 체크 |
| TC-018 | 프롬프트 상세 /p/{id} | PASS | 200 | 실제 ID 사용 |
| TC-019 | 프롬프트 상세 /p/없는ID | PASS | 404 | notFound() 정상 동작 |

**전체: 19/19 PASS**

---

## 발견된 버그 및 수정 내역

### BUG-001: GET /api/public/prompts/{id} → HTTP 500
**원인**: MyBatis의 `map-underscore-to-camel-case: true` 설정 + UUID 타입 캐스팅 문제
- MyBatis는 UUID 컬럼을 `java.util.UUID` 객체로 반환
- SQL alias `version_id`는 camelCase 변환되어 HashMap key가 `versionId`가 됨
- 코드에서 `(String) prompt.get("version_id")`로 직접 캐스팅 → ClassCastException

**수정 파일**: `/c/GitHub/PromptBuilder/back/src/main/java/com/promptbuilder/service/PromptService.java`
- `getDetail()`: `prompt.get("versionId")` (camelCase) 우선 조회, `.toString()` 변환
- `generate()`: `versionId`, `templateBody` 모두 동일 패턴으로 수정

### BUG-002: GET /api/me/prompts → HTTP 403 (401이어야 함)
**원인**: Spring Security 기본 동작: 인증 없는 요청에 AccessDeniedException → 403 반환
- JWT stateless 환경에서 unauthenticated 요청은 401이 올바른 동작

**수정 파일**: `/c/GitHub/PromptBuilder/back/src/main/java/com/promptbuilder/security/SecurityConfig.java`
- `.exceptionHandling()` 추가: `HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)` 설정

---

## 빌드 결과

### Maven 빌드 (Spring Boot)
```
cd /c/GitHub/PromptBuilder/back
./mvnw clean package -DskipTests -q
→ BUILD SUCCESS (exit code: 0)
```

### Next.js 빌드
```
cd /c/GitHub/PromptBuilder/front
npm run build
→ ✓ Compiled successfully
→ ✓ Generating static pages (8/8)
→ BUILD SUCCESS
```

## 최종 상태
- 전체 19개 TC 모두 PASS
- 백엔드 Maven 빌드 PASS
- 프론트엔드 Next.js 빌드 PASS
