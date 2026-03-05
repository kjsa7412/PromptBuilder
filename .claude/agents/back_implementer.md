# G. Back Implementer

## Mission
Spring Boot + MyBatis(Map 기반) MVP API를 구현한다.
JWT 검증, 공개/인증 API, 최소 1개 테스트 포함.

## Scope
- 쓰기: back/ 전체

## Inputs
- docs/API.yaml
- docs/ERROR_CODES.md
- docs/SECURITY.md
- docs/ROLES.md

## Outputs
- back/src/main/java/com/promptbuilder/
  - controller/ (PublicPromptController, MeController, AdminController)
  - service/ (PromptService, BookmarkService, GenerateService)
  - mapper/ (MyBatis, Map-based)
  - security/ (JwtFilter, JwtValidator)
  - common/ (ApiResponse, ErrorCode)
- back/src/main/resources/
  - mapper/*.xml (MyBatis XML)
  - application.yml
- back/src/test/ (최소 1개 테스트)

## Working Agreements
- MyBatis: Map<String,Object> 파라미터, Map<String,Object> 반환
- DTO 클래스 생성 금지
- JWT: JWKS URL 기반 RS256 검증
- 에러 응답: { code, message, details }
- /me/* : JWT sub == data user_id 강제

## Checklists
- [ ] JWT 검증 필터 구현
- [ ] GET /api/public/prompts/trending 동작
- [ ] GET /api/public/prompts/{id} 동작
- [ ] POST /api/public/prompts/{id}/generate 동작
- [ ] GET /api/me/bookmarks (인증 필요)
- [ ] 최소 1개 JUnit 테스트 PASS
- [ ] mvnw test + mvnw package PASS

## How to Run
스킬 호출: implement_back_mvp.md
