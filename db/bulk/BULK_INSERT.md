# PromptClip 벌크 인서트 가이드

## 폴더 구조

```
db/bulk/
├── BULK_INSERT.md        ← 이 파일 (작업 가이드)
├── generate.js           ← SQL 생성 스크립트
├── templates/
│   └── example.json      ← 작업파일 예시 (복사해서 사용)
├── work/                 ← 처리할 작업파일 (JSON) 넣는 곳
├── sql/                  ← 생성된 SQL 파일 (실행 전 검토)
└── done/                 ← 처리 완료된 작업파일
```

---

## 전제 조건

- **Node.js** 18 이상 설치
- **ADMIN_USER_ID**: PromptClip 관리자 계정의 Supabase `auth.users.id` (UUID)
  - Supabase 대시보드 → Authentication → Users 에서 확인

---

## 작업 절차

### 1단계: 작업파일 작성

`templates/example.json`을 복사해서 `work/` 폴더에 넣고 내용을 작성합니다.

```bash
cp db/bulk/templates/example.json db/bulk/work/my-post.json
# 파일명은 영문/숫자/하이픈 권장 (예: marketing-prompts.json)
```

### 2단계: SQL 생성

```bash
# 관리자 UUID를 환경변수로 전달
ADMIN_USER_ID=<your-uuid> node db/bulk/generate.js
```

또는 `generate.js` 상단의 `ADMIN_USER_ID` 상수를 직접 수정:

```js
const ADMIN_USER_ID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
```

생성된 SQL 파일이 `sql/` 폴더에 저장되고, 작업파일은 `done/` 폴더로 이동합니다.

### 3단계: SQL 검토 및 실행

1. `sql/` 폴더의 `.sql` 파일을 열어 내용을 확인합니다.
2. [Supabase SQL Editor](https://supabase.com/dashboard/project/_/sql) 에 붙여넣고 실행합니다.
3. `RAISE NOTICE` 출력으로 성공 여부를 확인합니다.

### 4단계: 실행 완료 후 정리

SQL 파일은 자동으로 삭제되지 않습니다. 실행 후 `sql/` 폴더에서 수동으로 삭제하거나 보관하세요.

---

## 작업파일 형식 (JSON)

파일 하나에 게시물을 **여러 개** 배열로 담을 수 있습니다.

```json
[
  {
    "title": "첫 번째 게시물 제목",
    "description": "게시물 설명 (선택)",
    "tags": ["태그1", "태그2"],
    "visibility": "public",
    "body_markdown": "## 소개\n\n내용...\n\n[[PROMPT:0]]",
    "post_prompts": [
      {
        "title": "프롬프트 제목",
        "template_body": "{{role}}로서 {{topic}}에 대해 작성해주세요.",
        "status": "complete",
        "sort_order": 0,
        "variables": [
          {
            "key": "role",
            "label": "역할",
            "description": "입력 힌트 (선택)",
            "type": "text",
            "sort_order": 0
          }
        ]
      }
    ]
  },
  {
    "title": "두 번째 게시물 제목",
    "post_prompts": [...]
  }
]
```

단일 게시물도 배열 없이 객체 하나로 작성할 수 있습니다 (하위 호환).

```json
{
  "title": "게시물 제목",
  "post_prompts": [...]
}
```
```

### 필드 설명

| 필드 | 필수 | 설명 |
|------|------|------|
| `title` | ✅ | 게시물 제목 |
| `description` | - | 게시물 설명 |
| `tags` | - | 태그 배열 |
| `visibility` | - | `public` / `private` / `draft` (기본: `public`) |
| `body_markdown` | - | 게시물 본문 마크다운. `[[PROMPT:N]]` 마커로 프롬프트 위치 지정 |
| `post_prompts` | ✅ | 프롬프트 블록 배열 (1개 이상 필수) |

### post_prompts 필드

| 필드 | 필수 | 설명 |
|------|------|------|
| `title` | ✅ | 프롬프트 블록 제목 |
| `template_body` | ✅ | 프롬프트 템플릿. 변수는 `{{key}}` 형식으로 |
| `status` | - | `complete` / `in_progress` / `draft` (기본: `complete`) |
| `sort_order` | - | 정렬 순서 (기본: 배열 인덱스) |
| `variables` | - | 변수 정의 배열 |

### variables 필드

| 필드 | 필수 | 설명 |
|------|------|------|
| `key` | ✅ | 변수 키 (`{{key}}` 와 일치해야 함) |
| `label` | - | 사용자에게 표시될 라벨 |
| `description` | - | 입력 힌트 텍스트 |
| `type` | - | `text` / `textarea` / `select` (기본: `text`) |
| `options` | - | `type: "select"` 일 때 선택지 배열 |
| `sort_order` | - | 정렬 순서 (기본: 배열 인덱스) |

### body_markdown 마커

`[[PROMPT:N]]` 마커를 사용하면 해당 위치에 N번째 프롬프트 블록이 삽입됩니다 (0-indexed).

```
## 소개
소개 내용...

[[PROMPT:0]]   ← 첫 번째 프롬프트 위치

## 추가 설명
추가 내용...

[[PROMPT:1]]   ← 두 번째 프롬프트 위치
```

마커가 없으면 텍스트 본문 아래에 `sort_order` 순으로 모든 프롬프트가 표시됩니다.

---

## 주의사항

- `work/` 폴더의 파일은 SQL 생성 후 `done/`으로 **자동 이동**됩니다.
- 동일한 파일명이 `done/`에 이미 있으면 덮어씁니다.
- SQL 실행은 **트랜잭션** (`DO $$ BEGIN ... END $$`) 으로 감싸져 있어, 오류 발생 시 롤백됩니다.
- SQL 파일을 실행하기 전에 반드시 내용을 검토하세요.
- `generate.js`가 실패해도 `work/` 파일은 그대로 남아있습니다.
