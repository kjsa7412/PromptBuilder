# Skill: design_openapi_contract

## 목적
docs/API.yaml (OpenAPI 3.0) + docs/ERROR_CODES.md를 작성한다.

## 필수 엔드포인트

### Public
- GET /api/public/prompts/trending
- GET /api/public/prompts/random
- GET /api/public/prompts/new
- GET /api/public/prompts/search
- GET /api/public/prompts/{promptId}
- POST /api/public/prompts/{promptId}/generate

### Auth (User)
- GET/POST/DELETE /api/me/bookmarks/{promptId}
- POST /api/me/prompts
- PUT /api/me/prompts/{promptId}
- POST /api/me/prompts/{promptId}/versions
- PUT /api/me/prompts/{promptId}/versions/{verId}
- POST /api/me/prompts/{promptId}/publish
- POST/DELETE /api/me/likes/{promptId}

### Admin
- POST /api/admin/prompts/{promptId}/moderate

## 에러 응답 형식
```json
{ "code": "AUTH_001", "message": "...", "details": {} }
```

## 성공 응답 형식
```json
{ "data": {...} }
{ "data": [...], "meta": { "total": 0, "page": 0, "size": 20 } }
```
