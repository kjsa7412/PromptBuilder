-- ============================================================
-- Bulk Insert: 국내여행 일정 자동 설계 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.981Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '국내여행 일정 자동 설계 프롬프트',
        '당일치기부터 2박 3일까지, 출발지·교통수단·취향·예산을 반영해 현실적인 국내여행 일정을 짜주는 핵심 프롬프트입니다.',
        '{"국내여행","여행일정","1박2일","당일치기","코스추천"}'::text[],
        'public',
        '## 소개

국내여행에서 가장 자주 필요한 것은 결국 ''내 상황에 맞는 일정''입니다. 이 게시물은 지역만 추천하는 수준이 아니라, 이동 피로도·식사 타이밍·사진 포인트·대체 코스까지 포함한 실제 실행형 일정을 만드는 데 초점을 둡니다.

먼저 전체 일정을 설계하고,

[[PROMPT:0]]

이미 생각해둔 후보지가 있다면 동선 기준으로 다시 다듬을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 국내여행 전체 일정 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '국내여행 전체 일정 설계',
        '당신은 국내여행 전문 플래너입니다.

아래 조건에 맞춰 국내여행 일정을 짜주세요.

[출발지]
{{departure}}

[여행 지역 또는 후보 지역]
{{destination}}

[여행 기간]
{{duration}}

[교통수단]
{{transport}}

[동행자]
{{companions}}

[여행 스타일]
{{travel_style}}

[예산 수준]
{{budget}}

[추가 조건]
{{extra_conditions}}

조건:
- 실제 이동시간과 휴식 포인트를 고려한 현실적인 일정으로 짤 것
- 아침/점심/저녁/카페/산책/숙소 체크인 흐름이 자연스럽게 이어지게 할 것
- 너무 많은 장소를 억지로 넣지 말고 핵심 위주로 구성할 것
- 각 장소마다 추천 이유를 한 줄씩 적을 것
- 우천 시 대체 코스 2개를 포함할 것
- 마지막에 ''이 일정의 핵심 포인트 5개''와 ''예약 또는 운영시간 재확인 필요 항목''을 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '여행 출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '가고 싶은 지역 또는 후보 지역을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일, 2박 3일 등을 입력하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transport',
        '교통수단',
        '자차, KTX, 시외버스, 대중교통 등을 선택하세요',
        'select',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '혼자, 친구, 연인, 부모님, 아이 동반 등을 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '맛집, 자연, 감성카페, 사진, 체험, 휴식 등 원하는 스타일을 입력하세요',
        'textarea',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'budget',
        '예산',
        '총 예산 또는 1인당 예산을 입력하세요',
        'text',
        6,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'extra_conditions',
        '추가 조건',
        '걷는 거리 적게, 주차 편해야 함, 붐비지 않게 등 조건을 입력하세요',
        'textarea',
        7,
        NOW()
    );

    -- post_prompt[1]: 후보지 목록을 실제 동선으로 재구성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '후보지 목록을 실제 동선으로 재구성',
        '당신은 국내여행 동선 최적화 도우미입니다.

아래 후보지 목록을 보고 실제 여행 일정으로 재구성해주세요.

[지역]
{{region}}

[후보지 목록]
{{candidate_places}}

[식사 취향]
{{food_preference}}

[이동 제약]
{{movement_limit}}

조건:
- 위치상 비효율적인 순서는 과감히 정리할 것
- 꼭 갈 만한 곳, 취향이면 좋은 곳, 빼도 되는 곳으로 나눌 것
- 하루 일정표 형태로 다시 배치할 것
- 포토스팟, 휴식 타이밍, 카페 타이밍을 함께 제안할 것
- 마지막에 ''이 코스에서 과한 부분''도 솔직하게 지적할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'region',
        '지역',
        '주요 여행 지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'candidate_places',
        '후보지 목록',
        '가고 싶은 장소들을 줄바꿈으로 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'food_preference',
        '식사 취향',
        '해산물, 시장, 카페 위주 등 식사 취향을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'movement_limit',
        '이동 제약',
        '도보 최소화, 운전 오래 못함 등 제약을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 국내여행 일정 자동 설계 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 아이와 함께 가는 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.983Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '아이와 함께 가는 국내여행 프롬프트',
        '유아·어린이 동반 여행에서 필요한 낮잠, 식사, 화장실, 체험, 이동 피로도까지 반영한 가족형 국내여행 프롬프트입니다.',
        '{"국내여행","아이와여행","가족여행","유아동반","육아여행"}'::text[],
        'public',
        '## 소개

