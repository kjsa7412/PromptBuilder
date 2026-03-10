-- ============================================================
-- Bulk Insert: 해외여행 전체 일정 자동 설계 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.979Z
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
        '해외여행 전체 일정 자동 설계 프롬프트',
        '출발지, 여행지, 기간, 예산, 동행자, 스타일을 반영해 현실적인 해외여행 일정을 짜주는 핵심 프롬프트입니다.',
        '{"해외여행","여행","여행일정","자유여행","코스추천"}'::text[],
        'public',
        '## 소개

해외여행에서 가장 자주 필요한 것은 내 상황에 맞는 전체 일정입니다. 이 게시물은 예쁜 장소만 나열하는 것이 아니라 비행, 체크인, 식사, 이동, 휴식, 사진 포인트, 우천 대안까지 반영한 실행형 일정을 만드는 데 초점을 둡니다.

먼저 전체 일정을 설계하고,

[[PROMPT:0]]

이미 생각해둔 후보지가 있다면 실제 동선 기준으로 다시 다듬을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 해외여행 전체 일정 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '해외여행 전체 일정 설계',
        '당신은 해외여행 전문 플래너입니다.

아래 조건에 맞춰 해외여행 일정을 짜주세요.

[출발지]
{{departure}}

[여행지]
{{destination}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[여행 스타일]
{{travel_style}}

[예산]
{{budget}}

[중요 조건]
{{important_conditions}}

조건:
- 비행 도착일과 출국일의 피로도를 고려한 현실적인 일정으로 짤 것
- 관광, 식사, 카페, 쇼핑, 휴식의 균형을 맞출 것
- 하루에 너무 많은 장소를 억지로 넣지 말 것
- 각 장소마다 추천 이유를 한 줄씩 적을 것
- 우천 시 대체 코스와 체력 저하 시 축소 코스를 함께 제안할 것
- 마지막에 예약 우선순위가 높은 항목과 현지에서 유동적으로 조정 가능한 항목을 구분할 것',
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
        '출발 도시 또는 공항을 입력하세요',
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
        '여행지',
        '여행 국가 및 도시를 입력하세요',
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
        '3박 4일, 5박 6일 등 입력하세요',
        'text',
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
        '혼자, 친구, 연인, 가족 등 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '맛집, 쇼핑, 미술관, 야경, 휴양, 사진 등 원하는 스타일을 입력하세요',
        'textarea',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'budget',
        '예산',
        '총예산 또는 1인당 예산을 입력하세요',
        'text',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'important_conditions',
        '중요 조건',
        '걷는 거리 적게, 아침 약함, 쇼핑 많이, 유명지 필수 등 조건을 입력하세요',
        'textarea',
        6,
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
        '당신은 해외여행 동선 최적화 도우미입니다.

아래 후보지 목록을 실제 여행 일정으로 재구성해주세요.

[도시]
{{city}}

[후보지 목록]
{{candidate_places}}

[식사 취향]
{{food_preference}}

[이동 제약]
{{movement_limit}}

조건:
- 위치상 비효율적인 순서는 과감히 정리할 것
- 꼭 갈 만한 곳, 취향이면 좋은 곳, 빼도 되는 곳으로 나눌 것
- 동네별로 묶어서 하루 일정표 형태로 다시 배치할 것
- 웨이팅, 예약, 야경 시간대, 휴식 타이밍까지 고려할 것
- 마지막에 과한 부분과 무리 없는 수정안을 함께 제시할 것',
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
        'city',
        '도시',
        '여행 도시를 입력하세요',
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
        '가고 싶은 장소를 줄바꿈으로 입력하세요',
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
        '현지 음식, 카페, 브런치, 파인다이닝 등 입력하세요',
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
        '계단 약함, 장거리 도보 힘듦, 늦은 밤 이동 피함 등 입력하세요',
        'textarea',
        3,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 해외여행 전체 일정 자동 설계 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 여권·비자·입국서류 체크리스트 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '여권·비자·입국서류 체크리스트 프롬프트',
        '여권 유효기간, 입국 요건, 비자, 환승 요건, 건강 서류까지 빠뜨리기 쉬운 출국 전 체크리스트를 정리하는 프롬프트입니다.',
        '{"해외여행","여행","여권","비자","입국요건"}'::text[],
        'public',
        '## 소개

해외여행은 일정만 잘 짜도 되는 것이 아니라 출발 자체가 가능한지를 먼저 확인해야 합니다. 이 게시물은 여권, 비자, 환승, 건강 서류, 약 반입, 기본 준비를 빠짐없이 확인하는 데 적합합니다.

먼저 전체 체크리스트를 만들고,

[[PROMPT:0]]

복잡한 다구간 일정이라면 환승까지 포함해 다시 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 출국 전 서류 체크리스트 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '출국 전 서류 체크리스트 만들기',
        '당신은 해외여행 출국 준비 점검 도우미입니다.

아래 여정을 기준으로 출국 전에 반드시 확인해야 할 서류와 조건을 체크리스트로 정리해주세요.

[국적]
{{nationality}}

[출발지]
{{departure}}

[목적지]
{{destination}}

[경유지 또는 환승지]
{{transit}}

[여행 목적]
{{trip_purpose}}

[현재 내가 준비한 것]
{{current_preparation}}

조건:
- 여권 유효기간, 비자 또는 전자여행허가, 입국 신고 관련 준비, 환승 시 유의점, 건강 관련 서류 확인 필요 여부, 약 반입 확인 필요 여부를 포함할 것
- ''이미 준비함 / 지금 확인 필요 / 공식 사이트 재확인 필요''로 나눠서 정리할 것
- 실제 규정은 공식 사이트에서 최종 확인해야 한다는 전제로, 준비 항목을 구조적으로 정리할 것
- 마지막에 출발 7일 전, 3일 전, 출발 전날에 각각 확인할 항목을 나눠서 적을 것',
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
        'nationality',
        '국적',
        '본인 국적을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'departure',
        '출발지',
        '출발 국가와 도시를 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'destination',
        '목적지',
        '도착 국가와 도시를 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transit',
        '환승지',
        '환승 국가/도시가 있으면 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'trip_purpose',
        '여행 목적',
        '관광, 출장, 방문 등 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'current_preparation',
        '현재 준비 상태',
        '여권 있음, 비자 신청 안 함 등 현재 상태를 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 다구간 여정 서류 리스크 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '다구간 여정 서류 리스크 정리',
        '아래 다구간 해외여행 일정을 보고, 서류와 입국/환승 측면에서 놓치기 쉬운 위험 포인트를 정리해주세요.

[여정 전체]
{{itinerary}}

조건:
- 출발국, 환승국, 도착국별로 구분해서 정리할 것
- 여권, 비자, 전자허가, 환승, 수하물 연결, 재체크인 가능성, 약 반입 확인 포인트를 포함할 것
- 사실 단정이 아니라 ''확인해야 할 포인트'' 중심으로 작성할 것
- 마지막에 공식 사이트에서 반드시 다시 확인할 질문 목록을 적을 것',
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
        'itinerary',
        '여정 전체',
        '항공편과 도시 이동 순서를 자세히 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 여권·비자·입국서류 체크리스트 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 항공권·환승·공항 이동 플랜 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '항공권·환승·공항 이동 플랜 프롬프트',
        '비행편 선택, 환승 난이도, 공항에서 숙소까지 이동, 밤도착 리스크까지 포함한 항공 이동 계획 프롬프트입니다.',
        '{"해외여행","여행","항공권","환승","공항이동"}'::text[],
        'public',
        '## 소개

해외여행은 도시에 도착하는 순간보다 공항에 도착하는 순간부터 체력이 갈립니다. 이 게시물은 비행 스케줄, 환승 난이도, 공항 이동, 늦은 도착 리스크를 함께 보는 데 유용합니다.

먼저 이동 플랜을 짜고,

[[PROMPT:0]]

기존 항공권 후보가 있다면 체력과 일정 기준으로 비교할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 공항부터 숙소까지 이동 플랜 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '공항부터 숙소까지 이동 플랜 설계',
        '당신은 해외여행 항공 이동 플래너입니다.

아래 조건을 바탕으로 비행, 환승, 공항 도착 후 숙소까지의 이동 플랜을 짜주세요.

[출발 공항]
{{departure_airport}}

[도착 공항]
{{arrival_airport}}

[환승 여부]
{{transit_info}}

[도착 시간대]
{{arrival_time}}

[숙소 위치]
{{hotel_area}}

[동행자 및 짐 상황]
{{baggage_condition}}

조건:
- 환승 부담, 입국 심사, 수하물 찾기, 시차 적응, 야간 이동 리스크를 고려할 것
- 공항철도, 버스, 택시, 픽업 서비스 중 어떤 방식이 적합한지 비교할 것
- 밤 늦게 도착하는 경우와 낮 도착하는 경우를 나눠 안내할 것
- 숙소 체크인 시간과 연결되도록 조정할 것
- 마지막에 ''도착 당일 절대 무리하지 말아야 할 포인트''를 적을 것',
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
        'departure_airport',
        '출발 공항',
        '출발 공항을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'arrival_airport',
        '도착 공항',
        '도착 공항을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'transit_info',
        '환승 정보',
        '직항, 1회 환승, 환승 공항 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'arrival_time',
        '도착 시간대',
        '오전, 오후, 심야 등 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'hotel_area',
        '숙소 위치',
        '숙소 지역 또는 주소를 입력하세요',
        'text',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'baggage_condition',
        '짐 상황',
        '캐리어 큼, 유모차 있음, 아이 동반 등 입력하세요',
        'textarea',
        5,
        NOW()
    );

    -- post_prompt[1]: 항공권 후보 체력 기준 비교
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '항공권 후보 체력 기준 비교',
        '당신은 해외여행 항공권 비교 도우미입니다.

