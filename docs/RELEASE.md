# 릴리즈 가이드 (RELEASE)

## 릴리즈 프로세스

1. feature 브랜치 → PR 생성
2. 코드 리뷰 + 승인
3. scripts/gate.sh PASS 확인
4. main 브랜치 머지
5. ALLOW_PROD=1 설정 후 배포

## 버전 관리

- Semantic Versioning (MAJOR.MINOR.PATCH)
- MAJOR: 호환성 깨는 변경
- MINOR: 기능 추가
- PATCH: 버그 수정

## 릴리즈 체크리스트

- [ ] gate.sh PASS
- [ ] docs 업데이트
- [ ] .env.example 업데이트 (새 환경변수)
- [ ] DB migration 검증