아이와 함께하는 국내여행은 예쁜 코스보다 ''무리 없는 흐름''이 더 중요합니다. 이 게시물은 이동 거리, 낮잠, 식사, 아이가 흥미를 느낄 포인트, 부모가 쉴 수 있는 포인트까지 반영해 가족형 일정을 만들기 위해 설계했습니다.

[[PROMPT:0]]

필요하면 숙소와 식당 선택 기준도 같이 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 동반 국내여행 일정 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 동반 국내여행 일정 설계',
        '당신은 아이 동반 가족여행 전문 플래너입니다.

아래 정보를 바탕으로 아이와 함께 가는 국내여행 일정을 짜주세요.

[출발지]
{{departure}}

[여행 지역]
{{destination}}

[아이 나이]
{{child_age}}

[여행 기간]
{{duration}}

[교통수단]
{{transport}}

[아이 성향]
{{child_style}}

[부모가 원하는 분위기]
{{parent_style}}

[중요 조건]
{{important_conditions}}

조건:
- 낮잠, 간식, 화장실, 휴식 타이밍을 고려할 것
- 이동이 너무 길거나 빡센 코스는 피할 것
- 아이가 즐길 포인트와 부모가 만족할 포인트를 함께 제안할 것
- 실내/실외를 적절히 섞을 것
- 숙소 체크인 전후 흐름까지 자연스럽게 짤 것
- 마지막에 ''아이 동반 여행 체크포인트''와 ''예약 또는 운영시간 재확인 포인트''를 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '가고 싶은 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'child_age',
        '아이 나이',
        '개월 수 또는 나이를 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transport',
        '교통수단',
        '자차, KTX, 대중교통 등을 선택하세요',
        'select',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'child_style',
        '아이 성향',
        '동물 좋아함, 뛰어노는 것 좋아함, 낯가림 있음 등을 입력하세요',
        'textarea',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'parent_style',
        '부모 스타일',
        '맛집, 산책, 카페, 사진, 체험 등 원하는 분위기를 입력하세요',
        'textarea',
        6,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'important_conditions',
        '중요 조건',
        '유모차 가능, 수유실, 주차 편리 등 조건을 입력하세요',
        'textarea',
        7,
        NOW()
    );

    -- post_prompt[1]: 아이 동반 숙소·식당 선택 기준 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 동반 숙소·식당 선택 기준 정리',
        '아이와 국내여행 갈 때 숙소와 식당을 고를 때 체크해야 할 기준표를 만들어주세요.

[아이 나이]
{{child_age}}

[여행 지역]
{{destination}}

[부모가 특히 걱정하는 점]
{{worry_points}}

조건:
- 숙소 편의, 식당 편의, 이동 편의, 돌발상황 대응으로 나눠 정리할 것
- 유모차, 아기의자, 수유/기저귀, 소음, 대기시간, 주차, 아침 식사까지 고려할 것
- 마지막에 ''예약 전에 확인할 질문 10개''를 써줄 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'child_age',
        '아이 나이',
        '아이 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'destination',
        '여행 지역',
        '여행 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'worry_points',
        '걱정 포인트',
        '낮잠, 편식, 긴 대기 어려움 등 걱정 포인트를 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 아이와 함께 가는 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 비 오는 날 국내여행 대체 코스 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.984Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '비 오는 날 국내여행 대체 코스 프롬프트',
        '우천, 강풍, 폭염, 한파처럼 날씨가 변수일 때 실내 위주로 여행 일정을 다시 설계해주는 프롬프트입니다.',
        '{"국내여행","비오는날","실내여행","대체코스","우천대비"}'::text[],
        'public',
        '## 소개

국내여행은 날씨 변수에 크게 영향을 받습니다. 이 게시물은 비가 오거나 바람이 강한 날에도 여행이 망가지지 않도록 실내 중심의 대체 코스를 빠르게 만드는 데 적합합니다.

[[PROMPT:0]]

이미 짜둔 일정이 있다면 우천 버전으로 다시 바꿀 수도 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 우천·실내 중심 여행 코스 재설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '우천·실내 중심 여행 코스 재설계',
        '당신은 날씨 변수에 강한 국내여행 플래너입니다.

아래 조건에 맞춰 비가 오거나 날씨가 좋지 않아도 즐길 수 있는 국내여행 일정을 만들어주세요.

