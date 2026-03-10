-- ============================================================
-- Bulk Insert: 아이 수면 루틴 정리 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.956Z
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
        '아이 수면 루틴 정리 프롬프트',
        '잠투정, 밤중 각성, 늦은 취침처럼 반복되는 수면 문제를 일상 루틴 관점에서 정리하고 저녁 루틴을 설계하는 육아 프롬프트입니다.',
        '{"육아","수면","잠투정","루틴","생활습관"}'::text[],
        'public',
        '## 소개

아이 수면은 육아에서 가장 반복적으로 부딪히는 주제 중 하나입니다. 이 게시물은 의료 진단이 아니라, 현재 생활패턴을 정리하고 실천 가능한 저녁 루틴을 만드는 데 초점을 둡니다.

먼저 현재 상황을 바탕으로 루틴을 설계하고,

[[PROMPT:0]]

필요하면 최근 수면 기록을 붙여 넣어 패턴을 읽기 쉽게 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 저녁 수면 루틴 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 저녁 수면 루틴 설계',
        '당신은 육아 루틴 정리 도우미입니다.

아래 정보를 바탕으로 아이의 저녁 수면 루틴을 현실적으로 설계해주세요.

[아이 나이]
{{age}}

[현재 수면 문제]
{{sleep_issue}}

[현재 생활 패턴]
{{current_routine}}

[부모가 지킬 수 있는 조건]
{{parent_limit}}

조건:
- 이상적인 답이 아니라 실제로 지킬 수 있는 루틴으로 작성할 것
- 취침 90분 전부터 단계별로 정리할 것
- 부모가 아이에게 말할 짧은 멘트도 함께 제안할 것
- 무리한 방법은 제외할 것',
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
        'age',
        '아이 나이',
        '개월 수 또는 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'sleep_issue',
        '현재 수면 문제',
        '잠투정, 늦게 잠듦, 자주 깸 등 현재 문제를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'current_routine',
        '현재 생활 패턴',
        '기상, 낮잠, 저녁 식사, 목욕, 스크린 사용 등을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'parent_limit',
        '부모 조건',
        '몇 시까지 가능, 혼자 재워야 함 등 현실 조건을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 최근 수면 기록 요약 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '최근 수면 기록 요약 정리',
        '아래에 붙여 넣는 최근 수면 기록을 읽고 반복되는 패턴을 정리해주세요.

정리 기준:
- 잠드는 시간
- 밤중 각성 시간대
- 낮잠과 밤잠의 연결성
- 부모가 바로 손댈 수 있는 작은 조정 포인트

조건:
- 의학적 진단처럼 말하지 말 것
- 관찰 가능한 패턴 중심으로만 정리할 것
- 마지막에 오늘부터 해볼 수 있는 3가지를 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 아이 수면 루틴 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 떼쓰기·감정폭발 대응 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.965Z
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
        '떼쓰기·감정폭발 대응 프롬프트',
        '떼쓰기, 소리 지르기, 울면서 버티기 같은 상황에서 부모가 즉시 사용할 말과 사후 대화 멘트를 정리하는 실전형 육아 프롬프트입니다.',
        '{"육아","떼쓰기","감정조절","훈육","대화"}'::text[],
        'public',
        '## 소개

아이의 떼쓰기와 감정폭발은 부모를 지치게 만드는 대표적인 반복 상황입니다. 이 게시물은 상황 중 즉시 대응하는 말과, 진정 후 관계를 회복하는 대화까지 함께 정리할 수 있게 구성했습니다.

먼저 상황 대응 멘트를 만들고,

[[PROMPT:0]]

필요하면 상황이 끝난 뒤 사용할 사후 대화 문장도 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 떼쓰기 상황 즉시 대응 멘트 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '떼쓰기 상황 즉시 대응 멘트 만들기',
        '당신은 차분하고 일관된 육아 대화 코치입니다.

아래 상황에서 부모가 바로 사용할 수 있는 짧은 대응 멘트를 만들어주세요.

[아이 나이]
{{age}}

[문제가 된 상황]
{{situation}}

[아이가 보인 행동]
{{behavior}}

[부모가 지키고 싶은 원칙]
{{boundary}}

