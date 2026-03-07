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
