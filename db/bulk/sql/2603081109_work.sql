-- ============================================================
-- Bulk Insert: 공식 회의록 작성 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.868Z
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
        '공식 회의록 작성 프롬프트',
        '비정형 회의 메모를 공식 회의록, 결정사항, 후속조치 중심의 문서로 정리하는 업무용 프롬프트입니다.',
        '{"업무","회의록","정리","문서작성","협업"}'::text[],
        'public',
        '## 소개

회의 직후 남겨둔 메모나 대화 기록은 그대로 두면 공유용 문서로 사용하기 어렵습니다. 이 게시물은 비정형 회의 내용을 공식 회의록 형식으로 정리하는 데 초점을 둡니다.

먼저 전체 회의록 초안을 만들고,

[[PROMPT:0]]

그 다음 실행 과제만 따로 추출해 관리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 비정형 회의 메모를 공식 회의록으로 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '비정형 회의 메모를 공식 회의록으로 정리',
        '당신은 공식 회의록 작성 도우미입니다.

아래 회의 메모를 바탕으로 {{document_style}} 형식의 회의록을 작성해주세요.

[회의 주제]
{{meeting_topic}}

[회의 메모]
{{meeting_notes}}

[출력 시 포함 항목]
- 회의 목적
- 주요 논의사항
- 결정사항
- 미결사항
- 후속조치

조건:
- 원문에 없는 내용은 추정하지 말 것
- 보고서 문체로 정리할 것
- 읽기 쉬운 항목형 구조로 작성할 것',
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
        'meeting_topic',
        '회의 주제',
        '회의 제목 또는 안건명을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'meeting_notes',
        '회의 메모',
        '정리되지 않은 회의 메모를 붙여넣으세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'document_style',
        '문서 스타일',
        '원하는 회의록 문서 스타일을 선택하세요',
        'select',
        2,
        NOW()
    );

    -- post_prompt[1]: 회의록에서 액션 아이템만 추출
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '회의록에서 액션 아이템만 추출',
        '아래 회의 내용을 기준으로 실행해야 할 업무만 추출해주세요.

[회의 내용]
{{content}}

조건:
- 해야 할 일만 목록화할 것
- 각 항목에 담당자, 기한, 우선순위를 구분할 것
- 정보가 없으면 ''(확인 필요)''로 표기할 것
- 결과는 {{output_format}} 형식으로 정리할 것',
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
        '회의 내용',
        '회의록 또는 메모 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'output_format',
        '출력 형식',
        '정리 형식을 선택하세요',
        'select',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 공식 회의록 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 업무 이메일·공문 초안 작성 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.869Z
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
        '업무 이메일·공문 초안 작성 프롬프트',
        '업무 요청, 회신, 안내, 협조 요청 등 다양한 상황의 이메일과 공문 초안을 빠르게 만드는 프롬프트입니다.',
        '{"업무","이메일","공문","협조요청","문서작성"}'::text[],
        'public',
        '## 소개

업무에서는 이메일, 공문, 안내문 등 형식 있는 문서를 반복적으로 작성하게 됩니다. 이 게시물은 목적과 상대, 톤에 맞는 초안을 신속하게 만드는 데 적합합니다.

먼저 초안을 만들고,

[[PROMPT:0]]

필요 시 더 정중하거나 더 간결하게 다듬을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 업무용 이메일 또는 공문 초안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '업무용 이메일 또는 공문 초안 작성',
        '당신은 기업/기관 문서 작성 도우미입니다.

아래 정보를 바탕으로 {{doc_type}} 초안을 작성해주세요.

[수신 대상]
{{recipient}}

[작성 목적]
{{purpose}}

[핵심 전달 내용]
{{key_points}}

[원하는 톤]
{{tone}}

조건:
- 실제 발송 가능한 수준으로 자연스럽게 작성할 것
- 문서 목적이 분명하게 드러나게 작성할 것
- 제목도 함께 제안할 것',
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
        'doc_type',
        '문서 유형',
        '작성할 문서 유형을 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'recipient',
        '수신 대상',
        '받는 사람 또는 기관을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'purpose',
        '작성 목적',
        '문서를 작성하는 목적을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'key_points',
        '핵심 내용',
        '반드시 포함해야 할 주요 내용을 입력하세요',
        'textarea',
        3,
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
        4,
        NOW()
    );

    -- post_prompt[1]: 문서를 더 정중하거나 간결하게 다듬기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '문서를 더 정중하거나 간결하게 다듬기',
        '아래 문서를 {{revision_style}} 방향으로 다듬어주세요.

[원문]
{{original_doc}}