조건:
- 부모가 바로 입 밖으로 낼 수 있는 짧은 문장 위주로 작성할 것
- 감정 공감 + 한계 설정 + 다음 행동 제안 순서로 구성할 것
- 너무 훈계조이거나 비난하는 표현은 빼고 작성할 것
- 집 버전과 외출 중 버전으로 나눠 제시할 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'situation',
        '상황',
        '장난감 사달라 떼씀, 씻기 싫어함 등 상황을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'behavior',
        '아이 행동',
        '울기, 드러눕기, 소리 지르기, 때리기 등 행동을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'boundary',
        '부모 원칙',
        '안 되는 것은 안 됨, 때리면 멈춤 등 원칙을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 진정 후 사후 대화 문장 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '진정 후 사후 대화 문장 만들기',
        '아래 상황이 지나간 뒤 아이와 다시 이야기할 때 쓸 문장을 만들어주세요.

[상황 요약]
{{after_situation}}

[부모가 전하고 싶은 메시지]
{{parent_message}}

조건:
- 길지 않고 아이가 이해할 수 있는 문장으로 작성할 것
- 감정 이름 붙이기, 행동 한계, 다음번 대안 제시를 포함할 것
- 아이에게 수치심을 주는 표현은 제외할 것',
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
        'after_situation',
        '상황 요약',
        '무슨 일이 있었는지 짧게 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'parent_message',
        '전하고 싶은 메시지',
        '기다리기, 말로 표현하기 등 가르치고 싶은 점을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 떼쓰기·감정폭발 대응 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 편식·식사 스트레스 대응 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.966Z
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
        '편식·식사 스트레스 대응 프롬프트',
        '편식, 한두 가지만 먹음, 식탁 거부처럼 반복되는 식사 스트레스를 줄이기 위해 식단 노출과 부모 멘트를 정리하는 육아 프롬프트입니다.',
        '{"육아","편식","식사","식단","생활습관"}'::text[],
        'public',
        '## 소개

편식은 부모가 매일 마주치는 대표적인 육아 스트레스입니다. 이 게시물은 억지로 먹이는 방식이 아니라, 현재 먹는 음식과 거부 패턴을 바탕으로 노출 계획과 식탁 대화를 정리하는 데 중점을 둡니다.

먼저 식사 계획을 만들고,

[[PROMPT:0]]

필요하면 식탁에서 바로 쓸 수 있는 짧은 문장도 얻을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 편식 아이를 위한 현실적인 식사 노출 계획
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '편식 아이를 위한 현실적인 식사 노출 계획',
        '당신은 현실적인 육아 식사 루틴 도우미입니다.

아래 정보를 바탕으로 아이의 편식을 줄이기 위한 7일 식사 노출 계획을 짜주세요.

[아이 나이]
{{age}}

[잘 먹는 음식]
{{safe_foods}}

[거부하는 음식]
{{avoid_foods}}

[식사 때 주로 생기는 문제]
{{meal_issue}}

[가정의 현실 조건]
{{home_condition}}

조건:
- 새로운 음식만 밀어붙이지 말고 익숙한 음식과 함께 배치할 것
- 부모가 실천할 수 있는 수준으로 작성할 것
- 식사 때의 목표를 ''많이 먹이기''가 아니라 ''부담 없는 노출'' 중심으로 둘 것
- 하루마다 부모가 해볼 한 가지 행동을 적을 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'safe_foods',
        '잘 먹는 음식',
        '아이가 비교적 잘 먹는 음식을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'avoid_foods',
        '거부하는 음식',
        '거부하거나 뱉는 음식들을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'meal_issue',
        '식사 문제',
        '입에 안 넣음, 오래 물고 있음, 앉아있지 않음 등 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'home_condition',
        '가정 조건',
        '아침은 바쁨, 저녁만 함께 먹음 등 조건을 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 식탁에서 쓰는 짧은 부모 문장 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '식탁에서 쓰는 짧은 부모 문장 만들기',
        '편식하는 아이와 식사할 때 부모가 사용할 짧은 문장을 20개 만들어주세요.