아래 항공권 후보를 보고 여행 만족도 기준으로 비교해주세요.

[여행지]
{{destination}}

[항공권 후보]
{{flight_candidates}}

[내 우선순위]
{{priority}}

조건:
- 가격만이 아니라 출발/도착 시간, 환승 길이, 체력 소모, 첫날 일정 영향, 마지막 날 피로도까지 고려할 것
- 꼭 좋은 선택 / 무난한 선택 / 피하고 싶은 선택으로 나눌 것
- 왜 그렇게 판단했는지 여행자 입장에서 설명할 것
- 마지막에 ''돈을 조금 더 써도 좋은 구간''과 ''절약해도 되는 구간''을 구분할 것',
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
        '여행지',
        '여행지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'flight_candidates',
        '항공권 후보',
        '비행편 후보를 붙여넣으세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'priority',
        '우선순위',
        '최저가, 체력, 첫날 활용, 마일리지 등 우선순위를 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 항공권·환승·공항 이동 플랜 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 숙소 지역 선택·치안·동선 비교 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '숙소 지역 선택·치안·동선 비교 프롬프트',
        '도시 안에서 어느 동네에 숙소를 잡아야 하는지, 관광·식사·교통·야간 이동 기준으로 비교하는 프롬프트입니다.',
        '{"해외여행","여행","숙소","호텔","지역선택"}'::text[],
        'public',
        '## 소개

