# 정책 명세 (POLICY)

## 보안 정책

### PL-SEC-001: 인증 단일원칙
- 모든 JWT는 Supabase Auth에서 발급
- Spring Boot는 JWKS URL로 서명 검증만 수행
- 자체 JWT 발급 없음

### PL-SEC-002: 권한 분리
- user: 기본 역할 (로그인 사용자)
- admin: JWT 클레임 `role=admin` 또는 별도 설정
- 권한 검사는 Spring Security / Filter에서 수행

### PL-SEC-003: 데이터 접근
- RLS 미사용
- /me/* API는 JWT의 sub(userId)와 데이터의 user_id 일치 여부를 애플리케이션에서 강제

## DB 정책

### PL-DB-001: FK 미사용
- 테이블 간 FK 제약조건 없음
- user_id, prompt_id 등은 UUID 타입 컬럼으로 저장
- 참조 무결성은 애플리케이션 레이어에서 관리

### PL-DB-002: 인덱스
- 조회 성능을 위한 인덱스/유니크 제약은 허용
- 예: bookmarks(user_id, prompt_id) UNIQUE

### PL-DB-003: soft-delete
- MVP에서는 is_deleted 플래그 방식 사용
- soft-FK 검사 미수행

## 운영 정책

### PL-OPS-001: 배포 게이트
- ALLOW_PROD=0 (기본): 프로덕션 배포 커맨드 차단
- ALLOW_PROD=1: PR 승인 후에만 설정 허용

### PL-OPS-002: 개발 흐름
1. 로컬 구현
2. scripts/gate.sh PASS
3. GitHub PR 생성
4. 코드 리뷰/승인
5. 배포 (ALLOW_PROD=1)

## 어뷰징 방지

### PL-ABUSE-001: Generate 제한
- 동일 사용자: 하루 GENERATE_DAILY_LIMIT_PER_USER회 제한 (기본 50)
- 비로그인: IP 기반 레이트리밋 (기본 20회/시간)

### PL-ABUSE-002: 신고 처리
- 신고 누적 시 관리자 검토 대상으로 플래그
- 관리자가 hide/ban 처리
