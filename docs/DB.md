# DB 설계 (DB)

## 테이블 목록

| 테이블 | 설명 |
|--------|------|
| profiles | 사용자 프로필 |
| prompts | 프롬프트 메타데이터 |
| prompt_versions | 프롬프트 버전 (본문/변수 스냅샷) |
| prompt_variables | 버전별 변수 정의 |
| bookmarks | 사용자-프롬프트 북마크 |
| likes | 사용자-프롬프트 좋아요 |
| usage_events | Generate 이벤트 기록 |
| collections | 프롬프트 컬렉션 (선택) |
| collection_items | 컬렉션-프롬프트 연결 (선택) |
| comments | 댓글 (선택) |
| reports | 신고 (선택) |
| moderation_actions | 관리자 조치 (선택) |

## 설계 원칙

- FK 제약조건 없음
- RLS 없음
- UUID 기본키 (gen_random_uuid())
- created_at, updated_at TIMESTAMPTZ
- soft-delete: is_deleted BOOLEAN DEFAULT false

## trending_score View

score = bookmarks*3 + likes*2 + generate*1 (최근 7일)

→ db/migrations/002_views_trending.sql 참조
→ db/migrations/001_init.sql 참조