조건:
- 억지, 협박, 거래처럼 들리지 않을 것
- 한 입 먹어봐를 반복하는 표현 대신 부담을 줄이는 말로 구성할 것
- 공감 문장, 경계 문장, 선택 제안 문장으로 나눠서 작성할 것
- 실제 식탁에서 바로 말할 수 있는 짧은 문장으로 만들 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 편식·식사 스트레스 대응 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 배변훈련·실수 대응 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.966Z
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
        '배변훈련·실수 대응 프롬프트',
        '배변훈련 시작 시점, 실수 반복, 다시 기저귀 찾기 같은 상황에서 부모가 천천히 진행할 수 있는 계획을 만드는 육아 프롬프트입니다.',
        '{"육아","배변훈련","기저귀","생활훈련","습관형성"}'::text[],
        'public',
        '## 소개

배변훈련은 아이의 속도와 감정 상태에 크게 영향을 받는 주제입니다. 이 게시물은 조급하게 밀어붙이기보다 현재 상태를 정리하고 현실적인 진행 계획을 세우는 데 맞춰져 있습니다.

먼저 시작 또는 재시도 계획을 만들고,

[[PROMPT:0]]

배변 실수나 퇴행이 있을 때는 대응 문장과 체크 포인트를 따로 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 배변훈련 시작 또는 재시도 계획 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '배변훈련 시작 또는 재시도 계획 만들기',
        '당신은 육아 루틴 정리 도우미입니다.

아래 상황을 바탕으로 배변훈련 계획을 짜주세요.

[아이 나이]
{{age}}

[현재 상태]
{{current_status}}

[부모가 걱정하는 점]
{{concern}}

[가정/기관 환경]
{{environment}}

조건:
- 아이를 압박하는 방식은 제외할 것
- 하루 루틴에 어떻게 넣을지 구체적으로 제시할 것
- 부모가 사용할 짧은 말도 함께 제안할 것
- 실수가 났을 때 어떻게 반응할지 포함할 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'current_status',
        '현재 상태',
        '변기에 관심 있음, 앉기 싫어함, 낮에는 성공 등 상태를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'concern',
        '걱정하는 점',
        '실수 잦음, 변기 무서워함, 어린이집 적응 중 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'environment',
        '환경',
        '집, 어린이집, 외출 상황 등 환경을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 실수·퇴행 상황 대응 멘트와 체크포인트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '실수·퇴행 상황 대응 멘트와 체크포인트',
        '아래 상황에서 부모가 사용할 반응 문장과 체크포인트를 정리해주세요.

[상황 설명]
{{regression_case}}

조건:
- 아이를 부끄럽게 하거나 혼내는 표현은 제외할 것
- 지금 당장 점검할 것, 며칠 관찰할 것, 기관과 공유할 것을 나눠서 적을 것
- 부모 멘트는 아주 짧게 제시할 것',
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
        'regression_case',
        '상황 설명',
        '실수 반복, 다시 기저귀 찾음, 변기 거부 등 상황을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 배변훈련·실수 대응 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 스크린타임 규칙표 만들기 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.966Z
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
        '스크린타임 규칙표 만들기 프롬프트',
        '영상 끄기 전쟁, 식사 중 기기 사용, 잠들기 전 화면 노출처럼 반복되는 문제를 줄이기 위해 가정 규칙과 전환 멘트를 만드는 프롬프트입니다.',
        '{"육아","스크린타임","미디어","규칙","생활습관"}'::text[],
        'public',
        '## 소개

스크린 사용은 많은 가정에서 갈등이 생기기 쉬운 주제입니다. 이 게시물은 무조건 금지보다, 집에서 지킬 수 있는 규칙과 종료 전환 문장을 만드는 데 초점을 둡니다.

먼저 우리 집 규칙표를 만들고,

[[PROMPT:0]]

필요하면 기기 종료 직전 사용할 멘트와 대체 활동도 함께 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 우리 집 스크린타임 규칙표 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '우리 집 스크린타임 규칙표 만들기',
        '당신은 가족 루틴 정리 도우미입니다.

아래 상황을 바탕으로 우리 집 스크린타임 규칙표를 만들어주세요.

[아이 나이]
{{age}}

[현재 사용 패턴]
{{current_pattern}}