[여행 지역]
{{destination}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[원래 원했던 여행 분위기]
{{desired_style}}

[날씨 상황]
{{weather_issue}}

조건:
- 박물관, 전시, 실내 체험, 시장, 대형 카페, 전망 공간, 실내 산책 가능한 곳 등을 적절히 섞을 것
- 비 오는 날 오히려 더 분위기 있는 코스가 되도록 제안할 것
- 이동 동선이 꼬이지 않게 묶을 것
- 젖은 옷/우산/주차/대중교통까지 현실적으로 고려할 것
- 마지막에 ''비 오는 날 여행 운영 팁'' 7개를 적을 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기 또는 숙박 일정을 입력하세요',
        'select',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '혼자, 연인, 친구, 부모님, 아이 동반 등을 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'desired_style',
        '원래 분위기',
        '바다, 산책, 감성카페, 사진 등 원래 원한 분위기를 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'weather_issue',
        '날씨 상황',
        '비, 강풍, 폭염, 한파 등 상황을 입력하세요',
        'select',
        4,
        NOW()
    );

    -- post_prompt[1]: 기존 야외 일정의 실내 대체안 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '기존 야외 일정의 실내 대체안 만들기',
        '아래 기존 국내여행 일정을 읽고, 같은 지역 안에서 실내 또는 반실내 중심 대체안으로 바꿔주세요.

[기존 일정]
{{original_plan}}

조건:
- 완전히 다른 여행이 되지 않도록 원래 분위기를 최대한 살릴 것
- 사진, 식사, 휴식, 쇼핑, 체험 요소를 균형 있게 넣을 것
- 장소별로 ''왜 대체안으로 좋은지''를 짧게 설명할 것
- 마지막에 날씨가 조금 나아질 경우 넣을 수 있는 야외 후보도 3개 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'original_plan',
        '기존 일정',
        '이미 짜둔 여행 일정을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 비 오는 날 국내여행 대체 코스 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: KTX·버스·대중교통 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.984Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        'KTX·버스·대중교통 국내여행 프롬프트',
        '자가용 없이 KTX, 시외버스, 지하철, 시내버스를 활용해 이동 효율이 좋은 국내여행 동선을 짜는 프롬프트입니다.',
        '{"국내여행","KTX","대중교통","시외버스","교통동선"}'::text[],
        'public',
        '## 소개

국내여행은 차가 없을 때 난도가 확 올라갑니다. 이 게시물은 KTX, 시외버스, 지하철, 시내버스를 기준으로 이동 피로도가 덜한 동선을 만드는 데 초점을 둡니다.

[[PROMPT:0]]

기차나 버스 시간을 실제 예약 전 확인해야 할 때 사용할 질문형 체크리스트도 함께 만들 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 대중교통 중심 국내여행 동선 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '대중교통 중심 국내여행 동선 설계',
        '당신은 대중교통 중심 국내여행 동선 플래너입니다.

아래 조건을 바탕으로 KTX, 시외버스, 지하철, 시내버스를 이용하는 여행 코스를 짜주세요.

[출발지]
{{departure}}