같은 도시라도 어느 지역에 숙소를 잡느냐에 따라 여행 난이도가 크게 달라집니다. 이 게시물은 관광지 접근성뿐 아니라 식사, 야간 이동, 소음, 분위기까지 함께 보며 지역을 고르는 데 적합합니다.

먼저 숙소 지역을 비교하고,

[[PROMPT:0]]

후보 숙소가 있다면 실제 여행 목적에 맞춰 다시 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 도시별 숙소 지역 비교
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '도시별 숙소 지역 비교',
        '당신은 해외도시 숙소 선택 도우미입니다.

아래 조건을 바탕으로 어느 동네에 숙소를 잡는 것이 좋은지 비교해주세요.

[도시]
{{city}}

[여행 목적]
{{trip_goal}}

[동행자]
{{companions}}

[원하는 분위기]
{{preferred_vibe}}

[피하고 싶은 것]
{{avoid_points}}

조건:
- 관광 접근성, 식당 밀집도, 대중교통 편의, 야간 이동 부담, 소음 가능성, 치안 체감, 쇼핑 접근성, 체크인 후 동선까지 고려할 것
- ''초보 여행자에게 좋은 지역'', ''감성은 좋지만 호불호 있는 지역'', ''이번 여행엔 비추천 지역''으로 나눌 것
- 마지막에 숙소 예약 전에 지도에서 체크할 포인트를 10개 적을 것',
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
        'city',
        '도시',
        '숙소를 잡을 도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'trip_goal',
        '여행 목적',
        '관광, 쇼핑, 야경, 휴양, 미식 등 입력하세요',
        'textarea',
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
        '혼자, 연인, 친구, 가족 등 입력하세요',
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
        '원하는 분위기',
        '조용함, 감성, 편리함, 밤문화, 로컬감성 등 입력하세요',
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
        '오르막, 심야 소음, 복잡한 환승 등 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 숙소 후보 비교표 만들기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '숙소 후보 비교표 만들기',
        '당신은 해외여행 숙소 비교 도우미입니다.

아래 숙소 후보를 여행 흐름에 맞춰 비교해주세요.

[도시]
{{city}}

[숙소 후보]
{{hotel_candidates}}

[중요 기준]
{{important_criteria}}

