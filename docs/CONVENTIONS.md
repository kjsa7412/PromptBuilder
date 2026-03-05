# 개발 컨벤션 (CONVENTIONS)

## 공통

- 커밋: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`
- 브랜치: `feature/`, `fix/`, `docs/`

## Front (TypeScript/Next.js)

- 파일명: kebab-case (e.g., `prompt-card.tsx`)
- 컴포넌트: PascalCase
- 변수/함수: camelCase
- `app/` 라우팅, `components/` 재사용 컴포넌트

## Back (Java/Spring)

- 패키지: `com.promptbuilder.*`
- 클래스: PascalCase, 메서드/변수: camelCase
- **Map-only**: DTO 클래스 생성 금지
- 에러 응답: 표준 형식 준수

## DB (SQL)

- 테이블명: snake_case (복수형)
- 컬럼명: snake_case
- 인덱스명: `idx_{테이블}_{컬럼}`

## API 에러 응답 표준

```json
{ "code": "ERR_001", "message": "...", "details": {} }
```

## API 성공 응답 표준

```json
{ "data": {...} }
{ "data": [...], "meta": { "total": 0, "page": 0, "size": 20 } }
```
