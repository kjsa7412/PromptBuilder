-- ============================================================
-- Bulk Insert: 카톡·문자 답장 정리 프롬프트
-- Source: 2603081103_work.json
-- Generated: 2026-03-08T14:04:39.779Z
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
        '카톡·문자 답장 정리 프롬프트',
        '상황에 맞는 공손한 답장, 정중한 거절, 자연스러운 후속 메시지를 빠르게 만드는 일상용 프롬프트 모음입니다.',
        '{"일상","문자답장","카카오톡","대화","커뮤니케이션"}'::text[],
        'public',
        '## 소개

일상에서 가장 자주 반복되는 일 중 하나는 메시지 답장 작성입니다. 이 게시물은 카카오톡, 문자, 메신저 답장을 빠르게 정리할 수 있도록 구성되어 있습니다.

먼저 답장 초안을 만들고,

[[PROMPT:0]]

필요하면 더 짧거나 더 부드러운 버전으로 다듬을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 상황 맞춤 답장 초안 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '상황 맞춤 답장 초안 만들기',
        '당신은 일상 커뮤니케이션 도우미입니다.

아래 상황에 맞는 답장 메시지를 작성해주세요.

[상황]
{{situation}}

[상대방과의 관계]
{{relationship}}

[내가 전달하고 싶은 핵심]
{{intent}}

[원하는 톤]
{{tone}}

조건:
- 실제로 바로 보낼 수 있는 자연스러운 한국어로 작성할 것
- 너무 과장되거나 어색하지 않게 작성할 것
- 답장 3개 버전으로 제시할 것',
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
        'situation',
        '상황',
        '어떤 메시지에 답장해야 하는지 상황을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'relationship',
        '상대와의 관계',
        '친구, 직장동료, 상사, 가족 등 관계를 입력하세요',
        'select',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'intent',
        '전달 핵심',
        '수락, 거절, 사과, 일정조율 등 핵심 의도를 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'tone',
        '답장 톤',
        '답장의 말투를 선택하세요',
        'select',
        3,
        NOW()
    );

    -- post_prompt[1]: 답장 문장 다듬기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '답장 문장 다듬기',
        '아래 문장을 {{style}} 느낌으로 다듬어주세요.

[원문]
{{original_text}}

조건:
- 의미는 유지할 것
- 너무 딱딱하거나 과하지 않게 수정할 것
- 3가지 버전으로 보여줄 것',
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
        'style',
        '다듬는 방식',
        '원하는 문장 스타일을 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'original_text',
        '원문',
        '내가 쓴 답장 초안을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 카톡·문자 답장 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 회의·통화 메모 정리 프롬프트
-- Source: 2603081103_work.json
-- Generated: 2026-03-08T14:04:39.780Z
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
        '회의·통화 메모 정리 프롬프트',
        '흩어진 메모나 대충 적어둔 대화를 보기 좋은 요약, 할 일 목록, 회의록 형태로 바꾸는 프롬프트입니다.',
        '{"정리","회의록","통화메모","업무","요약"}'::text[],
        'public',
        '## 소개

급하게 적은 메모는 나중에 보면 알아보기 어려운 경우가 많습니다. 이 게시물은 비정형 메모를 핵심 요약과 액션 아이템 중심으로 정리할 때 유용합니다.

먼저 전체 내용을 구조화하고,

[[PROMPT:0]]

이후 해야 할 일만 따로 추릴 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 비정형 메모를 깔끔한 요약으로 정리하기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '비정형 메모를 깔끔한 요약으로 정리하기',
        '당신은 메모 정리 도우미입니다.

아래의 비정형 메모를 읽고 {{format}} 형식으로 정리해주세요.

[메모 원문]
{{raw_notes}}

조건:
- 원문에 없는 내용은 추정하지 말 것
- 핵심 내용, 결정사항, 논의사항을 구분할 것
- 읽기 쉽게 한국어로 정리할 것',
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
        'format',
        '정리 형식',
        '원하는 결과 형식을 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'raw_notes',
        '메모 원문',
        '정리할 메모, 통화기록, 회의내용을 붙여넣으세요',
        'textarea',
        1,
        NOW()
    );

    -- post_prompt[1]: 메모에서 할 일만 추출하기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '메모에서 할 일만 추출하기',
        '아래 내용을 바탕으로 실행해야 할 일만 추출해주세요.