[목적지 지역]
{{destination}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[우선순위]
{{priority}}

[짐 또는 이동 제약]
{{movement_limit}}

조건:
- 역, 터미널, 숙소, 주요 관광지 사이 이동이 자연스럽게 이어지게 할 것
- 환승이 너무 복잡한 코스는 피할 것
- 도착 직후/출발 직전 넣기 좋은 장소도 포함할 것
- 교통편은 실제 예약 전 공식 시간표를 확인해야 한다는 전제로, 계획용 동선을 짤 것
- 마지막에 ''이 여행에서 교통 때문에 놓치기 쉬운 체크포인트''를 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발역 또는 출발 지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '목적지',
        '여행 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '혼자, 친구, 연인, 부모님 등 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'priority',
        '우선순위',
        '걷는 거리 최소화, 환승 최소화, 풍경 좋은 이동 등 우선순위를 입력하세요',
        'textarea',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'movement_limit',
        '이동 제약',
        '캐리어 있음, 늦은 밤 이동 피함 등 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 기차·버스 예약 전 체크리스트 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '기차·버스 예약 전 체크리스트 만들기',
        '국내여행에서 KTX나 시외버스, 대중교통을 쓸 때 예약 전 확인해야 할 체크리스트를 만들어주세요.

조건:
- 출발/도착 시간, 막차, 역에서 숙소까지 거리, 환승 시간, 좌석, 수하물, 체크인 시간, 당일 날씨를 포함할 것
- 혼자 여행 / 부모님 동반 / 아이 동반 / 친구 여행으로 나눠 다르게 주의할 점을 적을 것
- 마지막에 ''실제 예약 직전에 공식 사이트에서 다시 볼 항목''만 따로 정리할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: KTX·버스·대중교통 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 자차 드라이브 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.984Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '자차 드라이브 국내여행 프롬프트',
        '운전 피로도를 줄이고 주차·휴식·식사 타이밍까지 반영한 자차 중심 국내여행 드라이브 코스를 짜는 프롬프트입니다.',
        '{"국내여행","자차여행","드라이브","주차","로드트립"}'::text[],
        'public',
        '## 소개

자차 여행은 자유롭지만 일정이 과해지기 쉽습니다. 이 게시물은 운전 스트레스를 줄이고, 쉬는 타이밍과 주차 난이도까지 감안한 드라이브형 여행 코스를 만들 때 쓰기 좋습니다.

[[PROMPT:0]]

운전 구간별 휴식 계획이 필요하면 아래 프롬프트를 함께 쓸 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 자차 중심 드라이브 코스 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '자차 중심 드라이브 코스 설계',
        '당신은 국내 드라이브 여행 플래너입니다.

아래 조건에 맞춰 자차로 가기 좋은 국내여행 코스를 짜주세요.

[출발지]
{{departure}}

[가고 싶은 지역]
{{destination}}

[여행 기간]
{{duration}}

[운전 가능 시간]
{{drive_tolerance}}

[동행자]
{{companions}}

[원하는 분위기]
{{travel_mood}}

[중요 조건]
{{conditions}}

조건:
- 운전 구간이 너무 몰리지 않도록 분산할 것
- 주차가 너무 어려울 수 있는 곳은 주의사항을 함께 적을 것
- 중간 휴식, 화장실, 카페, 식사, 뷰포인트를 자연스럽게 넣을 것
- 해 질 무렵이나 야간 드라이브 포인트가 있으면 함께 제안할 것
- 마지막에 ''운전 피로를 줄이는 일정 조정 팁''을 5개 적을 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '가고 싶은 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'drive_tolerance',
        '운전 가능 시간',
        '한 번에 몇 시간 정도 운전 가능한지 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '누구와 가는지 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_mood',
        '원하는 분위기',
        '바다, 산, 숲길, 카페, 야경 등 원하는 분위기를 입력하세요',
        'textarea',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'conditions',
        '중요 조건',
        '주차 쉬워야 함, 걷는 거리 짧게 등 조건을 입력하세요',
        'textarea',
        6,
        NOW()
    );

    -- post_prompt[1]: 운전 구간별 휴식·식사 포인트 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '운전 구간별 휴식·식사 포인트 정리',
        '아래 자차 여행 계획을 보고 운전 피로를 줄일 수 있도록 중간 휴식과 식사 포인트를 다시 배치해주세요.

[여행 계획]
{{drive_plan}}

조건:
- 운전만 길게 이어지는 구간을 찾아서 끊어줄 것
- 아침/점심/저녁과 카페, 편의점, 화장실 타이밍을 자연스럽게 조정할 것
- 동승자가 지루하지 않게 중간에 풍경 포인트를 넣을 것
- 마지막에 ''빼도 되는 이동''을 솔직하게 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'drive_plan',
        '여행 계획',
        '이미 생각해둔 자차 여행 계획을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 자차 드라이브 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 국내 식도락·카페 투어 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.985Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '국내 식도락·카페 투어 프롬프트',
        '지역 대표 음식, 시장, 로컬 맛집, 감성카페를 한 번에 묶어 식사 흐름이 좋은 식도락 중심 여행 코스를 짜는 프롬프트입니다.',
        '{"국내여행","식도락","맛집여행","카페투어","로컬맛집"}'::text[],
        'public',
        '## 소개

많은 국내여행은 결국 먹으러 가는 여행이기도 합니다. 이 게시물은 유명한 곳만 나열하는 대신, 아침-점심-간식-저녁-카페의 흐름이 자연스럽고 지역성이 살아 있는 식도락 코스를 만들기 위해 설계했습니다.

[[PROMPT:0]]

맛집 후보가 많을 때는 우선순위를 정리하는 데 아래 프롬프트를 쓸 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 지역 식도락 중심 여행 코스 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '지역 식도락 중심 여행 코스 설계',
        '당신은 국내 식도락 여행 플래너입니다.

아래 조건에 맞춰 지역 음식과 카페를 중심으로 여행 코스를 짜주세요.

