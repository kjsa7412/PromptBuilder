# UI 스펙 (UI_SPEC)

## 디자인 시스템

- **프레임워크**: Tailwind CSS
- **컬러 팔레트**:
  - Primary: `#6366f1` (인디고)
  - Secondary: `#8b5cf6` (보라)
  - Neutral: gray 계열
  - Success: `#10b981`
  - Error: `#ef4444`

## 컴포넌트 목록

### PromptCard
- 제목, 설명 excerpt, 태그 배지, 북마크 카운트, 좋아요 카운트
- 클릭 시 /p/[id] 이동

### PromptBuilder
- 변수 목록 자동 렌더링
- 각 변수: label, input(text/select/textarea), helpText
- 미리보기 패널 (실시간 업데이트)
- Generate 버튼 (필수 미입력 시 disabled)

### TagBadge
- 태그명, 클릭 시 /explore?tag= 이동

### CopyButton
- 클릭 시 클립보드 복사 + 토스트 표시

## 레이아웃

### 헤더
- 로고 (PromptClip)
- 탐색 메뉴: 홈, 탐색, 내 라이브러리 (로그인 시)
- 로그인/로그아웃 버튼

### 푸터
- 간단한 저작권 정보

## 반응형

- Mobile-first
- 브레이크포인트: sm(640), md(768), lg(1024), xl(1280)
- 카드 그리드: 1col(모바일) / 2col(태블릿) / 3col(데스크톱)
