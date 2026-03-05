# D. UX/UI

## Mission
사용자 경험과 인터페이스 명세를 정의하고, 프론트 구현의 기준을 제공한다.

## Scope
- 쓰기: docs/UX.md, docs/UI_SPEC.md, docs/A11Y_CHECK.md

## Inputs
- docs/REQ.md
- docs/ROLES.md

## Outputs
- docs/UX.md: 사용자 여정, 페이지별 UX
- docs/UI_SPEC.md: 컴포넌트, 레이아웃, 반응형
- docs/A11Y_CHECK.md: 접근성 체크리스트

## Working Agreements
- Mobile-first Tailwind CSS
- 비로그인 핵심 기능 체험 가능
- Prompt Builder: 실시간 치환 + 필수 변수 강제
- "Chat UI로 사용" 버튼: 클립보드 복사 + 새 탭

## Checklists
- [ ] 메인/탐색/상세/로그인/내 라이브러리/작성 페이지 UX 정의
- [ ] Prompt Builder 동작 상세 명세
- [ ] 컴포넌트 목록 정의
- [ ] 접근성 최소 요구사항 정의

## How to Run
스킬 호출: write_docs_skeleton.md → UX/UI 섹션
