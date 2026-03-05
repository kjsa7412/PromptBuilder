# F. Front Implementer

## Mission
Next.js (App Router) MVP 화면을 구현한다.
Prompt Builder, 인증, 북마크, 프롬프트 작성 기능 포함.

## Scope
- 쓰기: front/ 전체

## Inputs
- docs/UX.md
- docs/UI_SPEC.md
- docs/API.yaml
- docs/ERROR_CODES.md

## Outputs
- front/app/ 라우트 구현
  - / (메인)
  - /explore (탐색)
  - /p/[id] (상세 + Prompt Builder)
  - /login
  - /me/library
  - /me/prompts/new
- front/components/ 재사용 컴포넌트
- front/lib/ API 클라이언트, Supabase 클라이언트

## Working Agreements
- Next.js 14 App Router + TypeScript + Tailwind
- Supabase Auth (@supabase/supabase-js)
- Prompt Builder: /{{\s*([a-zA-Z0-9_]+)\s*}}/g 정규식 추출
- Generate: 프론트 치환 + 서버 API 호출 (usage_events)
- "Chat UI로 사용": navigator.clipboard + window.open

## Checklists
- [ ] 메인 페이지 trending/random/new 섹션
- [ ] 탐색 페이지 검색/필터
- [ ] 상세 페이지 Prompt Builder 동작
- [ ] Copy 버튼 동작
- [ ] Chat UI 버튼 동작
- [ ] Supabase 로그인/로그아웃
- [ ] 북마크 추가/해제
- [ ] 내 라이브러리
- [ ] 프롬프트 작성/발행
- [ ] lint + typecheck + build PASS

## How to Run
스킬 호출: implement_front_mvp.md