[가장 자주 문제 되는 상황]
{{problem_scene}}

[부모가 허용 가능한 기준]
{{family_rule}}

조건:
- 완벽한 규칙이 아니라 실제로 지킬 수 있는 규칙으로 작성할 것
- 사용 가능 시간, 사용 불가 시간, 예외 상황, 종료 절차를 나눠서 작성할 것
- 부모가 아이에게 설명할 짧은 문장도 함께 적을 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'current_pattern',
        '현재 사용 패턴',
        '언제 얼마나 보는지 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'problem_scene',
        '문제 상황',
        '끄라 하면 울음, 식사 중 요구, 자기 전 사용 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'family_rule',
        '가정 기준',
        '평일 제한, 주말 허용, 식탁 금지 등 원하는 기준을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 영상 종료 전환 멘트와 대체 활동 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '영상 종료 전환 멘트와 대체 활동 만들기',
        '아이에게 영상을 끄자고 할 때 바로 쓸 수 있는 전환 멘트 15개와, 이후 바로 이어서 할 짧은 대체 활동 15개를 만들어주세요.

조건:
- 멘트는 짧고 예측 가능하게 작성할 것
- 협박하거나 기기 빼앗는 느낌의 표현은 제외할 것
- 대체 활동은 준비물이 거의 없고 5~15분 안에 가능한 것으로 제안할 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 스크린타임 규칙표 만들기 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 연령별 놀이·집콕놀이 아이디어 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.967Z
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
        '연령별 놀이·집콕놀이 아이디어 프롬프트',
        '아이 나이와 현재 관심사를 바탕으로 집에서 바로 할 수 있는 놀이, 책, 말걸기 아이디어를 만드는 프롬프트입니다.',
        '{"육아","놀이","발달","집콕","활동"}'::text[],
        'public',
        '## 소개

놀이 아이디어는 매일 새로 떠올리기 어렵습니다. 이 게시물은 아이 나이와 관심사를 바탕으로 집에서 당장 가능한 놀이를 고를 수 있게 구성했습니다.

먼저 맞춤 놀이를 추천받고,

[[PROMPT:0]]

준비물이 거의 없는 놀이만 따로 뽑고 싶다면 아래 프롬프트를 사용할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 나이와 관심사에 맞는 놀이 추천
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 나이와 관심사에 맞는 놀이 추천',
        '당신은 가정 놀이 아이디어 도우미입니다.

아래 정보를 바탕으로 아이와 할 수 있는 놀이 12가지를 추천해주세요.

[아이 나이]
{{age}}

[요즘 관심사]
{{interest}}

[현재 발달 또는 성향]
{{temperament}}

[가능한 공간]
{{space}}

[가능한 시간]
{{time_limit}}

조건:
- 집에서 바로 할 수 있는 활동 위주로 제안할 것
- 준비물, 진행 방법, 기대되는 놀이 포인트를 함께 적을 것
- 너무 과한 준비가 필요한 놀이는 제외할 것
- 조용한 놀이와 에너지 쓰는 놀이를 섞어서 제안할 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'interest',
        '관심사',
        '자동차, 공룡, 그림, 노래 등 관심사를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'temperament',
        '성향/발달 특징',
        '움직임 많음, 금방 싫증냄, 말놀이 좋아함 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'space',
        '가능한 공간',
        '거실, 식탁, 욕실 놀이 가능 여부 등을 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'time_limit',
        '가능 시간',
        '10분, 20분 등 가능한 시간을 입력하세요',
        'text',
        4,
        NOW()
    );

    -- post_prompt[1]: 준비물 거의 없는 10분 놀이만 모아보기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '준비물 거의 없는 10분 놀이만 모아보기',
        '집에 흔히 있는 물건만 써서 할 수 있는 10분 놀이 20가지를 추천해주세요.

