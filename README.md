# PromptBuilder (PromptClip)

> 프롬프트를 템플릿(설명+변수폼+완성 프롬프트) 형태로 저장·공유하고,
> 사용자는 변수만 채우면 즉시 복사/전송 가능한 완성 프롬프트를 얻는 서비스.

## 모노레포 구조 (A안)

```
repo-root/
├── front/          # Next.js 14 (App Router) + TypeScript + Tailwind
├── back/           # Spring Boot 3 + MyBatis(Map 기반) + JWT
├── tests/          # 통합/E2E 테스트
├── scripts/        # gate, db_apply, db_verify, secret_scan, pii_scan
├── docs/           # 표준 산출물 문서 (20개)
├── db/
│   └── migrations/ # Migration-first SQL (001_init, 002_views)
├── generated/      # 자동 생성 산출물
├── .claude/        # Claude Code 에이전트 A-J, 스킬, 훅
└── .github/        # CI 워크플로우
```

## 빠른 시작

### 1. 환경 설정

```bash
cp .env.example .env
# .env 파일을 열어 Supabase/DB 값 입력
```

### 2. 로컬 DB 실행 (Docker)

```bash
docker-compose up -d
```

### 3. DB 마이그레이션 적용

```bash
chmod +x scripts/*.sh
./scripts/db_apply.sh
./scripts/db_verify.sh
```

### 4. 백엔드 실행

```bash
cd back
./mvnw spring-boot:run
# http://localhost:8080
```

### 5. 프론트엔드 실행

```bash
cd front
npm install
npm run dev
# http://localhost:3000
```

### 6. 로컬 게이트 실행 (CI 체크)

```bash
./scripts/gate.sh
```

## 스택

| 영역 | 기술 |
|------|------|
| Front | Next.js 14 (App Router) + TypeScript + Tailwind CSS |
| Back | Spring Boot 3 + MyBatis (Map-only) + JWT |
| DB | PostgreSQL 16 |
| Auth | Supabase Auth (JWT 발급, Spring에서 JWKS 검증) |
| 배포 | Vercel (front) / Railway (back) / Supabase (Auth+DB) |

## 핵심 기능

- **비로그인**: 주간 인기/랜덤/신규/태그 탐색, Prompt Builder 사용
- **Prompt Builder**: `{{변수}}` 자동 폼 생성, 실시간 미리보기, Generate, Copy
- **Chat UI로 사용**: 클립보드 복사 + 새 탭 Chat UI 오픈
- **로그인**: 북마크, 내 라이브러리, 프롬프트 작성/발행

## Prompt Builder

```
템플릿: "안녕하세요, {{name}}님! {{role}} 역할로 도움드리겠습니다."

변수 폼:
  name: [Alice          ]
  role: [개발자          ]

완성 프롬프트:
  "안녕하세요, Alice님! 개발자 역할로 도움드리겠습니다."
```

## 개발 흐름

1. 로컬 구현 → `./scripts/gate.sh` PASS
2. GitHub PR 생성
3. 코드 리뷰/승인
4. 배포 (`ALLOW_PROD=1` 설정 후)

> **Guardrails**: `ALLOW_PROD=0`(기본)일 때 vercel --prod, railway up 등 자동 차단

## 에이전트 팀 (.claude/agents/)

| 에이전트 | 역할 |
|---------|------|
| A. delivery_orchestrator | 전체 흐름 조율 |
| B. foundation_builder | 모노레포 뼈대/환경 |
| C. product_policy | 요구사항/정책/롤 |
| D. ux_ui | UX/UI 명세 |
| E. solution_architect_api_contract | API 계약/아키텍처 |
| F. front_implementer | Next.js 구현 |
| G. back_implementer | Spring Boot 구현 |
| H. db_schema_migration_author | DB 스키마/마이그레이션 |
| I. qa_gatekeeper | QA/게이트 |
| J. release_deployment | 릴리즈/배포 |

## 환경변수

| 키 | 설명 |
|----|------|
| `DB_*` | PostgreSQL 연결 |
| `SUPABASE_*` | Supabase Auth/DB |
| `NEXT_PUBLIC_*` | 프론트 공개 변수 |
| `JWT_*` | Spring JWT 검증 |
| `ALLOW_PROD` | `0`=배포차단, `1`=허용 |

`.env.example` 참조
