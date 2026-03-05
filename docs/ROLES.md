# 역할 정의 (ROLES)

## 사용자 역할

| 역할 | 설명 | 권한 |
|------|------|------|
| anonymous | 비로그인 사용자 | 공개 프롬프트 열람, Generate(레이트리밋) |
| user | 로그인 사용자 | anonymous + 북마크, 좋아요, 내 프롬프트 작성/발행 |
| admin | 관리자 | user + 신고/차단/비공개 처리 |

## API 접근 권한

| 엔드포인트 | anonymous | user | admin |
|-----------|-----------|------|-------|
| GET /api/public/* | O | O | O |
| POST /api/public/*/generate | O (레이트리밋) | O | O |
| GET/POST/DELETE /api/me/* | X | O (본인만) | O |
| POST /api/admin/* | X | X | O |

## JWT 클레임 구조 (Supabase)

```json
{
  "sub": "uuid",
  "email": "user@example.com",
  "role": "authenticated",
  "app_metadata": {
    "role": "admin"
  },
  "exp": 1234567890
}
```

## 역할 판정 로직 (Spring)

1. JWT의 `app_metadata.role == "admin"` → ADMIN
2. JWT의 `role == "authenticated"` → USER
3. 그 외 → ANONYMOUS