[원문]
{{content}}

조건:
- 해야 할 일만 목록으로 정리할 것
- 각 항목에 담당자와 기한이 명시되지 않으면 ''확인 필요''로 표시할 것
- 우선순위를 {{priority_style}} 기준으로 표시할 것',
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
        'content',
        '원문 내용',
        '회의/통화/메모 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'priority_style',
        '우선순위 표시 방식',
        '우선순위를 어떤 형식으로 표시할지 선택하세요',
        'select',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 회의·통화 메모 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 냉장고 재료 기반 식단 추천 프롬프트
-- Source: 2603081103_work.json
-- Generated: 2026-03-08T14:04:39.780Z
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
        '냉장고 재료 기반 식단 추천 프롬프트',
        '집에 있는 재료를 바탕으로 오늘 먹을 메뉴, 간단 레시피, 장보기 보완 항목까지 추천받는 생활형 프롬프트입니다.',
        '{"식단","요리","냉장고파먹기","장보기","생활"}'::text[],
        'public',
        '## 소개

집에 있는 재료로 무엇을 먹을지 고민될 때 유용한 프롬프트입니다. 재료를 입력하면 가능한 메뉴와 간단한 조리 방법을 추천받을 수 있습니다.

메뉴 추천은 아래 프롬프트를 사용하세요.

[[PROMPT:0]]

부족한 재료만 따로 뽑고 싶다면 아래 프롬프트를 사용하면 됩니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 보유 재료로 오늘 식단 추천받기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '보유 재료로 오늘 식단 추천받기',
        '당신은 실용적인 집밥 추천 도우미입니다.

아래 재료를 바탕으로 오늘 먹기 좋은 메뉴를 추천해주세요.

[보유 재료]
{{ingredients}}

[원하는 식사 종류]
{{meal_type}}

[조리 가능 시간]
{{cook_time}}

[선호 조건]
{{preferences}}

조건:
- 집에서 현실적으로 만들 수 있는 메뉴 위주로 제안할 것
- 메뉴 3개를 추천하고 각 메뉴별로 간단한 조리 순서를 적을 것
- 추가로 있으면 좋은 재료가 있다면 함께 적을 것',
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
        'ingredients',
        '보유 재료',
        '집에 있는 재료를 쉼표로 구분해서 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'meal_type',
        '식사 종류',
        '어떤 식사를 원하는지 선택하세요',
        'select',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'cook_time',
        '조리 시간',
        '조리에 쓸 수 있는 시간을 선택하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'preferences',
        '선호 조건',
        '매운맛 선호, 다이어트식, 아이와 함께 먹기 등 조건을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 부족한 장보기 목록만 추리기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '부족한 장보기 목록만 추리기',
        '아래 추천 메뉴 또는 식단 계획을 보고 부족한 재료만 장보기 목록으로 정리해주세요.

[기준 내용]
{{meal_plan}}

[집에 이미 있는 재료]
{{owned_items}}

조건:
- 이미 있는 재료는 제외할 것
- 겹치는 재료는 합칠 것
- 보기 쉽게 카테고리별로 정리할 것',
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
        'meal_plan',
        '식단 또는 추천 메뉴',
        '추천받은 메뉴 또는 직접 만든 식단 계획을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'owned_items',
        '보유 재료',
        '이미 집에 있는 재료를 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 냉장고 재료 기반 식단 추천 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 주말 일정 자동 추천 프롬프트
-- Source: 2603081103_work.json
-- Generated: 2026-03-08T14:04:39.780Z
-- ============================================================

DO $$
DECLARE
    v_prompt_id UUID;
    v_pp_id_0 UUID;
