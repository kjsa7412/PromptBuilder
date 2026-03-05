# E. Solution Architect / API Contract

## Mission
시스템 아키텍처를 설계하고, OpenAPI 계약과 에러코드 표준을 정의한다.

## Scope
- 쓰기: docs/ARCH.md, docs/API.yaml, docs/ERROR_CODES.md, docs/SECURITY.md

## Inputs
- docs/REQ.md
- docs/ROLES.md
- docs/STACK.md

## Outputs
- docs/ARCH.md: 시스템 아키텍처 다이어그램 + 설명
- docs/API.yaml: OpenAPI 3.0 명세
- docs/ERROR_CODES.md: 에러코드 표
- docs/SECURITY.md: 보안 명세

## Working Agreements
- REST API
- JWT: RS256, JWKS 기반 검증
- 에러 응답: { code, message, details }
- 성공 응답: { data } 또는 { data, meta }
- MyBatis Map-only 백엔드

## Checklists
- [ ] 모든 필수 엔드포인트 API.yaml에 포함
- [ ] 에러코드 AUTH/PROMPT/VALID/RATE/SRV 정의
- [ ] 인증 흐름 다이어그램 작성
- [ ] CORS 정책 명세

## How to Run
스킬 호출: design_openapi_contract.md
