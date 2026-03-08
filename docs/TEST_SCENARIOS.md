# PromptBuilder 전체 테스트 시나리오

## TC-001: Trending API
- **대상**: GET /api/public/prompts/trending?limit=5
- **조건**: 인증 없음
- **기대결과**: HTTP 200, data 배열 반환 (빈 배열도 허용)
- **방법**: curl

## TC-002: Random API
- **대상**: GET /api/public/prompts/random?limit=5
- **조건**: 인증 없음
- **기대결과**: HTTP 200, data 배열 반환
- **방법**: curl

## TC-003: New API
- **대상**: GET /api/public/prompts/new?limit=5
- **조건**: 인증 없음
- **기대결과**: HTTP 200, data 배열 반환
- **방법**: curl

## TC-004: Search API
- **대상**: GET /api/public/prompts/search?q=&tag=&page=0&size=10
- **조건**: 인증 없음, 빈 검색어
- **기대결과**: HTTP 200, data 배열 + meta(total/page/size) 반환
- **방법**: curl

## TC-005: Prompt Detail API
- **대상**: GET /api/public/prompts/{promptId}
- **조건**: 인증 없음, 실제 존재하는 promptId 사용
- **기대결과**: HTTP 200, data 객체 반환 (title, template_body, variables 포함)
- **방법**: curl

## TC-006: Generate API
- **대상**: POST /api/public/prompts/{promptId}/generate
- **조건**: 인증 없음, body: {"values":{"name":"test","contents":"content"}}
- **기대결과**: HTTP 200, renderedPrompt 반환 (변수 치환된 템플릿)
- **방법**: curl

## TC-007: Me Prompts - No Auth (보안 검증)
- **대상**: GET /api/me/prompts
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-008: Me Clips - No Auth (보안 검증)
- **대상**: GET /api/me/clips
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-009: Add Clip - No Auth (보안 검증)
- **대상**: POST /api/me/clips/{promptId}
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-010: Remove Clip - No Auth (보안 검증)
- **대상**: DELETE /api/me/clips/{promptId}
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-011: Create Prompt - No Auth (보안 검증)
- **대상**: POST /api/me/prompts
- **조건**: Authorization 헤더 없음, body: {"title":"test"}
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-012: Admin Moderate - No Auth (보안 검증)
- **대상**: POST /api/admin/prompts/{promptId}/moderate
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-013: 홈 화면
- **대상**: GET http://localhost:3000/
- **조건**: 없음
- **기대결과**: HTTP 200
- **방법**: curl

## TC-014: 탐색 화면
- **대상**: GET http://localhost:3000/explore
- **조건**: 없음
- **기대결과**: HTTP 200
- **방법**: curl

## TC-015: 로그인 화면
- **대상**: GET http://localhost:3000/login
- **조건**: 없음
- **기대결과**: HTTP 200
- **방법**: curl

## TC-016: 라이브러리 화면
- **대상**: GET http://localhost:3000/me/library
- **조건**: 없음 (클라이언트 사이드에서 auth 체크)
- **기대결과**: HTTP 200 (페이지 렌더링 성공)
- **방법**: curl

## TC-017: 새 프롬프트 작성 화면
- **대상**: GET http://localhost:3000/me/prompts/new
- **조건**: 없음 (클라이언트 사이드에서 auth 체크)
- **기대결과**: HTTP 200
- **방법**: curl

## TC-018: 프롬프트 상세 화면
- **대상**: GET http://localhost:3000/p/{promptId}
- **조건**: 실제 존재하는 promptId 사용
- **기대결과**: HTTP 200
- **방법**: curl

## TC-019: 프롬프트 상세 화면 (존재하지 않는 ID)
- **대상**: GET http://localhost:3000/p/00000000-0000-0000-0000-000000000000
- **조건**: 존재하지 않는 promptId
- **기대결과**: HTTP 404
- **방법**: curl

---

## [신규] 데이터 정리 및 주요 기능 검증 시나리오

## TC-020: 데이터 정리 - 특정 게시물만 존재 확인
- **대상**: DB prompts 테이블
- **조건**: "회의록2 입니다." 이외 모든 게시물 삭제 후
- **기대결과**: prompts 테이블에 정확히 1건("회의록2 입니다.")만 존재
- **방법**: psql COUNT 쿼리

## TC-021: Stats API - 공개 게시물 수 정확성
- **대상**: GET /api/public/stats
- **조건**: "회의록2 입니다."만 public 상태
- **기대결과**: HTTP 200, data.totalPrompts = 1
- **방법**: curl

## TC-022: 메인 탭 - "회의록2 입니다." 이외 게시물 미노출
- **대상**: GET /api/public/prompts/trending, /random, /new
- **조건**: DB에 공개 게시물 1건만 존재
- **기대결과**: 각 탭에 "회의록2 입니다." 1건만 반환, 다른 게시물 없음
- **방법**: curl + title 필드 검증

## TC-023: Like API - No Auth (보안 검증)
- **대상**: POST /api/me/likes/{promptId}
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-024: Like Remove API - No Auth (보안 검증)
- **대상**: DELETE /api/me/likes/{promptId}
- **조건**: Authorization 헤더 없음
- **기대결과**: HTTP 401 Unauthorized
- **방법**: curl

## TC-025: 상세 화면 - 블록 순서 보존 (bodyMarkdown + postPrompts)
- **대상**: GET /api/public/prompts/{promptId}
- **조건**: body_markdown에 [[PROMPT:N]] 마커가 포함된 게시물
- **기대결과**: body_markdown 필드에 텍스트와 [[PROMPT:N]] 마커가 순서대로 포함됨
- **방법**: curl + body_markdown 필드 내 마커 패턴 검증

## TC-026: 상세 화면 - 변수 설명 정보 저장 검증
- **대상**: GET /api/me/prompts/{promptId}/post-prompts
- **조건**: post_prompt_variables 테이블에 description 저장 후
- **기대결과**: variables 배열 내 각 항목에 description 필드 반환
- **방법**: psql 직접 조회 + API 응답 검증

## TC-027: 상세 화면 페이지 렌더링 - camelCase 변환 검증
- **대상**: GET http://localhost:3000/p/{promptId}
- **조건**: API snake_case 응답을 프론트에서 camelCase로 변환
- **기대결과**: HTTP 200, 페이지에 templateBody/bodyMarkdown/likeCount 등 올바르게 렌더링
- **방법**: curl HTTP 상태코드 검증 (렌더링 오류 시 500 반환)

---

## [2026-03-08] 패치: 한글변수 / 임시저장 / visibility / slash UX

### TC-P04-01: 한글 변수 포함 프롬프트 블록 생성
- 전제조건: 인증된 유저, 프롬프트 존재
- 입력: POST /api/me/prompts/{id}/post-prompts body={templateBody: "{{역할}}로서 {{주제}}를 설명해"}
- 기대 결과: 200, variables 배열에 key="역할", key="주제" 포함
- 실패 기준: variables 빈 배열이면 FAIL

### TC-P04-02: 제목 없는 임시저장 (draft)
- 전제조건: 인증된 유저
- 입력: POST /api/me/prompts body={visibility:"draft", title:"임시저장 테스트 날짜"}
- 기대 결과: 201, data.id 존재
- 실패 기준: 400/500이면 FAIL

### TC-P04-03: 한글 변수 조회 확인
- 전제조건: TC-P04-01 성공 후
- 입력: GET /api/me/prompts/{id}/post-prompts
- 기대 결과: variables 배열에 한글 key 포함 (역할, 주제)
- 실패 기준: variables 빈 배열이면 FAIL