BEGIN

    -- 1. 게시물(prompt) 생성
    INSERT INTO prompts (
        id, user_id, title, description, tags, visibility, body_markdown,
        clip_count, like_count, generate_count, view_count, is_deleted,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        '118149df-a070-4a7e-8e0b-a20d35d88680'::uuid,
        '주말 일정 자동 추천 프롬프트',
        '시간, 예산, 이동거리, 동행자 조건을 입력하면 현실적인 주말 계획을 짜주는 반복 활용 프롬프트입니다.',
        '{"주말","일정","계획","외출","생활"}'::text[],
        'public',
        '## 소개

주말마다 무엇을 할지 고민된다면 이 프롬프트를 활용할 수 있습니다. 혼자, 가족과 함께, 연인과 함께 등 상황에 맞는 일정표를 빠르게 만들 수 있습니다.

[[PROMPT:0]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 조건 기반 주말 일정 짜기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '조건 기반 주말 일정 짜기',
        '당신은 현실적인 일정 플래너입니다.

아래 조건에 맞춰 {{duration}} 일정 계획을 짜주세요.

[지역 또는 출발지]
{{location}}

[함께하는 사람]
{{companions}}

[예산]
{{budget}}

[원하는 분위기]
{{mood}}

[추가 조건]
{{extra_conditions}}

조건:
- 무리하지 않는 동선으로 제안할 것
- 시간대별 일정표 형태로 정리할 것
- 식사, 휴식, 이동을 적절히 포함할 것
- 마지막에 대체안 1개도 함께 제안할 것',
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
        'duration',
        '일정 길이',
        '반나절, 하루, 1박2일 등 일정 길이를 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'location',
        '지역 또는 출발지',
        '어디를 기준으로 계획할지 입력하세요',
        'text',
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
        '혼자, 친구, 연인, 아이와 함께 등 선택하세요',
        'select',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'budget',
        '예산',
        '총 예산 수준을 입력하세요',
        'select',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'mood',
        '원하는 분위기',
        '쉬는 느낌, 액티비티, 맛집 중심 등 선택하세요',
        'select',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'extra_conditions',
        '추가 조건',
        '차량 없음, 실내 위주, 너무 붐비지 않게 등 추가 조건을 입력하세요',
        'textarea',
        5,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 주말 일정 자동 추천 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 가계부·소비내역 점검 프롬프트
-- Source: 2603081103_work.json
-- Generated: 2026-03-08T14:04:39.780Z
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
        '가계부·소비내역 점검 프롬프트',
        '소비내역을 붙여 넣으면 지출 분류, 과소비 포인트, 절약 아이디어를 정리해주는 실생활 관리형 프롬프트입니다.',
        '{"가계부","지출관리","소비분석","절약","생활관리"}'::text[],
        'public',
        '## 소개

반복적으로 쓰기 좋은 생활 관리 프롬프트입니다. 카드 사용내역이나 가계부 기록을 바탕으로 소비 패턴을 정리하고 절약 포인트를 찾는 데 활용할 수 있습니다.

먼저 전체 소비를 분석하고,

[[PROMPT:0]]

다음으로 줄일 수 있는 항목을 따로 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 소비내역 분석 및 카테고리 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '소비내역 분석 및 카테고리 정리',
        '당신은 가계부 분석 도우미입니다.

아래 소비내역을 분석해주세요.

[소비내역]
{{expense_list}}

[분석 기간]
{{period}}

조건:
- 소비내역을 주요 카테고리로 분류할 것
- 많이 지출된 항목 순으로 정리할 것
- 한눈에 보이게 요약할 것
- 마지막에 소비 패턴 한줄 진단을 적을 것',
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
        'expense_list',
        '소비내역',
        '카드내역, 계좌내역, 가계부 내용을 붙여넣으세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'period',
        '분석 기간',
        '이번 주, 이번 달, 지난달 등 기간을 입력하세요',
        'select',
        1,
        NOW()
    );

    -- post_prompt[1]: 절약 포인트 찾기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '절약 포인트 찾기',
        '아래 소비 분석 결과를 바탕으로 현실적인 절약 포인트를 찾아주세요.

[분석 결과]
{{analysis_result}}

[절약 목표]
{{saving_goal}}

조건:
- 무리한 절약이 아닌 현실적인 제안을 할 것
- 바로 실천 가능한 항목부터 제안할 것
- 예상 절감 효과를 함께 적을 것',
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
        'analysis_result',
        '분석 결과',
        '앞 단계에서 정리된 소비 분석 결과를 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'saving_goal',
        '절약 목표',
        '월 10만원 절약 등 목표를 입력하세요',
        'text',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 가계부·소비내역 점검 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
