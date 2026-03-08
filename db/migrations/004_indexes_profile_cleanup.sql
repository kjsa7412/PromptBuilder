-- ============================================================
-- PromptBuilder: 004_indexes_profile_cleanup.sql
-- 대규모 패치(소유자 편집·삭제·공개여부·프로필 관리) 이후
-- 실서비스 반영에 필요한 인덱스 추가 및 정합성 보강
--
-- 변경 내용:
--   1. prompts: (user_id, visibility, is_deleted) 복합 인덱스
--      - findMyDraftPrompts / findMyPrompts 쿼리 성능 향상
--   2. prompts: (id, user_id) 복합 인덱스
--      - findByIdForOwner / softDeletePrompt / updateVisibility 쿼리 성능 향상
--   3. profiles: username 유니크 인덱스 (NULL·삭제 제외)
--      - 프로필 수정 기능 추가로 username 중복 방지
--   4. post_prompt_variables: (post_prompt_id, key) 유니크 인덱스
--      - 동일 post_prompt 내 변수 key 중복 방지
--   5. likes: clip_count 조인 지원 — LikeMapper bookmark_count 참조를
--      clip_count 로 교체 (쿼리 수정)
--   6. v_my_prompts: 소유자용 프롬프트 View (draft 포함)
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- 1. prompts: 소유자 목록·초안 조회용 복합 인덱스
--    findMyPrompts  : WHERE user_id = ? AND is_deleted = false
--    findMyDraftPrompts: WHERE user_id = ? AND visibility = 'draft' AND is_deleted = false
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_prompts_user_visibility
    ON prompts(user_id, visibility)
    WHERE is_deleted = false;

-- ─────────────────────────────────────────────────────────────
-- 2. prompts: 소유자 단건 조회·수정·삭제용 복합 인덱스
--    findByIdForOwner / softDeletePrompt / updateVisibility / updatePromptFull
--    WHERE id = ? AND user_id = ? AND is_deleted = false
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_prompts_id_user
    ON prompts(id, user_id)
    WHERE is_deleted = false;

-- ─────────────────────────────────────────────────────────────
-- 3. profiles: username 유니크 인덱스
--    updateProfile 으로 username 설정 가능 → 중복 방지
--    NULL username, is_deleted=true 제외
-- ─────────────────────────────────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS uq_profiles_username
    ON profiles(username)
    WHERE username IS NOT NULL AND is_deleted = false;

-- ─────────────────────────────────────────────────────────────
-- 4. post_prompt_variables: (post_prompt_id, key) 유니크 인덱스
--    동일 프롬프트 블록 내 변수명 중복 방지
-- ─────────────────────────────────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS uq_post_prompt_variables_key
    ON post_prompt_variables(post_prompt_id, key);

-- ─────────────────────────────────────────────────────────────
-- 5. LikeMapper.findByUserId bookmark_count → clip_count 대응
--    likes 조회 시 clip_count 를 함께 반환하도록 View 교체
--    (LikeMapper.xml 의 SELECT p.bookmark_count 를 p.clip_count 로 교체)
-- ─────────────────────────────────────────────────────────────
-- NOTE: 코드(LikeMapper.xml)에서 p.bookmark_count → p.clip_count 수정 필요.
--       bookmark_count 컬럼 자체는 하위 호환을 위해 유지한다.
--       아래는 혹시 필요 시 DEFAULT 값 동기화용 코멘트로 남긴다.
-- UPDATE prompts SET bookmark_count = clip_count WHERE bookmark_count = 0 AND clip_count > 0;

-- ─────────────────────────────────────────────────────────────
-- 6. v_my_prompts: 소유자용 프롬프트 View (draft 포함)
--    - 내 라이브러리 / 내 프롬프트 목록에서 활용
--    - findMyPrompts / findMyDraftPrompts 와 동일 결과
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW v_my_prompts AS
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
    p.updated_at
FROM prompts p
WHERE p.is_deleted = false;

COMMENT ON VIEW v_my_prompts IS '소유자용 프롬프트 View — draft 포함, is_deleted 제외. user_id 로 필터하여 사용.';

-- ─────────────────────────────────────────────────────────────
-- 5. profiles: 닉네임 검색용 인덱스 (display_name, username ILIKE 검색)
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_profiles_display_name_lower
    ON profiles(lower(display_name))
    WHERE is_deleted = false AND display_name IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_profiles_username_lower
    ON profiles(lower(username))
    WHERE is_deleted = false AND username IS NOT NULL;
