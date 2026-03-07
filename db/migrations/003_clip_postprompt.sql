-- ============================================================
-- PromptBuilder: 003_clip_postprompt.sql
-- 개발 중 수동 추가된 스키마를 마이그레이션에 반영
-- 001_init.sql 이후 추가된 내용:
--   1. prompts 테이블: clip_count, body_markdown 컬럼 추가
--   2. clips 테이블 (북마크 대체)
--   3. post_prompts 테이블 (게시물 내 복수 프롬프트)
--   4. post_prompt_variables 테이블 (post_prompt 변수 정의)
--   5. v_trending_scores 뷰 수정 (bookmarks -> clips 반영)
-- ============================================================

-- 1. prompts: clip_count 컬럼 추가
ALTER TABLE prompts
    ADD COLUMN IF NOT EXISTS clip_count INT NOT NULL DEFAULT 0;

-- 2. prompts: body_markdown 컬럼 추가
--    텍스트+프롬프트 블록 순서를 [[PROMPT:N]] 마커로 인코딩한 Markdown
ALTER TABLE prompts
    ADD COLUMN IF NOT EXISTS body_markdown TEXT;

-- 3. clips 테이블 (bookmark 대체 — 클립 기능)
CREATE TABLE IF NOT EXISTS clips (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL,
    prompt_id  UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_clips_user_prompt ON clips(user_id, prompt_id);
CREATE INDEX IF NOT EXISTS idx_clips_user_id    ON clips(user_id);
CREATE INDEX IF NOT EXISTS idx_clips_prompt_id  ON clips(prompt_id);

-- 4. post_prompts 테이블
--    게시물(prompt) 안에 여러 개의 프롬프트 블록을 정의
CREATE TABLE IF NOT EXISTS post_prompts (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_id     UUID NOT NULL,          -- 부모 게시물 ID
    title         VARCHAR(200) NOT NULL DEFAULT '새 프롬프트',
    template_body TEXT NOT NULL DEFAULT '',
    sort_order    INT  NOT NULL DEFAULT 0,
    status        VARCHAR(20) NOT NULL DEFAULT 'draft'
                  CHECK (status IN ('draft','in_progress','complete')),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_prompts_prompt_id ON post_prompts(prompt_id);

CREATE TRIGGER trg_post_prompts_updated_at
    BEFORE UPDATE ON post_prompts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 5. post_prompt_variables 테이블
--    post_prompt 별 변수 정의 (key, label, description)
CREATE TABLE IF NOT EXISTS post_prompt_variables (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_prompt_id UUID NOT NULL,
    key            VARCHAR(100) NOT NULL,
    label          VARCHAR(200),
    description    TEXT,                  -- 변수 입력 힌트
    type           VARCHAR(20) NOT NULL DEFAULT 'text'
                   CHECK (type IN ('text','textarea','select')),
    sort_order     INT NOT NULL DEFAULT 0,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_post_prompt_variables_post_prompt_id
    ON post_prompt_variables(post_prompt_id);

-- 6. v_trending_scores 뷰 수정: clips 테이블도 포함
CREATE OR REPLACE VIEW v_trending_scores AS
WITH recent_events AS (
    SELECT prompt_id, 1 AS score
    FROM usage_events
    WHERE event_type = 'generate'
      AND created_at >= NOW() - INTERVAL '7 days'
    UNION ALL
    SELECT prompt_id, 2 AS score
    FROM likes
    WHERE created_at >= NOW() - INTERVAL '7 days'
    UNION ALL
    SELECT prompt_id, 3 AS score
    FROM clips
    WHERE created_at >= NOW() - INTERVAL '7 days'
)
SELECT
    prompt_id,
    SUM(score) AS weekly_score,
    NOW() AS calculated_at
FROM recent_events
GROUP BY prompt_id;

-- 7. v_public_prompts 뷰 수정: clip_count 포함
-- CREATE OR REPLACE 는 컬럼명 변경 불가 → DROP 후 재생성
DROP VIEW IF EXISTS v_public_prompts;
CREATE VIEW v_public_prompts AS
SELECT
    p.id,
    p.user_id,
    p.title,
    p.description,
    p.tags,
    p.visibility,
    p.current_version_id,
    p.clip_count,
    p.like_count,
    p.generate_count,
    p.view_count,
    p.body_markdown,
    p.created_at,
    p.updated_at,
    COALESCE(ts.weekly_score, 0) AS weekly_score
FROM prompts p
LEFT JOIN v_trending_scores ts ON ts.prompt_id = p.id
WHERE p.visibility = 'public'
  AND p.is_deleted = false;