조건:
- 가격만이 아니라 위치, 역 접근성, 공항 이동, 밤 늦게 돌아와도 괜찮은지, 주변 식당과 편의점, 체크인 편의, 소음 가능성까지 고려할 것
- 표 형태와 요약 코멘트를 함께 줄 것
- 가장 추천하는 1곳과 차선책 1곳을 고를 것
- 예약 전에 숙소에 문의하면 좋은 질문도 함께 제안할 것',
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
        'city',
        '도시',
        '도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'hotel_candidates',
        '숙소 후보',
        '숙소 후보 목록을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'important_criteria',
        '중요 기준',
        '엘리베이터, 조식, 역세권, 욕조 등 중요 기준을 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 숙소 지역 선택·치안·동선 비교 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 환전·카드·ATM·예산 관리 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '환전·카드·ATM·예산 관리 프롬프트',
        '해외여행 예산을 항공·숙소·식비·교통·쇼핑으로 나누고, 현금과 카드 사용 전략까지 정리하는 프롬프트입니다.',
        '{"해외여행","여행","환전","카드","예산관리"}'::text[],
        'public',
        '## 소개

해외여행은 총예산보다도 현지에서 어떻게 돈을 쓰느냐가 중요합니다. 이 게시물은 환전, 카드, ATM 사용, 식비·교통비·쇼핑비 분리까지 함께 보는 데 적합합니다.

먼저 전체 예산표를 만들고,

[[PROMPT:0]]

현지 결제 전략이 궁금하다면 카드와 현금 비중도 따로 설계할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 해외여행 예산표 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '해외여행 예산표 설계',
        '당신은 해외여행 예산 설계 도우미입니다.

아래 정보를 바탕으로 해외여행 예산표를 짜주세요.

[여행지]
{{destination}}

[여행 기간]
{{duration}}

[인원]
{{people_count}}

[총예산]
{{total_budget}}

[여행 스타일]
{{travel_style}}

조건:
- 항공, 숙소, 교통, 식비, 카페/간식, 입장료/체험, 쇼핑, 비상금으로 나눠 예산을 배분할 것
- 가성비형과 만족도 우선형 두 가지 안으로 제시할 것
- 절약하면 좋은 항목과 돈을 써야 만족도가 올라가는 항목을 구분할 것
- 마지막에 ''예산 초과가 잘 나는 지점''과 ''미리 상한선을 정하면 좋은 지점''을 정리할 것',
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
        '여행지',
        '국가와 도시를 입력하세요',
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
        '여행 기간을 입력하세요',
        'text',
        1,
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
        2,
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
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '쇼핑 위주, 식도락 위주, 관광 위주 등 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 현금·카드·ATM 사용 전략 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '현금·카드·ATM 사용 전략 정리',
        '당신은 해외여행 결제 전략 도우미입니다.

아래 여행 조건을 바탕으로 현금, 카드, ATM 인출의 사용 전략을 정리해주세요.

[여행지]
{{destination}}

[여행 방식]
{{travel_mode}}

[지출 성향]
{{spending_pattern}}

[걱정되는 점]
{{worry_points}}

조건:
- 교통, 소액결제, 식당, 쇼핑, 비상 상황에서 무엇이 편한지 구분할 것
- 현금을 너무 많이 들고 다니는 위험과 카드만 믿는 위험을 균형 있게 설명할 것
- 환전 시점, 현지 도착 직후 쓸 최소 현금, 카드 분산 보관 아이디어를 포함할 것
- 마지막에 출발 전 금융 관련 체크리스트를 적을 것',
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
        '여행지',
        '여행지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'travel_mode',
        '여행 방식',
        '자유여행, 패키지, 도시 중심, 지방 이동 포함 등 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'spending_pattern',
        '지출 성향',
        '소액결제 많음, 쇼핑 많음, 교통 많음 등 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'worry_points',
        '걱정 포인트',
        '분실, 환전, 수수료, 카드 승인 오류 등 입력하세요',
        'textarea',
        3,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 환전·카드·ATM·예산 관리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 짐싸기·의약품·여행 준비물 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '짐싸기·의약품·여행 준비물 프롬프트',
        '기본 짐, 계절 옷차림, 전자기기, 상비약, 처방약, 장시간 비행 준비까지 포함한 준비물 체크 프롬프트입니다.',
        '{"해외여행","여행","짐싸기","준비물","의약품"}'::text[],
        'public',
        '## 소개

해외여행 준비물은 너무 많이 챙겨도 문제고 빠뜨려도 문제입니다. 이 게시물은 여행지, 계절, 일정, 건강 상태에 따라 꼭 필요한 것만 압축해서 정리하는 데 적합합니다.

먼저 전체 준비물 체크리스트를 만들고,

[[PROMPT:0]]

