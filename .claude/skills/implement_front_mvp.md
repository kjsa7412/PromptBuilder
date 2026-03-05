# Skill: implement_front_mvp

## 목적
Next.js MVP 화면/빌더를 구현한다.

## 필수 페이지

| 경로 | 기능 |
|------|------|
| / | 메인 (trending/random/new/tag) |
| /explore | 탐색 (검색/필터) |
| /p/[id] | 상세 + Prompt Builder |
| /login | Supabase Auth |
| /me/library | 내 북마크 |
| /me/prompts/new | 프롬프트 작성 |

## Prompt Builder 핵심 로직

```typescript
// 변수 추출
const PLACEHOLDER_RE = /\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g;
function extractVars(template: string): string[] {
  return [...new Set([...template.matchAll(PLACEHOLDER_RE)].map(m => m[1]))];
}

// 치환
function renderPrompt(template: string, values: Record<string, string>): string {
  return template.replace(PLACEHOLDER_RE, (_, key) => values[key] ?? '');
}
```

## Generate 흐름
1. 프론트에서 renderedPrompt 생성
2. POST /api/public/prompts/{id}/generate 호출 (usage_events 기록)
3. 서버 missingRequired 2중 체크
4. 완성 프롬프트 표시

## "Chat UI로 사용" 버튼
```typescript
await navigator.clipboard.writeText(renderedPrompt);
window.open(process.env.NEXT_PUBLIC_CHAT_UI_URL, '_blank');
// 토스트: "복사됨. Ctrl+V 후 Enter"
```
