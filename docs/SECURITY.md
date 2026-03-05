# 보안 명세 (SECURITY)

## 인증/인가

### JWT 검증
- 알고리즘: RS256 (Supabase 기본)
- 검증 항목: 서명, issuer, audience, exp
- JWKS 캐싱: 1시간
- 검증 실패: HTTP 401 + AUTH_001

### 권한 강제
- /me/* API: JWT sub == 데이터 user_id 검사
- /admin/* API: role == admin 검사
- Spring Security FilterChain으로 엔드포인트별 접근 제어

## 입력 검증

### SQL Injection
- MyBatis #{} 파라미터 바인딩 사용 (PreparedStatement)
- ${} 사용 금지

### XSS
- 프론트: React 기본 이스케이프
- 마크다운 렌더링: sanitize 적용

### Rate Limiting
- /api/public/*/generate: IP 기반 20회/시간
- /api/me/*/generate: userId 기반 50회/일

## 비밀 관리

- 코드에 API 키, 비밀번호 하드코딩 금지
- .env 파일 git 커밋 금지 (.gitignore)
- JWKS URL/Issuer/Audience는 환경변수로 주입

## CORS

- 허용 오리진: 환경변수로 지정
- 개발: http://localhost:3000
- 프로덕션: Vercel 도메인