약과 건강 관련 준비는 별도로 더 꼼꼼하게 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 해외여행 짐싸기 체크리스트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '해외여행 짐싸기 체크리스트',
        '당신은 해외여행 준비물 정리 도우미입니다.

아래 조건을 바탕으로 짐싸기 체크리스트를 만들어주세요.

[여행지]
{{destination}}

[여행 시기]
{{season_or_weather}}

[여행 기간]
{{duration}}

[여행 스타일]
{{travel_style}}

[짐 제한 또는 특이사항]
{{packing_limit}}

조건:
- 서류, 의류, 세면/건강, 전자기기, 기내용, 현지필수품으로 나눠 정리할 것
- 꼭 필요한 것과 있으면 좋은 것을 구분할 것
- 장시간 비행 대비 아이템과 현지 날씨 대비 아이템을 포함할 것
- 마지막에 출발 전날 밤 체크리스트와 공항 가기 직전 체크리스트를 따로 적을 것',
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
        '여행지',
        '국가와 도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'season_or_weather',
        '시기/날씨',
        '여행 시기와 예상 날씨를 입력하세요',
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
        '여행 기간을 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_style',
        '여행 스타일',
        '도시관광, 휴양, 트레킹, 출장 등 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'packing_limit',
        '짐 제한',
        '기내용만, 위탁 1개, 아이 동반 등 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 의약품·건강 준비 체크리스트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '의약품·건강 준비 체크리스트',
        '당신은 해외여행 건강 준비 도우미입니다.

아래 상황을 바탕으로 여행 건강 준비 체크리스트를 만들어주세요.

[여행지]
{{destination}}

[여행 기간]
{{duration}}

[복용 중인 약 또는 건강 이슈]
{{health_info}}

조건:
- 처방약, 상비약, 기내용으로 따로 챙길 것, 장거리 비행 대비 준비, 현지에서 구하기 어려울 수 있는 기본품을 구분할 것
- 나라별 약 반입 규정은 공식 확인이 필요하다는 전제로, 준비 관점에서 정리할 것
- 약 포장, 처방전 사본, 영문명 확인 같은 실무적인 포인트를 포함할 것
- 마지막에 출국 전 병원이나 약국에 물어보면 좋은 질문 목록을 제시할 것',
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
        '여행지',
        '여행지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'duration',
        '여행 기간',
        '여행 기간을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'health_info',
        '건강 정보',
        '알레르기, 처방약, 멀미, 위장 약함 등 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 짐싸기·의약품·여행 준비물 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 아이 동반 해외여행 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '아이 동반 해외여행 프롬프트',
        '유아·어린이 동반 해외여행에서 비행, 낮잠, 식사, 유모차, 숙소, 일정 밀도를 현실적으로 맞추는 프롬프트입니다.',
        '{"해외여행","여행","아이와여행","가족여행","유아동반"}'::text[],
        'public',
        '## 소개

아이와 가는 해외여행은 예쁜 코스보다 무리 없는 흐름이 중요합니다. 이 게시물은 비행, 식사, 낮잠, 유모차, 실내 대안까지 반영한 가족형 해외여행 계획에 초점을 둡니다.

먼저 전체 일정을 만들고,

[[PROMPT:0]]

숙소와 식당을 고를 때의 기준도 따로 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 아이 동반 해외여행 일정 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 동반 해외여행 일정 설계',
        '당신은 아이 동반 해외여행 전문 플래너입니다.

아래 정보를 바탕으로 아이와 함께 가는 해외여행 일정을 짜주세요.

[여행지]
{{destination}}

[아이 나이]
{{child_age}}

[여행 기간]
{{duration}}

[비행 시간]
{{flight_time}}

[아이 성향]
{{child_style}}

[부모가 원하는 분위기]
{{parent_style}}

[중요 조건]
{{important_conditions}}

조건:
- 아이의 비행 피로, 낮잠, 간식, 화장실, 유모차, 긴 대기 스트레스를 고려할 것
- 실내와 실외를 적절히 섞을 것
- 무리한 장거리 이동은 피하고, 하루에 확실한 메인 포인트만 잡을 것
- 부모도 만족할 수 있는 식사나 카페 타이밍을 포함할 것
- 마지막에 ''아이 동반 여행에서 예약 전에 꼭 확인할 것''을 정리할 것',
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
        '여행지',
        '국가와 도시를 입력하세요',
        'text',
        0,
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
        '여행 기간을 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'flight_time',
        '비행 시간',
        '직항 몇 시간, 환승 포함 총 몇 시간 등 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'child_style',
        '아이 성향',
        '낯가림, 잠 민감, 오래 못 앉아있음 등 입력하세요',
        'textarea',
        4,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'parent_style',
        '부모 스타일',
        '관광 반반, 맛집 필수, 휴양 중심 등 입력하세요',
        'textarea',
        5,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'important_conditions',
        '중요 조건',
        '유모차, 키즈풀, 조식, 근거리 이동 등 입력하세요',
        'textarea',
        6,
        NOW()
    );

    -- post_prompt[1]: 아이 동반 숙소·식당 선택 기준표
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '아이 동반 숙소·식당 선택 기준표',
        '아이와 해외여행 갈 때 숙소와 식당을 고를 때 체크해야 할 기준표를 만들어주세요.