[여행 지역]
{{destination}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[선호 음식]
{{food_preference}}

[피하고 싶은 음식 또는 조건]
{{avoid_conditions}}

[원하는 분위기]
{{mood}}

조건:
- 아침, 점심, 간식, 저녁, 카페 흐름이 과하지 않게 이어지게 할 것
- 관광지와 식사 장소를 따로 놀지 않게 동선에 맞춰 배치할 것
- 무조건 유명한 곳만 말하지 말고 로컬 느낌, 시장, 오래된 노포, 감성 카페를 균형 있게 섞을 것
- 웨이팅 가능성이나 식사 타이밍 주의점도 적을 것
- 마지막에 ''이 지역에서 꼭 먹을 것 5개''와 ''비 오면 더 좋은 식도락 플랜''을 함께 적을 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '여행 지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '누구와 가는지 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'food_preference',
        '선호 음식',
        '해산물, 국밥, 면, 빵, 디저트 등 선호를 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'avoid_conditions',
        '피할 조건',
        '매운 음식 제외, 웨이팅 긴 곳 피함 등 입력하세요',
        'textarea',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'mood',
        '원하는 분위기',
        '시장감성, 오션뷰카페, 노포, 힙한 카페 등 분위기를 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 맛집 후보 리스트 우선순위 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '맛집 후보 리스트 우선순위 정리',
        '아래 국내여행 맛집/카페 후보 리스트를 보고 실제로 갈 가치가 높은 순서로 정리해주세요.

[지역]
{{destination}}

[후보 리스트]
{{candidate_list}}

[여행 스타일]
{{travel_style}}

조건:
- 식사 시간, 이동 동선, 분위기, 웨이팅 부담 기준으로 평가할 것
- 반드시 갈 곳 / 상황 따라 갈 곳 / 굳이 안 가도 될 곳으로 나눌 것
- 너무 유명하지만 과한 곳과 진짜 여행 흐름에 맞는 곳을 구분해줄 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'destination',
        '지역',
        '지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'candidate_list',
        '후보 리스트',
        '찾아둔 맛집과 카페 후보를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'travel_style',
        '여행 스타일',
        '맛집 위주, 관광 반반, 카페 위주 등 입력하세요',
        'text',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 국내 식도락·카페 투어 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 숙소 비교·선택 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.985Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '숙소 비교·선택 프롬프트',
        '호텔, 펜션, 리조트, 한옥스테이, 게스트하우스 후보를 여행 목적과 동선 기준으로 비교해 최종 선택을 돕는 프롬프트입니다.',
        '{"국내여행","숙소","호텔","펜션","숙소비교"}'::text[],
        'public',
        '## 소개

국내여행 만족도는 숙소가 크게 좌우합니다. 이 게시물은 단순 가격 비교가 아니라 위치, 주차, 체크인, 조식, 소음, 여행 동선까지 함께 판단하도록 만든 숙소 선택용 프롬프트입니다.

[[PROMPT:0]]

후보를 아직 못 정했다면 지역에 맞는 숙소 유형을 먼저 고르는 데 아래 프롬프트를 쓸 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 숙소 후보 비교표 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '숙소 후보 비교표 만들기',
        '당신은 국내여행 숙소 선택 도우미입니다.

아래 숙소 후보들을 여행 목적에 맞게 비교해주세요.

[여행 지역]
{{destination}}

[동행자]
{{companions}}

[여행 스타일]
{{travel_style}}

[숙소 후보]
{{accommodation_candidates}}

[중요 기준]
{{important_criteria}}

조건:
- 위치, 주차, 체크인 편의, 객실 분위기, 주변 식당 접근성, 소음 가능성, 아침 동선, 가성비를 기준으로 비교할 것
- 표 형태와 요약 코멘트를 함께 줄 것
- ''이 여행과 가장 잘 맞는 1곳''과 ''차선책 1곳''을 고를 것
- 마지막에 예약 전 확인할 질문 8개를 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '숙소를 잡을 지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '연인, 친구, 가족, 부모님 등 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '바다뷰, 시내 접근, 감성숙소, 휴식 중심 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'accommodation_candidates',
        '숙소 후보',
        '후보 숙소 목록과 간단 메모를 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'important_criteria',
        '중요 기준',
        '주차, 조식, 침대, 체크아웃, 야경 등 중요 기준을 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 이 여행에 맞는 숙소 유형부터 정하기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '이 여행에 맞는 숙소 유형부터 정하기',
        '아직 숙소를 못 골랐을 때, 아래 여행 조건에 맞는 숙소 유형부터 추천해주세요.

[여행 지역]
{{destination}}

[동행자]
{{companions}}

[여행 목적]
{{trip_goal}}

[예산]
{{budget}}

조건:
- 호텔, 리조트, 펜션, 한옥스테이, 게스트하우스, 레지던스 중 어떤 유형이 맞는지 설명할 것
- 각 유형의 장단점을 이 여행 기준으로 비교할 것
- 마지막에 ''숙소 검색 필터를 어떻게 걸어야 하는지'' 구체적으로 써줄 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'destination',
        '여행 지역',
        '지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'companions',
        '동행자',
        '누구와 가는지 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'trip_goal',
        '여행 목적',
        '휴식, 관광, 사진, 식도락 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'budget',
        '예산',
        '1박 예산 또는 총 숙박 예산을 입력하세요',
        'text',
        3,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 숙소 비교·선택 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 예산형 국내여행 경비표 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.985Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '예산형 국내여행 경비표 프롬프트',
        '총예산 안에서 교통, 숙소, 식비, 입장료, 카페, 여유비를 현실적으로 나눠주는 국내여행 경비 설계 프롬프트입니다.',
        '{"국내여행","예산여행","경비계획","가성비여행","여행비용"}'::text[],
        'public',
        '## 소개

여행은 가고 싶은데 예산이 애매할 때가 많습니다. 이 게시물은 총예산 안에서 여행을 실제로 굴릴 수 있도록 비용 배분, 절약 포인트, 돈 써야 할 포인트를 함께 정리하는 데 적합합니다.

[[PROMPT:0]]

여행 후 실제 사용 내역을 리뷰하고 다음 여행용 기준을 만들 때는 아래 프롬프트를 쓸 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 국내여행 예산 배분표 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '국내여행 예산 배분표 만들기',
        '당신은 현실적인 여행 예산 설계 도우미입니다.

아래 정보를 바탕으로 국내여행 예산표를 짜주세요.

[출발지]
{{departure}}

[여행 지역]
{{destination}}

[여행 기간]
{{duration}}

[동행자 수]
{{people_count}}

[총예산]
{{total_budget}}

[원하는 여행 스타일]
{{travel_style}}

조건:
- 교통, 숙소, 식비, 카페/간식, 입장료/체험, 주차/교통비, 여유비로 나눠서 예산을 배분할 것
- 어디에서 아끼고 어디에는 돈을 써야 만족도가 높은지 설명할 것
- 가성비 플랜과 만족도 우선 플랜 두 가지로 나눠 보여줄 것
- 마지막에 ''초과 지출이 잘 나는 지점''과 ''줄이기 쉬운 지점''을 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '여행 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'people_count',
        '인원',
        '총 인원을 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'total_budget',
        '총예산',
        '총예산을 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '맛집 위주, 체험 위주, 숙소에 투자 등 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 여행 후 지출 리뷰해서 다음 여행 기준 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '여행 후 지출 리뷰해서 다음 여행 기준 만들기',
        '아래 국내여행 실제 지출 내역을 보고, 다음 여행 때 더 효율적으로 예산을 쓰기 위한 리뷰를 작성해주세요.

[실제 지출 내역]
{{expense_log}}

조건:
- 잘 쓴 돈 / 과했던 돈 / 아낄 수 있었던 돈으로 나눌 것
- 다음 여행에서는 어떤 기준으로 예약하고 소비하면 좋은지 정리할 것
- 마지막에 ''다음 국내여행 예산 원칙 7개''를 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'expense_log',
        '실제 지출 내역',
        '여행 후 사용한 지출 내역을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 예산형 국내여행 경비표 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 축제·계절 특화 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.985Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '축제·계절 특화 국내여행 프롬프트',
        '벚꽃, 단풍, 바다, 겨울 실내, 지역축제처럼 시즌성과 타이밍이 중요한 국내여행을 계획하는 프롬프트입니다.',
        '{"국내여행","축제","계절여행","벚꽃","단풍"}'::text[],
        'public',
        '## 소개

국내여행은 계절과 행사 타이밍의 영향을 크게 받습니다. 이 게시물은 특정 시즌의 분위기를 살리면서도 혼잡도와 대체안까지 고려한 일정 설계에 적합합니다.

[[PROMPT:0]]

행사나 꽃놀이처럼 변수가 큰 일정일수록 백업 플랜을 따로 만드는 데 아래 프롬프트가 유용합니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 계절·축제 맞춤 국내여행 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '계절·축제 맞춤 국내여행 설계',
        '당신은 시즌형 국내여행 전문 플래너입니다.

아래 조건에 맞춰 계절감이 살아 있는 국내여행 일정을 짜주세요.

[출발지]
{{departure}}

[가고 싶은 지역 또는 후보 지역]
{{destination}}

[여행 시기]
{{season_or_date}}

[핵심 테마]
{{main_theme}}

[동행자]
{{companions}}

[중요 조건]
{{important_conditions}}

조건:
- 해당 시즌에 어울리는 풍경, 음식, 산책, 카페, 체험을 함께 제안할 것
- 축제나 유명 시즌 스폿이 있다면 혼잡을 피하는 시간대 전략도 포함할 것
- 기대가 너무 높아도 실망하기 쉬운 포인트는 솔직하게 알려줄 것
- 대체 장소나 플랜B도 함께 제안할 것
- 마지막에 ''이 여행에서 예약/운영 여부를 꼭 재확인할 항목''을 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '지역',
        '가고 싶은 지역 또는 후보지를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'season_or_date',
        '여행 시기',
        '3월 말, 10월 초, 겨울방학 등 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'main_theme',
        '핵심 테마',
        '벚꽃, 단풍, 바다, 눈, 축제, 야시장 등 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '누구와 가는지 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'important_conditions',
        '중요 조건',
        '사진 잘 나오는 곳, 붐비지 않게, 아이 가능 등 조건을 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 혼잡도 높은 시즌의 백업 플랜 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '혼잡도 높은 시즌의 백업 플랜 만들기',
        '아래 계절형 국내여행 계획을 바탕으로, 사람이 너무 많거나 날씨가 좋지 않을 경우를 대비한 플랜B와 플랜C를 만들어주세요.

[기존 계획]
{{season_plan}}

조건:
- 완전히 다른 여행이 되지 않게 같은 분위기를 유지할 것
- 시간대 조정, 장소 교체, 식사 순서 조정까지 포함할 것
- 마지막에 ''포기해도 아깝지 않은 요소''와 ''끝까지 지켜야 할 핵심 요소''를 구분할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'season_plan',
        '기존 계획',
        '기존 계절형 여행 계획을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 축제·계절 특화 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 숨은 명소·로컬 감성 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.986Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '숨은 명소·로컬 감성 국내여행 프롬프트',
        '너무 뻔한 관광지만 말고, 로컬 분위기와 동네 산책 감성이 살아 있는 국내여행 코스를 찾을 때 쓰는 프롬프트입니다.',
        '{"국내여행","숨은명소","로컬여행","감성여행","동네산책"}'::text[],
        'public',
        '## 소개

국내여행을 여러 번 가본 사람일수록 ''다들 가는 곳 말고 조금 덜 뻔한 코스''를 찾게 됩니다. 이 게시물은 과하게 외진 곳이 아니라, 여행자가 실제로 즐기기 좋은 로컬 감성 코스를 찾는 데 초점을 둡니다.

[[PROMPT:0]]

이미 유명 관광지는 알고 있을 때 보완 코스를 만들고 싶다면 아래 프롬프트를 함께 쓰면 좋습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 로컬 감성 중심 국내여행 코스 찾기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '로컬 감성 중심 국내여행 코스 찾기',
        '당신은 로컬 감성 국내여행 큐레이터입니다.

아래 조건에 맞춰 너무 뻔하지 않지만 실제로 만족도 높은 국내여행 코스를 추천해주세요.

[여행 지역]
{{destination}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[좋아하는 분위기]
{{preferred_vibe}}

[피하고 싶은 것]
{{avoid_points}}

조건:
- 전형적인 유명 관광지 나열만 하지 말 것
- 동네 산책, 로컬 카페, 시장, 작은 전시, 바다/숲/골목 풍경처럼 결이 살아 있는 장소를 포함할 것
- 사진만 찍고 끝나는 코스가 아니라 실제로 걷고 쉬고 먹는 흐름이 자연스럽게 이어지게 할 것
- 과하게 접근성이 떨어지는 곳은 주의사항을 적을 것
- 마지막에 ''이 지역에서 여행자가 놓치기 쉬운 포인트''를 적을 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '가고 싶은 지역을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companions',
        '동행자',
        '혼자, 연인, 친구 등 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'preferred_vibe',
        '좋아하는 분위기',
        '잔잔한 바다, 오래된 동네, 감성카페, 책방 등 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'avoid_points',
        '피하고 싶은 것',
        '너무 관광지 느낌, 웨이팅, 과한 이동 등 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 유명 관광지에 로컬 코스 덧붙이기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '유명 관광지에 로컬 코스 덧붙이기',
        '이미 알고 있는 유명 관광지 일정에 로컬 감성을 더해줄 보완 코스를 만들어주세요.

[기존 유명 관광지 일정]
{{main_plan}}

[원하는 감성]
{{vibe}}

조건:
- 기존 일정에 억지로 장소를 더하지 말고 자연스럽게 이어지는 보완 포인트만 추천할 것
- 식사, 산책, 카페, 소규모 공간, 해질녘 포인트를 균형 있게 제안할 것
- 마지막에 ''유명 코스만 돌 때 놓치는 경험''을 요약할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    -- post_prompt[1] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'main_plan',
        '기존 일정',
        '이미 알고 있는 관광지 일정을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'vibe',
        '원하는 감성',
        '조용함, 사진, 동네 느낌 등 입력하세요',
        'text',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 숨은 명소·로컬 감성 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 부모님·이동약자 동행 국내여행 프롬프트
-- Source: 2603101336_work.json
-- Generated: 2026-03-10T04:45:01.986Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
    v_pp_id_1 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '부모님·이동약자 동행 국내여행 프롬프트',
        '부모님, 고령자, 유모차 동반처럼 이동 편의가 중요한 여행에서 걷는 거리와 휴식, 편의시설을 고려해 일정을 짜는 프롬프트입니다.',
        '{"국내여행","부모님여행","열린관광","유모차","편한여행"}'::text[],
        'public',
        '## 소개

국내여행은 누구와 가느냐에 따라 코스가 완전히 달라집니다. 이 게시물은 부모님, 고령자, 유모차 동반처럼 이동 편의가 중요한 상황에서 무리 없는 일정을 설계하기 위해 만들었습니다.

[[PROMPT:0]]

편의시설 확인용 체크리스트가 필요하면 아래 프롬프트를 함께 사용할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 걷기 편한 국내여행 일정 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '걷기 편한 국내여행 일정 설계',
        '당신은 이동 편의 중심 국내여행 플래너입니다.

아래 정보를 바탕으로 걷는 거리와 체력 부담을 줄인 국내여행 일정을 짜주세요.

[출발지]
{{departure}}

[여행 지역]
{{destination}}

[동행자 특성]
{{companion_condition}}

[여행 기간]
{{duration}}

[교통수단]
{{transport}}

[선호 분위기]
{{preferred_style}}

[꼭 필요한 편의]
{{required_facilities}}

조건:
- 경사, 계단, 긴 도보, 긴 대기 시간을 최소화할 것
- 화장실, 주차, 엘리베이터, 실내 휴식 공간, 식사 접근성을 고려할 것
- 이동 구간마다 쉬는 포인트를 함께 제안할 것
- 무리하게 많은 장소를 넣지 말고 만족도 중심으로 구성할 것
- 마지막에 ''이 일정에서 현장 확인이 꼭 필요한 부분''을 정리할 것',
        0,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_0;

    -- post_prompt[0] 변수 생성
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '여행 지역',
        '여행 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'companion_condition',
        '동행자 특성',
        '부모님, 무릎 불편, 유모차, 임산부 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'duration',
        '여행 기간',
        '당일치기, 1박 2일 등을 선택하세요',
        'select',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transport',
        '교통수단',
        '자차, KTX, 대중교통 등을 선택하세요',
        'select',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'preferred_style',
        '선호 분위기',
        '바다, 온천, 조용한 산책, 전망 좋은 카페 등 입력하세요',
        'textarea',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'required_facilities',
        '필수 편의',
        '엘리베이터, 주차, 수유실, 휠체어 접근 등 입력하세요',
        'textarea',
        6,
        NOW()
    );

    -- post_prompt[1]: 현장 편의시설 확인 질문 리스트 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '현장 편의시설 확인 질문 리스트 만들기',
        '부모님 또는 이동약자와 국내여행 갈 때 관광지, 숙소, 식당에 미리 확인하면 좋은 질문 리스트를 만들어주세요.

조건:
- 주차, 계단, 경사, 화장실, 엘리베이터, 대기, 좌석, 실내 휴식 공간, 유모차/휠체어 가능 여부를 포함할 것
- 관광지 / 숙소 / 식당으로 구분할 것
- 전화나 메시지로 바로 물어볼 수 있는 문장형으로 작성할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 부모님·이동약자 동행 국내여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
