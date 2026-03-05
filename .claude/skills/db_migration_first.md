# Skill: db_migration_first

## 목적
db/migrations/ 초기 스키마/뷰/인덱스를 migration-first SQL로 작성한다.

## 파일 구조
- db/migrations/001_init.sql: 테이블 + 인덱스 + 트리거
- db/migrations/002_views_trending.sql: 뷰

## 규칙
- FK 제약조건 없음
- RLS 없음
- UUID 기본키: gen_random_uuid()
- soft-delete: is_deleted BOOLEAN DEFAULT false
- trending score: bookmarks*3 + likes*2 + generate*1 (7일)

## 적용 순서
```bash
./scripts/db_apply.sh    # SQL 실행
./scripts/db_verify.sh   # 존재 확인
```

## 필수 테이블
profiles, prompts, prompt_versions, prompt_variables,
bookmarks, likes, usage_events

## 선택 테이블
collections, collection_items, comments, reports, moderation_actions