[아이 나이]
{{child_age}}

[여행지]
{{destination}}

[가장 걱정되는 점]
{{worry_points}}

조건:
- 숙소 편의, 식당 편의, 이동 편의, 돌발상황 대응으로 나눠 정리할 것
- 엘리베이터, 침대 안전, 아침 식사, 유아식 가능성, 대기시간, 화장실, 유모차, 빨래, 편의점 접근을 포함할 것
- 마지막에 예약 전에 숙소/식당에 물어볼 질문 10개를 작성할 것',
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
        '여행지',
        '여행지를 입력하세요',
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
        '낮잠, 편식, 장거리 도보, 아이 의자 등 걱정 포인트를 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 아이 동반 해외여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 현지 교통패스·지하철·이동 전략 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '현지 교통패스·지하철·이동 전략 프롬프트',
        '공항철도, 지하철, 버스, 패스권, 택시, 도보를 어떻게 섞어야 여행이 편한지 정리하는 프롬프트입니다.',
        '{"해외여행","여행","현지교통","지하철","교통패스"}'::text[],
        'public',
        '## 소개

해외도시는 관광지보다 교통이 더 어려운 경우가 많습니다. 이 게시물은 공항 이동, 도시 내 패스권, 도보량, 택시 활용까지 함께 설계하는 데 적합합니다.

먼저 교통 전략을 만들고,

[[PROMPT:0]]

후보 패스권이나 이동 수단이 있다면 상황별로 비교할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 현지 교통 전략 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '현지 교통 전략 설계',
        '당신은 해외도시 교통 전략 도우미입니다.

아래 조건을 바탕으로 현지 교통 이용 전략을 짜주세요.

[도시]
{{city}}

[숙소 지역]
{{hotel_area}}

[주요 방문 예정 지역]
{{main_areas}}

[여행 기간]
{{duration}}

[동행자 및 이동 제약]
{{movement_limit}}

조건:
- 공항 이동, 도시 내 이동, 심야 이동, 짐 있는 날 이동을 구분해서 정리할 것
- 교통패스가 유리한지, 개별 결제가 유리한지, 택시를 섞는 것이 나은지 설명할 것
- 초보 여행자 기준으로 실수하기 쉬운 포인트를 포함할 것
- 마지막에 첫날 도착 직후와 마지막 날 출국 전 교통 운영 팁을 정리할 것',
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
        'city',
        '도시',
        '여행 도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'hotel_area',
        '숙소 지역',
        '숙소 지역을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'main_areas',
        '주요 방문 지역',
        '방문 예정 지역을 입력하세요',
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
        '여행 기간을 입력하세요',
        'text',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'movement_limit',
        '이동 제약',
        '캐리어 큼, 아이 동반, 계단 약함, 늦은 밤 위험 회피 등 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 교통패스 후보 비교 프롬프트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '교통패스 후보 비교 프롬프트',
        '당신은 여행 교통패스 비교 도우미입니다.

아래 교통패스 또는 이동 방식 후보를 보고 이번 여행에 맞게 비교해주세요.

[도시]
{{city}}

[후보]
{{pass_candidates}}

[예상 동선]
{{expected_route}}

조건:
- 무조건 싸다고 좋은 것이 아니라 사용 편의, 이동 횟수, 첫날/마지막 날 활용도, 관광 패턴을 고려할 것
- 꼭 필요한 패스 / 있으면 좋은 패스 / 굳이 필요 없는 패스로 나눌 것
- 마지막에 이번 여행에서 교통비를 아끼는 법보다 시간을 아끼는 법을 우선 설명할 것',
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
        'city',
        '도시',
        '도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'pass_candidates',
        '후보',
        '교통패스 또는 이동 방식 후보를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'expected_route',
        '예상 동선',
        '주로 이동할 지역과 횟수를 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 현지 교통패스·지하철·이동 전략 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 현지 맛집·카페·식도락 여행 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.982Z
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
        '현지 맛집·카페·식도락 여행 프롬프트',
        '유명 맛집만이 아니라 로컬 식당, 시장, 카페, 바를 동선에 맞게 묶어 식도락 여행 코스를 짜는 프롬프트입니다.',
        '{"해외여행","여행","맛집","카페","식도락"}'::text[],
        'public',
        '## 소개

