# 아키텍처 (ARCH)

## 시스템 아키텍처

```
Client (Browser) — Next.js (App Router, Vercel)
        |
        | HTTP/REST
        v
Spring Boot API (Railway)
  MyBatis (Map-based) + JWT Filter
        |                    |
        v                    v
PostgreSQL DB         Supabase Auth
 (Supabase)          (JWT 발급/JWKS)
```

## 인증 흐름

1. 사용자 → Supabase Auth 로그인
2. Supabase → JWT 발급
3. 클라이언트 → API 요청 (Authorization: Bearer JWT)
4. Spring Filter → JWKS URL에서 공개키로 검증
5. 검증 통과 → SecurityContext에 userId, role 저장
6. Controller → 비즈니스 로직 처리

## 레이어 구조 (Back)

```
Controller (Map 기반 Request/Response)
    ↓
Service (비즈니스 로직, Map)
    ↓
Mapper (MyBatis, Map-based SQL)
    ↓
PostgreSQL
```

## 기술 결정

| 결정 | 이유 |
|------|------|
| MyBatis Map-based | DTO 클래스 없이 유연한 쿼리 매핑, 빠른 개발 |
| FK 없음 | 유연한 스키마 진화, MVP 속도 |
| RLS 없음 | 단순성, 앱 레이어에서 권한 강제 |
| Supabase Auth | 자체 인증 구현 비용 절감 |

## 배포 구조

| 컴포넌트 | 플랫폼 |
|---------|--------|
| Front | Vercel |
| Back | Railway |
| DB | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
