-- ============================================================
-- PromptBuilder: 001_init.sql
-- MVP 테이블 초기화 (FK 제약 없음, RLS 없음)
-- ============================================================

-- UUID 생성 확장
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- profiles: 사용자 프로필
-- ============================================================
CREATE TABLE IF NOT EXISTS profiles (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL,
    username     VARCHAR(50),
    display_name VARCHAR(100),
    avatar_url   TEXT,
    bio          TEXT,
    is_admin     BOOLEAN NOT NULL DEFAULT false,
    is_deleted   BOOLEAN NOT NULL DEFAULT false,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_profiles_user_id ON profiles(user_id) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- ============================================================
-- prompts: 프롬프트 메타데이터
-- ============================================================
CREATE TABLE IF NOT EXISTS prompts (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id            UUID NOT NULL,
    title              VARCHAR(200) NOT NULL,
    description        TEXT,
    tags               TEXT[],
    visibility         VARCHAR(20) NOT NULL DEFAULT 'draft'
                       CHECK (visibility IN ('draft','public','private','banned')),
    current_version_id UUID,
    bookmark_count     INT NOT NULL DEFAULT 0,
    like_count         INT NOT NULL DEFAULT 0,
    generate_count     INT NOT NULL DEFAULT 0,
    view_count         INT NOT NULL DEFAULT 0,
    is_deleted         BOOLEAN NOT NULL DEFAULT false,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prompts_user_id ON prompts(user_id);
CREATE INDEX IF NOT EXISTS idx_prompts_visibility ON prompts(visibility) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_prompts_created_at ON prompts(created_at DESC) WHERE visibility = 'public' AND is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_prompts_tags ON prompts USING GIN(tags) WHERE visibility = 'public' AND is_deleted = false;

-- ============================================================
-- prompt_versions: 프롬프트 버전
-- ============================================================
CREATE TABLE IF NOT EXISTS prompt_versions (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_id      UUID NOT NULL,
    version_number INT NOT NULL DEFAULT 1,
    template_body  TEXT NOT NULL,
    change_note    TEXT,
    is_deleted     BOOLEAN NOT NULL DEFAULT false,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prompt_versions_prompt_id ON prompt_versions(prompt_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_prompt_versions_prompt_version
    ON prompt_versions(prompt_id, version_number) WHERE is_deleted = false;

-- ============================================================
-- prompt_variables: 버전별 변수 정의
-- ============================================================
CREATE TABLE IF NOT EXISTS prompt_variables (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    version_id      UUID NOT NULL,
    prompt_id       UUID NOT NULL,
    key             VARCHAR(100) NOT NULL,
    label           VARCHAR(200),
    type            VARCHAR(20) NOT NULL DEFAULT 'text'
                    CHECK (type IN ('text','textarea','select')),
    required        BOOLEAN NOT NULL DEFAULT true,
    placeholder     TEXT,
    help_text       TEXT,
    default_value   TEXT,
    options         TEXT[],
    validation_rule TEXT,
    sort_order      INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_prompt_variables_version_id ON prompt_variables(version_id);
CREATE INDEX IF NOT EXISTS idx_prompt_variables_prompt_id ON prompt_variables(prompt_id);

-- ============================================================
-- bookmarks
-- ============================================================
CREATE TABLE IF NOT EXISTS bookmarks (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL,
    prompt_id  UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_bookmarks_user_prompt ON bookmarks(user_id, prompt_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_prompt_id ON bookmarks(prompt_id);

-- ============================================================
-- likes
-- ============================================================
CREATE TABLE IF NOT EXISTS likes (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id    UUID NOT NULL,
    prompt_id  UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_likes_user_prompt ON likes(user_id, prompt_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_prompt_id ON likes(prompt_id);

-- ============================================================
-- usage_events: Generate 이벤트
-- ============================================================
CREATE TABLE IF NOT EXISTS usage_events (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_id  UUID NOT NULL,
    version_id UUID,
    user_id    UUID,
    session_id VARCHAR(100),
    event_type VARCHAR(50) NOT NULL DEFAULT 'generate'
               CHECK (event_type IN ('generate','view','copy')),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_usage_events_prompt_id ON usage_events(prompt_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_user_id ON usage_events(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_usage_events_created_at ON usage_events(created_at DESC);

-- ============================================================
-- collections (선택)
-- ============================================================
CREATE TABLE IF NOT EXISTS collections (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    visibility  VARCHAR(20) NOT NULL DEFAULT 'private'
                CHECK (visibility IN ('public','private')),
    is_deleted  BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_collections_user_id ON collections(user_id);

-- ============================================================
-- collection_items (선택)
-- ============================================================
CREATE TABLE IF NOT EXISTS collection_items (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL,
    prompt_id     UUID NOT NULL,
    sort_order    INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_collection_items ON collection_items(collection_id, prompt_id);
CREATE INDEX IF NOT EXISTS idx_collection_items_collection_id ON collection_items(collection_id);

-- ============================================================
-- comments (선택)
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prompt_id  UUID NOT NULL,
    user_id    UUID NOT NULL,
    parent_id  UUID,
    content    TEXT NOT NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_prompt_id ON comments(prompt_id) WHERE is_deleted = false;

-- ============================================================
-- reports (선택)
-- ============================================================
CREATE TABLE IF NOT EXISTS reports (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL,
    target_type VARCHAR(20) NOT NULL CHECK (target_type IN ('prompt','comment')),
    target_id   UUID NOT NULL,
    reason      VARCHAR(100) NOT NULL,
    description TEXT,
    status      VARCHAR(20) NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','reviewed','dismissed')),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_reports_target ON reports(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

-- ============================================================
-- moderation_actions (선택)
-- ============================================================
CREATE TABLE IF NOT EXISTS moderation_actions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    admin_id    UUID NOT NULL,
    target_type VARCHAR(20) NOT NULL,
    target_id   UUID NOT NULL,
    action      VARCHAR(50) NOT NULL CHECK (action IN ('hide','ban','restore','warn')),
    reason      TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_moderation_actions_target ON moderation_actions(target_type, target_id);

-- ============================================================
-- updated_at 자동 갱신
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_prompts_updated_at
    BEFORE UPDATE ON prompts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_prompt_versions_updated_at
    BEFORE UPDATE ON prompt_versions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_collections_updated_at
    BEFORE UPDATE ON collections FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_comments_updated_at
    BEFORE UPDATE ON comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_reports_updated_at
    BEFORE UPDATE ON reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
