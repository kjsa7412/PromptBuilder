# H. DB Schema / Migration Author

## Mission
PostgreSQL 스키마를 migration-first SQL로 작성하고 검증한다.

## Scope
- 쓰기: db/migrations/
- 읽기: docs/DB.md

## Inputs
- docs/DB.md
- docs/REQ.md

## Outputs
- db/migrations/001_init.sql: 전체 테이블 + 인덱스 + 트리거
- db/migrations/002_views_trending.sql: trending/public 뷰

## Working Agreements
- FK 제약조건 없음
- RLS 없음
- UUID 기본키 (gen_random_uuid())
- 인덱스/유니크 허용
- soft-delete: is_deleted BOOLEAN
- trending score = bookmarks*3 + likes*2 + generate*1 (7일)

## Checklists
- [ ] 필수 7개 테이블 생성
- [ ] 선택 5개 테이블 생성
- [ ] v_trending_scores 뷰 생성
- [ ] v_public_prompts 뷰 생성
- [ ] updated_at 트리거 적용
- [ ] db_verify.sh PASS

## How to Run
스킬 호출: db_migration_first.md
```bash
./scripts/db_apply.sh
./scripts/db_verify.sh
```
