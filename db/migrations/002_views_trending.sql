-- ============================================================
-- PromptBuilder: 002_views_trending.sql
-- trending 점수 View + 공개 프롬프트 View
-- ============================================================

-- ============================================================
-- v_trending_scores: 주간 trending 점수
-- score = bookmarks*3 + likes*2 + generate*1 (최근 7일)
-- ============================================================
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
    FROM bookmarks
    WHERE created_at >= NOW() - INTERVAL '7 days'
)
SELECT
    prompt_id,
    SUM(score) AS weekly_score,
    NOW() AS calculated_at
FROM recent_events
GROUP BY prompt_id;

COMMENT ON VIEW v_trending_scores IS
    '주간 trending 점수: bookmarks*3 + likes*2 + generate*1 (최근 7일)';

-- ============================================================
-- v_public_prompts: 공개 프롬프트 + trending 점수
-- ============================================================
CREATE OR REPLACE VIEW v_public_prompts AS
SELECT
    p.id,
    p.user_id,
    p.title,
    p.description,
    p.tags,
    p.visibility,
    p.current_version_id,
    p.bookmark_count,
    p.like_count,
    p.generate_count,
    p.view_count,
    p.created_at,
    p.updated_at,
    COALESCE(ts.weekly_score, 0) AS weekly_score
FROM prompts p
LEFT JOIN v_trending_scores ts ON ts.prompt_id = p.id
WHERE p.visibility = 'public'
  AND p.is_deleted = false;

COMMENT ON VIEW v_public_prompts IS '공개 프롬프트 + 주간 trending 점수';