조건:
- 원래 의미는 유지할 것
- 표현만 더 적절하게 정리할 것
- 수정본과 함께 개선 포인트를 3개 이내로 설명할 것',
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
        'revision_style',
        '수정 방향',
        '어떤 방향으로 다듬을지 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'original_doc',
        '원문',
        '작성한 문서 초안을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 업무 이메일·공문 초안 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 보고서 요약·보고자료 정리 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.869Z
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
        '보고서 요약·보고자료 정리 프롬프트',
        '긴 문서, 회의자료, 정책자료, 사업자료를 핵심만 간결하게 요약하고 보고용으로 정리하는 프롬프트입니다.',
        '{"업무","보고서","요약","보고자료","문서정리"}'::text[],
        'public',
        '## 소개

긴 자료를 그대로 전달하면 읽는 사람의 부담이 커집니다. 이 게시물은 보고용 핵심 요약, 한 페이지 정리, 임원 보고 포인트 정리에 적합합니다.

전체 자료를 요약하고,

[[PROMPT:0]]

필요하면 보고 대상에 맞춰 다시 재구성할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 긴 문서를 핵심 요약으로 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '긴 문서를 핵심 요약으로 정리',
        '당신은 보고자료 요약 도우미입니다.

아래 문서를 {{summary_type}} 형식으로 요약해주세요.

[원문]
{{source_text}}

조건:
- 핵심 내용, 주요 수치, 결정 포인트를 우선 정리할 것
- 불필요한 수식은 줄이고 의미 중심으로 요약할 것
- 한국어로 명확하게 작성할 것',
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
        'summary_type',
        '요약 형식',
        '원하는 요약 형식을 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'source_text',
        '원문',
        '요약할 보고서, 기사, 정책자료, 회의자료를 입력하세요',
        'textarea',
        1,
        NOW()
    );

    -- post_prompt[1]: 보고 대상별로 내용 재구성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '보고 대상별로 내용 재구성',
        '아래 내용을 {{audience}}에게 보고하기 좋은 형태로 재구성해주세요.

[기준 내용]
{{base_content}}

조건:
- 해당 보고 대상이 관심 가질 핵심 위주로 재배치할 것
- 배경, 현재 상황, 문제점, 요청사항을 구분할 것
- 바로 보고 가능한 문체로 작성할 것',
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
        'audience',
        '보고 대상',
        '누구에게 보고할지 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'base_content',
        '기준 내용',
        '요약본 또는 원문 핵심 내용을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 보고서 요약·보고자료 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 요구사항 정리·개발 요청서 작성 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.869Z
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
        '요구사항 정리·개발 요청서 작성 프롬프트',
        '구두로 전달받은 업무 요청이나 아이디어를 개발 요청서, 개선 요구사항, 화면/기능 정의 형태로 정리하는 프롬프트입니다.',
        '{"업무","요구사항","개발요청","기획","정리"}'::text[],
        'public',
        '## 소개

개발 요청이나 기능 개선 의견은 처음에는 대부분 정리되지 않은 상태로 전달됩니다. 이 게시물은 그 내용을 체계적인 요구사항 문서로 바꾸는 데 유용합니다.

먼저 요구사항 초안을 만들고,

[[PROMPT:0]]

그 다음 테스트 관점에서 확인 항목까지 뽑을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 비정형 요청을 요구사항 문서로 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '비정형 요청을 요구사항 문서로 정리',
        '당신은 서비스 기획 및 요구사항 정리 도우미입니다.

아래 요청 내용을 바탕으로 요구사항 문서를 작성해주세요.

[요청 배경]
{{background}}

[요청 내용]
{{request_details}}

[기대 효과]
{{expected_effect}}

조건:
- 요구사항을 기능 요구사항과 비기능 요구사항으로 나눌 것
- 화면/기능/예외사항 관점에서 빠짐없이 정리할 것
- 모호한 부분은 ''(확인 필요)''로 표기할 것',
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
        'background',
        '요청 배경',
        '이 요청이 왜 필요한지 배경을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'request_details',
        '요청 내용',
        '전달받은 요청사항이나 아이디어를 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'expected_effect',
        '기대 효과',
        '개선 후 기대되는 효과를 입력하세요',
        'textarea',
        2,
        NOW()
    );

    -- post_prompt[1]: 요구사항 기반 테스트 체크리스트 생성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '요구사항 기반 테스트 체크리스트 생성',
        '아래 요구사항을 기준으로 테스트 체크리스트를 작성해주세요.

[요구사항]
{{requirements}}

조건:
- 정상 케이스, 예외 케이스, 권한/상태값 케이스를 나눌 것
- 테스트 항목은 실행 가능한 문장으로 작성할 것
- 결과는 {{checklist_format}} 형식으로 정리할 것',
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
        'requirements',
        '요구사항',
        '정리된 요구사항 문서를 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'checklist_format',
        '체크리스트 형식',
        '출력 형식을 선택하세요',
        'select',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 요구사항 정리·개발 요청서 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 업무 우선순위·오늘 할 일 정리 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.869Z
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
        '업무 우선순위·오늘 할 일 정리 프롬프트',
        '쌓여 있는 업무를 긴급도와 중요도 기준으로 재정리하고 오늘 해야 할 일 중심으로 우선순위를 잡는 프롬프트입니다.',
        '{"업무","우선순위","할일정리","생산성","일정관리"}'::text[],
        'public',
        '## 소개