조건:
- 종이, 컵, 수건, 스티커, 블록, 책처럼 흔한 물건만 사용할 것
- 아이가 지루해지기 전 끝낼 수 있는 길이로 구성할 것
- 말놀이, 몸놀이, 감각놀이, 정리놀이를 골고루 섞을 것
- 부모가 바로 시작할 수 있게 첫 멘트도 함께 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 연령별 놀이·집콕놀이 아이디어 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 분리불안·등원 적응 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.967Z
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
        '분리불안·등원 적응 프롬프트',
        '어린이집·유치원 등원 거부, 엄마아빠와 떨어지기 힘들어함, 아침마다 우는 상황에서 준비 루틴과 짧은 작별 멘트를 만드는 프롬프트입니다.',
        '{"육아","분리불안","등원","적응","불안"}'::text[],
        'public',
        '## 소개

분리불안과 등원 적응은 많은 아이와 부모가 겪는 반복적인 스트레스입니다. 이 게시물은 불안을 완전히 없애기보다, 예측 가능한 준비 루틴과 짧은 작별 절차를 만드는 데 초점을 둡니다.

먼저 아침 준비 루틴을 만들고,

[[PROMPT:0]]

필요하면 교사에게 상황을 공유하는 메시지 초안도 함께 만들 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 등원 전 준비 루틴과 작별 절차 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '등원 전 준비 루틴과 작별 절차 만들기',
        '당신은 육아 루틴 정리 도우미입니다.

아래 상황을 바탕으로 아이의 등원 전 준비 루틴과 짧은 작별 절차를 만들어주세요.

[아이 나이]
{{age}}

[현재 어려움]
{{difficulty}}

[특히 힘든 시간대]
{{hard_time}}

[부모가 할 수 있는 범위]
{{parent_capacity}}

조건:
- 아침 준비, 이동, 작별 순간, 하원 후 연결 루틴까지 포함할 것
- 작별 인사는 짧고 예측 가능하게 만들 것
- 아이가 붙잡을 수 있는 안정 문장과 부모 멘트를 각각 제안할 것
- 억지로 떼어놓는 방식이 아니라 준비 중심으로 작성할 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'difficulty',
        '현재 어려움',
        '문 앞에서 움, 안 들어감, 밤부터 걱정함 등 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'hard_time',
        '힘든 시간대',
        '준비 시작, 차 안, 교실 앞 등 특히 힘든 순간을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'parent_capacity',
        '부모 가능 범위',
        '출근 시간, 동행 가능 여부 등 현실 조건을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 교사에게 공유할 적응 상황 메시지 초안
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '교사에게 공유할 적응 상황 메시지 초안',
        '아래 상황을 바탕으로 어린이집/유치원 교사에게 보낼 메시지 초안을 작성해주세요.

[아이 상황]
{{child_status}}

[부모가 공유하고 싶은 점]
{{share_point}}

[도움 받고 싶은 부분]
{{request_help}}

조건:
- 예의 바르고 짧게 작성할 것
- 아이를 부정적으로 낙인찍는 표현은 쓰지 말 것
- 현재 상황, 요청사항, 감사 표현 순서로 정리할 것',
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
        'child_status',
        '아이 상황',
        '등원 시 반응, 최근 변화 등을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'share_point',
        '공유 내용',
        '최근 잠 부족, 집에서도 불안 등 공유할 점을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'request_help',
        '부탁할 점',
        '도착 직후 안아주기, 짧은 인사 유도 등 요청을 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 분리불안·등원 적응 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 아이 상태 기록·병원 질문 정리 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.967Z
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
        '아이 상태 기록·병원 질문 정리 프롬프트',
        '열, 기침, 구토, 설사, 처짐 등 아이가 아플 때 증상을 시간순으로 정리하고 병원에 물어볼 질문을 준비하는 안전형 프롬프트입니다.',
        '{"육아","건강기록","증상정리","병원질문","안전"}'::text[],
        'public',
        '## 소개

아이가 아프면 부모는 당황하기 쉽고, 병원이나 상담 시 핵심 정보를 빠뜨리기 쉽습니다. 이 게시물은 진단을 대신하는 것이 아니라, 현재 상태를 시간순으로 정리하고 질문 목록을 만드는 데 맞춰져 있습니다.

먼저 증상 기록을 정리하고,

[[PROMPT:0]]

그 다음 병원이나 상담 시 물어볼 질문을 준비할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 증상 기록 시간순 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 증상 기록 시간순 정리',
        '당신은 보호자 기록 정리 도우미입니다.

