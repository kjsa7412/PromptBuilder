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

---

## v0.5.0 — 2026-03-08: UI/UX 전면 리디자인

### 주요 변경사항

**프론트엔드**
- 홈 히어로: dot-grid 배경 + noise 텍스처, 임베디드 검색바, 인기 검색 chips
- `HomeSections` 컴포넌트: 3개 독립 섹션(trending/new/random) 각각 무한 스크롤
- `PromptCard`: 카테고리 색상 border-l-4, 변수 카운트 `{{N}}` 배지, 템플릿 미리보기
- `Header`: 카테고리 nav pills (탐색/업무/일상/창작), 아바타 드롭다운 메뉴
- `MobileBottomNav`: 모바일 하단 탭바 (홈/탐색/라이브러리/프로필)
- `explore/page.tsx`: FilterSidebar (데스크탑 좌측 고정), 모바일 필터 패널, 활성 필터 chips, 무한 스크롤
- `globals.css`: 카테고리 색상 CSS 변수, `.dot-grid`, `.noise-bg`, `.skeleton`, `.glass-card`, `.gradient-text`, `.input-base`

**백엔드**
- trending/new/random/search 쿼리에 `variable_count`, `first_template_body` subquery 추가
- trending/new API에 `offset` 파라미터 추가 (무한 스크롤 지원)
