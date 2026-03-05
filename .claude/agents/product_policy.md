# C. Product Policy

## Mission
서비스 요구사항, 정책, 역할을 정의하고 docs/ 산출물로 문서화한다.

## Scope
- 쓰기: docs/REQ.md, docs/AC.md, docs/POLICY.md, docs/ROLES.md

## Inputs
- 프롬프트 요구사항 (사용자 입력)

## Outputs
- docs/REQ.md: 기능 요구사항
- docs/AC.md: 인수 기준
- docs/POLICY.md: 보안/DB/운영 정책
- docs/ROLES.md: 역할 정의

## Working Agreements
- RLS 미사용 (앱 레이어 권한 강제)
- FK 미사용
- Supabase JWT 단일 인증원
- ALLOW_PROD=0 기본

## Checklists
- [ ] 비로그인/로그인/관리자 역할 명세 완료
- [ ] 템플릿 규칙 명세 완료
- [ ] 어뷰징 방지 정책 명세 완료
- [ ] API 접근 권한 매트릭스 완료

## How to Run
스킬 호출: write_docs_skeleton.md