아래 아이 상태 기록을 시간순으로 정리해주세요.

[아이 나이]
{{age}}

[현재 증상]
{{symptoms}}

[증상 시작 시점과 경과]
{{timeline}}

[먹고 마신 양 / 소변 / 수면 / 약 복용]
{{intake_info}}

조건:
- 절대 진단하지 말 것
- 병원이나 상담 시 전달하기 쉬운 형식으로 정리할 것
- 보호자가 추가로 관찰하면 좋은 항목을 적을 것
- 마지막에 ''지금 바로 의료진에게 설명할 핵심 5줄''을 따로 적을 것',
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
        'age',
        '아이 나이',
        '개월 수 또는 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'symptoms',
        '현재 증상',
        '열, 기침, 콧물, 구토, 설사 등 증상을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'timeline',
        '시간 경과',
        '언제 시작됐고 어떻게 변했는지 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'intake_info',
        '먹고 마신 정보',
        '수분 섭취, 식사량, 소변 횟수, 해열제 복용 등을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 병원에 물어볼 질문 목록 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '병원에 물어볼 질문 목록 정리',
        '아래 상태를 바탕으로 보호자가 병원 또는 상담 시 물어보면 좋은 질문 목록을 만들어주세요.

[아이 상태 요약]
{{status_summary}}

조건:
- 진단이나 처방을 대신하지 말 것
- 보호자가 놓치기 쉬운 질문을 포함할 것
- 지금 당장 물어볼 것, 집에서 관찰하며 물어볼 것을 나눠서 정리할 것',
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
        'status_summary',
        '상태 요약',
        '현재 아이 상태를 요약해서 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 아이 상태 기록·병원 질문 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 어린이집·유치원·학교 연락 문안 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.967Z
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
        '어린이집·유치원·학교 연락 문안 프롬프트',
        '결석, 지각, 준비물, 상담 요청, 약 복용 안내처럼 부모가 자주 보내는 연락 문안을 빠르게 정리하는 육아 프롬프트입니다.',
        '{"육아","연락장","어린이집","유치원","학교"}'::text[],
        'public',
        '## 소개

기관과의 연락은 짧지만 정확해야 하고, 예의를 갖추는 것도 중요합니다. 이 게시물은 부모가 자주 보내는 연락 유형을 빠르게 정리할 수 있게 만들었습니다.

먼저 상황에 맞는 연락 문안을 만들고,

[[PROMPT:0]]

상담 후에는 공유용 요약 메시지로 정리할 수도 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 기관 연락 문안 빠르게 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '기관 연락 문안 빠르게 작성',
        '당신은 보호자 연락 문안 작성 도우미입니다.

아래 정보를 바탕으로 어린이집/유치원/학교에 보낼 메시지를 작성해주세요.

[연락 유형]
{{message_type}}

[상황 설명]
{{situation}}

[반드시 포함할 내용]
{{must_include}}

[원하는 톤]
{{tone}}

조건:
- 짧고 예의 바르게 작성할 것
- 상대가 바로 이해할 수 있게 핵심만 담을 것
- 메신저용과 알림장용 2가지 버전으로 제시할 것',
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
        'message_type',
        '연락 유형',
        '결석, 지각, 상담 요청, 준비물 문의, 약 안내 등을 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'situation',
        '상황',
        '현재 상황을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'must_include',
        '필수 내용',
        '시간, 사유, 부탁할 점 등 꼭 넣을 내용을 입력하세요',
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
        '문체',
        '원하는 문체를 선택하세요',
        'select',
        3,
        NOW()
    );

    -- post_prompt[1]: 상담 후 배우자·가족 공유용 요약 메시지
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '상담 후 배우자·가족 공유용 요약 메시지',
        '아래 상담 또는 교사와의 대화 내용을 바탕으로 배우자나 가족에게 공유할 짧은 요약 메시지를 작성해주세요.

[상담 내용]
{{consult_notes}}