해외여행의 만족도는 먹는 경험이 크게 좌우합니다. 이 게시물은 단순한 맛집 리스트가 아니라 아침·점심·간식·저녁·야식의 흐름과 예약 난이도까지 고려한 식도락 코스를 만들기 위해 설계했습니다.

먼저 식도락 코스를 설계하고,

[[PROMPT:0]]

맛집 후보가 많다면 우선순위 기준으로 다시 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 도시별 식도락 코스 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '도시별 식도락 코스 설계',
        '당신은 해외 식도락 여행 플래너입니다.

아래 조건에 맞춰 도시의 음식과 카페를 중심으로 여행 코스를 짜주세요.

[도시]
{{city}}

[여행 기간]
{{duration}}

[동행자]
{{companions}}

[선호 음식]
{{food_preference}}

[피하고 싶은 것]
{{avoid_conditions}}

[원하는 분위기]
{{mood}}

조건:
- 아침, 점심, 간식, 저녁, 카페 또는 바 흐름이 과하지 않게 이어지게 할 것
- 관광지와 식사 장소가 따로 놀지 않게 동선에 맞춰 배치할 것
- 유명한 곳만이 아니라 로컬 식당, 시장, 디저트, 감성 카페를 균형 있게 섞을 것
- 예약 필요성, 웨이팅 가능성, 식사 시간대 팁을 함께 적을 것
- 마지막에 꼭 먹어볼 것 5개와 비 오는 날 더 좋은 식도락 플랜을 적을 것',
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
        'city',
        '도시',
        '도시를 입력하세요',
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
        '여행 기간을 입력하세요',
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
        '면, 해산물, 디저트, 커피, 바 등 선호를 입력하세요',
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
        '매운 음식, 웨이팅 긴 곳, 술 제외 등 입력하세요',
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
        '로컬, 감성카페, 힙한 바, 전통시장 등 입력하세요',
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
        '당신은 해외여행 맛집 후보 정리 도우미입니다.

아래 후보 리스트를 실제로 갈 가치가 높은 순서로 정리해주세요.

[도시]
{{city}}

[후보 리스트]
{{candidate_list}}

[여행 스타일]
{{travel_style}}

조건:
- 식사 시간, 동선, 분위기, 예약 난이도, 웨이팅 부담 기준으로 평가할 것
- 반드시 갈 곳 / 상황 따라 갈 곳 / 굳이 안 가도 될 곳으로 나눌 것
- 너무 유명하지만 여행 흐름을 망칠 수 있는 곳은 솔직하게 지적할 것',
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
        'city',
        '도시',
        '도시를 입력하세요',
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

    RAISE NOTICE 'INSERT OK: 현지 맛집·카페·식도락 여행 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 우천·돌발상황·플랜B 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.983Z
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
        '우천·돌발상황·플랜B 프롬프트',
        '비, 파업, 휴무, 체력 저하, 소매치기 우려, 길찾기 실패처럼 현지에서 생길 수 있는 변수에 대비한 대체 플랜 프롬프트입니다.',
        '{"해외여행","여행","플랜B","우천대비","돌발상황"}'::text[],
        'public',
        '## 소개

해외여행은 계획보다 변수가 많습니다. 이 게시물은 날씨 문제뿐 아니라 휴무, 예약 실패, 피로, 길찾기 문제처럼 현지에서 자주 생기는 상황의 백업 플랜을 준비하는 데 적합합니다.

먼저 플랜B를 만들고,

[[PROMPT:0]]

불안한 상황에서 바로 볼 수 있는 긴급 행동 정리도 만들 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 여행 변수 대비 플랜B 설계
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '여행 변수 대비 플랜B 설계',
        '당신은 해외여행 플랜B 설계 도우미입니다.

아래 기존 여행 계획을 바탕으로 변수 발생 시 대체 플랜을 만들어주세요.

[여행지]
{{destination}}

[기존 계획]
{{original_plan}}

[걱정되는 변수]
{{risk_factors}}

