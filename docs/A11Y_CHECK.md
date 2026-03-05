# 접근성 체크리스트 (A11Y_CHECK)

## WCAG 2.1 AA 기준

### 지각 가능 (Perceivable)
- [ ] 이미지에 alt 텍스트 제공
- [ ] 색상만으로 정보 전달하지 않음
- [ ] 텍스트 대비율 4.5:1 이상 (일반 텍스트)

### 운용 가능 (Operable)
- [ ] 모든 기능 키보드로 접근 가능
- [ ] 포커스 표시기 명확
- [ ] Prompt Builder 폼 Tab 순서 논리적

### 이해 가능 (Understandable)
- [ ] 에러 메시지 명확 (어떤 필드, 왜 에러)
- [ ] 언어 속성 설정 (`lang="ko"`)

### 견고 (Robust)
- [ ] 시맨틱 HTML 사용 (button, label, input)
- [ ] aria-label, aria-describedby 적절히 사용

## MVP 최소 요구사항
- 폼 요소에 label 연결 필수
- 에러 메시지 role="alert"
- 버튼에 의미 있는 텍스트 (아이콘만 사용 시 aria-label)