조건:
- 핵심만 짧게 정리할 것
- 아이 상태, 교사 의견, 집에서 해볼 것 3가지로 나눌 것
- 감정적 표현보다 사실 중심으로 작성할 것',
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
        'consult_notes',
        '상담 내용',
        '상담 메모나 통화 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 어린이집·유치원·학교 연락 문안 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 외출·여행·병원 방문 준비 체크리스트 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.968Z
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
        '외출·여행·병원 방문 준비 체크리스트 프롬프트',
        '아이와 외출할 때마다 빠뜨리기 쉬운 준비물을 상황별 체크리스트로 정리하는 실전형 육아 프롬프트입니다.',
        '{"육아","외출","여행","준비물","체크리스트"}'::text[],
        'public',
        '## 소개

아이와의 외출은 준비물 누락이 곧 스트레스로 이어지기 쉽습니다. 이 게시물은 목적지와 시간, 나이에 맞게 필요한 것만 뽑아주는 체크리스트용 프롬프트입니다.

먼저 맞춤 준비물을 정리하고,

[[PROMPT:0]]

바로 복붙해서 쓸 수 있는 당일 아침 확인표도 만들 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 상황별 외출 준비물 체크리스트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '상황별 외출 준비물 체크리스트',
        '당신은 육아 준비물 체크리스트 도우미입니다.

아래 상황을 바탕으로 준비물 체크리스트를 만들어주세요.

[아이 나이]
{{age}}

[외출 목적]
{{outing_type}}

[외출 시간]
{{duration}}

[이동 수단]
{{transport}}

[날씨/특이사항]
{{extra_condition}}

조건:
- 꼭 필요한 것, 있으면 좋은 것, 상황별 선택 준비물로 나눌 것
- 너무 과하게 챙기지 않게 현실적으로 정리할 것
- 마지막에 ''문 나가기 직전 10초 점검표''도 따로 적을 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'outing_type',
        '외출 목적',
        '병원, 장보기, 공원, 여행, 친정 방문 등을 입력하세요',
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
        '외출 시간',
        '1시간, 반나절, 1박2일 등 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transport',
        '이동 수단',
        '도보, 자차, 대중교통 등을 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'extra_condition',
        '특이사항',
        '비 예보, 낮잠 시간 겹침, 약 복용 중 등을 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 당일 아침용 짧은 체크 문구 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '당일 아침용 짧은 체크 문구 만들기',
        '아이와 외출하기 전 부모가 빠르게 확인할 수 있는 한 줄 체크 문구 15개를 만들어주세요.

조건:
- 짧고 리듬감 있게 작성할 것
- 기저귀/여벌옷/물/간식/휴지/휴대폰 등 자주 빠뜨리는 항목을 포함할 것
- 아이 나이에 따라 달라질 수 있는 항목은 괄호로 예시를 적을 것',
        1,
        'complete',
        NOW(), NOW()
    )
    RETURNING id INTO v_pp_id_1;

    RAISE NOTICE 'INSERT OK: 외출·여행·병원 방문 준비 체크리스트 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 발달 관찰 메모 정리 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.968Z
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
        '발달 관찰 메모 정리 프롬프트',
        '말, 놀이, 반응, 움직임 등 부모가 관찰한 내용을 정리하고 기관이나 전문가에게 물어볼 질문을 준비하는 육아 프롬프트입니다.',
        '{"육아","발달","관찰","메모","질문정리"}'::text[],
        'public',
        '## 소개

부모는 아이의 변화를 가장 자주 보지만, 막상 상담할 때는 기억이 흐려지기 쉽습니다. 이 게시물은 관찰 메모를 정리하고, 무엇을 질문하면 좋을지 준비하는 데 초점을 둡니다.

먼저 관찰 내용을 구조화하고,

[[PROMPT:0]]

필요하면 상담이나 진료 전 질문 리스트도 뽑을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 발달 관찰 메모 구조화
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 발달 관찰 메모 구조화',
        '당신은 보호자 관찰 메모 정리 도우미입니다.

아래 부모 관찰 내용을 읽고 항목별로 정리해주세요.

[아이 나이]
{{age}}

[관찰 메모]
{{observation_notes}}