업무가 많아질수록 무엇부터 해야 하는지 판단이 어려워집니다. 이 게시물은 업무 목록을 우선순위 기준으로 재정리하고 실행 순서를 잡는 데 도움을 줍니다.

먼저 전체 업무를 분류하고,

[[PROMPT:0]]

오늘 안에 처리할 실행 계획으로 다시 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 업무 목록 우선순위 재정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '업무 목록 우선순위 재정리',
        '당신은 업무 우선순위 정리 도우미입니다.

아래 업무 목록을 보고 우선순위를 재정리해주세요.

[업무 목록]
{{task_list}}

[마감 일정 또는 제약]
{{constraints}}

조건:
- 긴급도와 중요도를 기준으로 분류할 것
- 먼저 해야 할 일부터 순서를 제시할 것
- 보류 가능한 항목도 구분할 것
- 결과는 {{priority_method}} 기준으로 정리할 것',
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
        'task_list',
        '업무 목록',
        '현재 해야 할 일들을 줄바꿈 또는 목록 형태로 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'constraints',
        '마감/제약사항',
        '오늘 마감, 외부 의존성, 보고 일정 등 제약을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'priority_method',
        '정리 기준',
        '원하는 우선순위 정리 방식을 선택하세요',
        'select',
        2,
        NOW()
    );

    -- post_prompt[1]: 오늘 실행 계획으로 변환
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '오늘 실행 계획으로 변환',
        '아래 우선순위 정리 결과를 기준으로 오늘 실행 계획을 짜주세요.

[우선순위 정리 결과]
{{priority_result}}

[오늘 사용 가능한 시간]
{{available_time}}

조건:
- 오전/오후 또는 시간대별로 배치할 것
- 집중이 필요한 업무와 단순 업무를 적절히 배분할 것
- 현실적으로 끝낼 수 있는 수준으로만 계획할 것',
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
        'priority_result',
        '우선순위 결과',
        '정리된 우선순위 목록을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'available_time',
        '사용 가능 시간',
        '오늘 업무에 쓸 수 있는 시간이나 스케줄을 입력하세요',
        'text',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 업무 우선순위·오늘 할 일 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 고객·민원 응대 답변 작성 프롬프트
-- Source: 2603081109_work.json
-- Generated: 2026-03-08T14:10:03.869Z
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
        '고객·민원 응대 답변 작성 프롬프트',
        '문의, 불만, 요청, 민원에 대해 정중하고 명확한 답변 초안을 만드는 업무 대응용 프롬프트입니다.',
        '{"업무","고객응대","민원응대","답변작성","커뮤니케이션"}'::text[],
        'public',
        '## 소개

고객이나 민원인의 문의에는 정확하면서도 감정적으로 불필요한 마찰이 없도록 답변해야 합니다. 이 게시물은 응대 초안 작성과 표현 다듬기에 적합합니다.

먼저 답변 초안을 만들고,

[[PROMPT:0]]

필요하면 더 부드럽거나 더 단호한 방향으로 조정할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 문의·민원 답변 초안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '문의·민원 답변 초안 작성',
        '당신은 고객 및 민원 응대 문서 작성 도우미입니다.

아래 문의 또는 민원 내용에 대해 답변 초안을 작성해주세요.

[문의/민원 내용]
{{issue_text}}

[현재 상황 또는 사실관계]
{{current_status}}

[반드시 전달해야 할 내용]
{{must_include}}

[응대 톤]
{{response_tone}}

조건:
- 감정적으로 과하지 않게 차분하게 작성할 것
- 상대방이 이해하기 쉽게 설명할 것
- 필요한 경우 사과, 안내, 후속 조치 내용을 구분할 것',
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
        'issue_text',
        '문의 또는 민원 내용',
        '상대방이 보낸 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'current_status',
        '현재 상황',
        '내부 확인 결과나 현재 상태를 입력하세요',
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
        '필수 안내 내용',
        '반드시 포함해야 하는 문구나 안내사항을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'response_tone',
        '응대 톤',
        '답변 문체를 선택하세요',
        'select',
        3,
        NOW()
    );

    -- post_prompt[1]: 응대 문장 톤 조정
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '응대 문장 톤 조정',
        '아래 답변 문안을 {{adjustment}} 방향으로 수정해주세요.

[답변 문안]
{{draft_reply}}

조건:
- 핵심 내용은 유지할 것
- 표현만 더 적절하게 조정할 것
- 수정본 2개 버전을 제시할 것',
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
        'adjustment',
        '조정 방향',
        '어떤 방향으로 답변을 조정할지 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'draft_reply',
        '답변 문안',
        '기존 답변 초안을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 고객·민원 응대 답변 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