조건:
- 비, 강풍, 폭염, 휴무, 예약 실패, 체력 저하, 늦은 출발, 교통 지연 같은 변수에 대응할 것
- 완전히 다른 여행이 되지 않게 원래 분위기를 최대한 유지할 것
- 무엇을 과감히 빼야 하는지, 무엇은 지켜야 하는지 구분할 것
- 마지막에 일정이 꼬였을 때 우선순위 판단 기준 7개를 적을 것',
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
        '여행지',
        '국가와 도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'original_plan',
        '기존 계획',
        '기존 일정을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'risk_factors',
        '걱정되는 변수',
        '비, 휴무, 체력, 치안 불안, 파업 등 입력하세요',
        'textarea',
        2,
        NOW()
    );

    -- post_prompt[1]: 긴급 상황 시 행동 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '긴급 상황 시 행동 정리',
        '해외여행 중 아래와 같은 상황이 생겼을 때 당황하지 않도록 행동 순서를 정리해주세요.

[상황]
{{emergency_case}}

조건:
- 여권 분실, 지갑 분실, 휴대폰 분실, 늦은 밤 길찾기 실패, 교통 파업, 몸이 아플 때, 예약 문제가 생겼을 때 같은 유형을 기준으로 정리할 것
- 공포 조장이 아니라 침착한 순서 중심으로 적을 것
- 당장 할 일 / 현지에서 확인할 것 / 귀국 전 정리할 것으로 나눌 것
- 마지막에 여행 전에 미리 준비해두면 좋은 비상 대비 항목을 적을 것',
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
        'emergency_case',
        '상황',
        '걱정되는 긴급 상황을 입력하세요',
        'textarea',
        0,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 우천·돌발상황·플랜B 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 현지 안전·에티켓·사기 회피 프롬프트
-- Source: 2603101425_work.json
-- Generated: 2026-03-10T05:26:08.983Z
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
        '현지 안전·에티켓·사기 회피 프롬프트',
        '여행지의 기본 에티켓, 사진 촬영 예절, 팁 문화, 소매치기·관광객 대상 사기 회피 포인트를 정리하는 프롬프트입니다.',
        '{"해외여행","여행","안전","에티켓","사기예방"}'::text[],
        'public',
        '## 소개

해외여행 만족도는 명소보다도 현지에서 불편한 일을 덜 겪는 데 달려 있습니다. 이 게시물은 현지 에티켓과 기본 안전 감각을 빠르게 정리하는 데 적합합니다.

먼저 여행지별 행동 가이드를 만들고,

[[PROMPT:0]]

관광객이 흔히 당하는 상황 위주로 회피 전략만 따로 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 여행지별 안전·에티켓 요약
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '여행지별 안전·에티켓 요약',
        '당신은 해외여행 안전·에티켓 정리 도우미입니다.

아래 여행지를 기준으로 여행자가 알아두면 좋은 기본 행동 가이드를 정리해주세요.

[국가/도시]
{{destination}}

[여행 방식]
{{travel_mode}}

[동행자]
{{companions}}

조건:
- 현지에서 무례하게 보일 수 있는 행동, 사진 촬영 주의, 팁 문화, 줄서기/대중교통 예절, 복장 유의점, 야간 이동 주의, 귀중품 관리 포인트를 포함할 것
- 지나치게 무섭게 쓰지 말고 현실적으로 정리할 것
- 초보 여행자가 바로 이해할 수 있게 짧고 명확하게 쓸 것
- 마지막에 ''이 도시에서 여행자가 쉽게 하는 실수 10개''를 적을 것',
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
        '여행지',
        '국가와 도시를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'travel_mode',
        '여행 방식',
        '자유여행, 출장, 쇼핑 위주, 야경 위주 등 입력하세요',
        'textarea',
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
        '혼자, 연인, 가족, 친구 등 입력하세요',
        'text',
        2,
        NOW()
    );

    -- post_prompt[1]: 관광객 대상 사기·불편 상황 회피 포인트
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '관광객 대상 사기·불편 상황 회피 포인트',
        '당신은 해외여행 리스크 회피 도우미입니다.

아래 여행 조건을 기준으로 관광객이 자주 겪는 불편 상황과 회피 포인트를 정리해주세요.

[여행지]
{{destination}}

[여행 스타일]
{{travel_style}}

조건:
- 택시, 환전, 길안내, 사진 찍어주기, 호객, 티켓 판매, 소매치기, 레스토랑 추가요금, 바/클럽, 야시장, 기념품 쇼핑처럼 자주 생기는 상황을 포함할 것
- 공포 조장이 아니라 ''어떻게 구분하고 어떻게 대응하면 되는지'' 중심으로 작성할 것
- 마지막에 여행 중 계속 기억하면 좋은 짧은 원칙 12개를 적을 것',
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
        '여행지',
        '여행지를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'travel_style',
        '여행 스타일',
        '쇼핑 위주, 야시장 위주, 대중교통 위주 등 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 현지 안전·에티켓·사기 회피 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