조건:
- 말/이해, 놀이, 사회성/반응, 움직임, 생활습관으로 나눠 정리할 것
- 부모의 걱정 포인트와 단순 관찰 포인트를 구분할 것
- 단정적인 평가를 하지 말고 ''관찰된 사실'' 중심으로 정리할 것
- 마지막에 며칠 더 관찰하면 좋은 항목을 적을 것',
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
        'age',
        '아이 나이',
        '개월 수 또는 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'observation_notes',
        '관찰 메모',
        '평소 메모해둔 행동, 말, 놀이, 반응을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    -- post_prompt[1]: 상담 전 질문 리스트 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '상담 전 질문 리스트 만들기',
        '아래 관찰 내용을 바탕으로 기관 상담, 소아과, 발달 상담 등에서 물어보면 좋은 질문 목록을 만들어주세요.

[관찰 내용 요약]
{{summary}}

[상담 대상]
{{target}}

조건:
- 불안만 키우는 질문이 아니라 실제로 도움이 되는 질문으로 구성할 것
- 지금 바로 물어볼 것과 조금 더 지켜본 뒤 물어볼 것을 나눌 것
- 질문은 짧고 구체적으로 작성할 것',
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
        'summary',
        '관찰 내용 요약',
        '정리된 관찰 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'target',
        '상담 대상',
        '교사, 소아과, 상담센터 등 대상을 입력하세요',
        'text',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 발달 관찰 메모 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 가족 루틴·하루 일정표 설계 프롬프트
-- Source: 2603091325_work.json
-- Generated: 2026-03-10T04:45:01.969Z
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
        '가족 루틴·하루 일정표 설계 프롬프트',
        '등원, 식사, 낮잠, 놀이, 목욕, 취침까지 하루를 너무 빡빡하지 않게 정리해 부모와 아이 모두 덜 지치게 만드는 루틴 프롬프트입니다.',
        '{"육아","루틴","일정표","생활관리","가정운영"}'::text[],
        'public',
        '## 소개

육아는 아이만의 일정이 아니라 가족 전체의 흐름을 맞추는 일입니다. 이 게시물은 아이의 리듬과 부모의 현실을 함께 반영한 하루 일정표를 만드는 데 초점을 둡니다.

먼저 우리 집 일정표를 만들고,

[[PROMPT:0]]

필요하면 주중과 주말 버전으로 나눠 재구성할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이와 가족의 하루 루틴 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이와 가족의 하루 루틴 설계',
        '당신은 가족 루틴 설계 도우미입니다.

아래 정보를 바탕으로 아이와 부모 모두 덜 지치는 하루 루틴을 설계해주세요.

[아이 나이]
{{age}}

[현재 고정 일정]
{{fixed_schedule}}

[가장 자주 무너지는 시간대]
{{problem_time}}

[부모의 현실 조건]
{{parent_reality}}

조건:
- 이상적인 루틴이 아니라 실제 생활에 맞게 작성할 것
- 식사, 이동, 놀이, 낮잠, 정리, 취침 흐름을 포함할 것
- 완벽히 지키지 못했을 때 복구하는 방법도 함께 적을 것
- 부모가 서로 역할을 나누기 쉽게 정리할 것',
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
        'age',
        '아이 나이',
        '아이의 나이를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'fixed_schedule',
        '고정 일정',
        '등원, 하원, 부모 출근 등 고정 일정을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'problem_time',
        '무너지는 시간대',
        '아침 준비, 저녁 식사 전, 취침 전 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'parent_reality',
        '부모 현실 조건',
        '맞벌이, 혼자 돌봄, 저녁 늦음 등 현실 조건을 입력하세요',
        'textarea',
        3,
        NOW()
    );

    -- post_prompt[1]: 주중/주말 루틴 차이 조정하기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '주중/주말 루틴 차이 조정하기',
        '아래 현재 루틴을 바탕으로 주중 버전과 주말 버전으로 나눠 다시 설계해주세요.

[현재 루틴]
{{routine}}

조건:
- 주말이라고 완전히 무너지지 않도록 핵심 축은 유지할 것
- 늦잠, 외출, 가족 일정이 들어와도 무리 없는 형태로 조정할 것
- 반드시 지킬 3가지와 유연하게 바꿀 수 있는 3가지를 구분할 것',
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
        'routine',
        '현재 루틴',
        '현재 하루 루틴을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 가족 루틴·하루 일정표 설계 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
