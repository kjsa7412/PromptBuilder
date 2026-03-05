# 인수 기준 (Acceptance Criteria)

## AC-001: 메인 페이지 탐색
- [ ] 주간 인기 프롬프트 카드 최소 1개 표시
- [ ] 랜덤 프롬프트 섹션 표시
- [ ] 신규 프롬프트 섹션 표시
- [ ] 태그 필터 동작

## AC-002: 상세 페이지 + Prompt Builder
- [ ] 템플릿의 `{{var}}` 추출하여 폼 자동 렌더링
- [ ] 필수 미입력 시 Generate 버튼 비활성
- [ ] Generate 클릭 시 완성 프롬프트 표시
- [ ] Copy 버튼 동작
- [ ] "Chat UI로 사용" 버튼: 클립보드 복사 + 새 탭 오픈

## AC-003: 인증
- [ ] Supabase Auth 로그인/로그아웃 동작
- [ ] JWT 토큰 Spring 백엔드 검증 통과

## AC-004: 북마크
- [ ] 로그인 상태에서 북마크 추가/해제
- [ ] /me/library 에서 북마크 목록 조회

## AC-005: 프롬프트 작성
- [ ] /me/prompts/new 에서 초안 생성
- [ ] 변수 정의 UI
- [ ] 미리보기 동작
- [ ] 발행(public 전환) 동작

## AC-006: DB 마이그레이션
- [ ] db_apply.sh 실행 후 모든 테이블 존재
- [ ] db_verify.sh PASS

## AC-007: 게이트
- [ ] scripts/gate.sh 전체 PASS
  - front: lint + typecheck + build
  - back: test(최소 1개) + build
  - db: db_verify
  - 보안: secret_scan + pii_scan
