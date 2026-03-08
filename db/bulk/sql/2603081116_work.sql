-- ============================================================
-- Bulk Insert: 업무 이메일·메신저 답장 작성 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.759Z
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
        '업무 이메일·메신저 답장 작성 프롬프트',
        '업무 요청 회신, 일정 조율, 자료 전달, 정중한 거절 등 일상적인 직장 커뮤니케이션 문안을 빠르게 작성하는 범용 프롬프트입니다.',
        '{"업무","이메일","메신저","답장","커뮤니케이션"}'::text[],
        'public',
        '## 소개

일반 업무에서 가장 자주 반복되는 일 중 하나는 이메일과 메신저 답장 작성입니다. 이 게시물은 상황에 맞는 회신 문안을 빠르게 만드는 데 초점을 둡니다.

먼저 상황에 맞는 초안을 만들고,

[[PROMPT:0]]

필요하면 같은 내용을 더 짧게, 더 정중하게, 더 부드럽게 다듬을 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 상황 맞춤 업무 답장 초안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '상황 맞춤 업무 답장 초안 작성',
        '당신은 업무 커뮤니케이션 도우미입니다.

아래 정보를 바탕으로 바로 보낼 수 있는 답장 초안을 작성해주세요.

[상대방]
{{recipient_type}}

[받은 내용 또는 상황]
{{situation}}

[내가 전달할 핵심]
{{key_message}}

[원하는 톤]
{{tone}}

[추가 조건]
{{extra_condition}}

조건:
- 실제 회사에서 바로 사용할 수 있는 자연스러운 한국어로 작성할 것
- 지나치게 길지 않게 작성할 것
- 제목이 필요한 경우 제목도 함께 제안할 것
- 초안 3개 버전으로 제시할 것',
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
        'recipient_type',
        '상대방',
        '상사, 동료, 타부서, 외부업체, 고객 등 상대를 선택하세요',
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
        '받은 요청, 문의, 일정 조율 상황 등을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'key_message',
        '전달 핵심',
        '승인, 거절, 전달, 확인, 요청 등 꼭 말해야 할 핵심을 입력하세요',
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
        '원하는 말투를 선택하세요',
        'select',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'extra_condition',
        '추가 조건',
        '오늘 중 회신, 첨부파일 언급, 기한 포함 등 추가 조건을 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 기존 문안 톤과 길이 다듬기
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '기존 문안 톤과 길이 다듬기',
        '아래 문안을 {{revision_goal}} 방향으로 수정해주세요.

[원문]
{{original_text}}

조건:
- 의미는 유지할 것
- 더 자연스럽고 실무적으로 다듬을 것
- 수정본 3개를 제시할 것
- 각 수정본의 차이를 짧게 설명할 것',
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
        'revision_goal',
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
        'original_text',
        '원문',
        '수정할 이메일 또는 메신저 문안을 입력하세요',
        'textarea',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 업무 이메일·메신저 답장 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 회의 메모를 회의록으로 정리하는 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.760Z
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
        '회의 메모를 회의록으로 정리하는 프롬프트',
        '정리되지 않은 회의 메모, 녹취 요약, 메신저 대화를 공식적인 회의록과 후속조치 목록으로 정리하는 범용 업무 프롬프트입니다.',
        '{"업무","회의록","회의정리","액션아이템","문서작성"}'::text[],
        'public',
        '## 소개

회의가 끝난 직후의 메모는 대부분 정리되지 않은 상태입니다. 이 게시물은 그런 내용을 공유 가능한 회의록 형태로 정리하는 데 유용합니다.

먼저 전체 회의록 초안을 만들고,

[[PROMPT:0]]

필요하면 해야 할 일만 따로 추출해 실행 관리용으로 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 비정형 회의 메모를 회의록으로 정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '비정형 회의 메모를 회의록으로 정리',
        '당신은 업무 회의록 작성 도우미입니다.

아래 회의 내용을 바탕으로 {{meeting_format}} 형식의 회의록을 작성해주세요.

[회의 주제]
{{meeting_topic}}

[참석자]
{{participants}}

[회의 메모]
{{raw_notes}}

조건:
- 원문에 없는 정보는 추정하지 말 것
- 핵심 논의사항, 결정사항, 미결사항, 후속조치를 구분할 것
- 공유 가능한 수준으로 깔끔하게 정리할 것
- 보고서 문체로 작성할 것',
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
        '회의 제목 또는 안건을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'participants',
        '참석자',
        '참석자를 쉼표 또는 줄바꿈으로 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'raw_notes',
        '회의 메모',
        '정리되지 않은 메모나 대화 내용을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'meeting_format',
        '회의록 형식',
        '원하는 회의록 형태를 선택하세요',
        'select',
        3,
        NOW()
    );

    -- post_prompt[1]: 회의 내용에서 실행 과제만 추출
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '회의 내용에서 실행 과제만 추출',
        '아래 회의 내용에서 실제로 해야 할 일만 추출해주세요.

[회의 내용]
{{meeting_content}}

[정리 방식]
{{output_style}}

조건:
- 해야 할 일만 목록으로 정리할 것
- 담당자, 기한, 우선순위를 구분할 것
- 정보가 없으면 ''(확인 필요)''로 표기할 것',
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
        'meeting_content',
        '회의 내용',
        '회의록 또는 회의 메모 전체 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'output_style',
        '정리 방식',
        '결과 형식을 선택하세요',
        'select',
        1,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 회의 메모를 회의록으로 정리하는 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 보고용 요약·업무 공유 문안 작성 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.760Z
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
        '보고용 요약·업무 공유 문안 작성 프롬프트',
        '긴 자료, 업무 진행상황, 검토 결과를 핵심만 간결하게 정리해 상사나 팀에 공유할 수 있는 보고 문안을 만드는 프롬프트입니다.',
        '{"업무","보고","요약","공유","문서정리"}'::text[],
        'public',
        '## 소개

업무에서는 자료를 그대로 전달하기보다 핵심을 압축해서 공유해야 할 때가 많습니다. 이 게시물은 진행상황, 검토 결과, 참고자료를 보고용으로 정리하는 데 적합합니다.

먼저 핵심 요약본을 만들고,

[[PROMPT:0]]

상황에 따라 보고 대상에 맞는 문안으로 다시 정리할 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 긴 자료를 핵심 보고용으로 요약
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '긴 자료를 핵심 보고용으로 요약',
        '당신은 업무 보고자료 정리 도우미입니다.

아래 자료를 {{summary_format}} 형식으로 요약해주세요.

[원문 또는 자료]
{{source_content}}

[특히 봐야 할 포인트]
{{focus_points}}

조건:
- 핵심 내용 위주로 압축할 것
- 읽는 사람이 빠르게 이해할 수 있게 정리할 것
- 필요 시 주요 이슈와 시사점을 분리할 것',
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
        'source_content',
        '원문 또는 자료',
        '요약할 문서, 메모, 기사, 보고자료 등을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'focus_points',
        '중점 포인트',
        '진행상황, 문제점, 일정, 비용 등 중점적으로 볼 항목을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'summary_format',
        '요약 형식',
        '원하는 결과 형식을 선택하세요',
        'select',
        2,
        NOW()
    );

    -- post_prompt[1]: 보고 대상에 맞춰 문안 재구성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '보고 대상에 맞춰 문안 재구성',
        '아래 내용을 {{audience}}에게 공유하기 좋은 문안으로 재구성해주세요.

[기준 내용]
{{base_text}}

[원하는 목적]
{{sharing_goal}}

조건:
- 해당 대상이 바로 이해할 수 있는 표현으로 정리할 것
- 배경, 현재 상황, 요청사항 또는 참고사항을 구분할 것
- 길지 않게 실무용 문안으로 작성할 것',
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
        '공유 대상',
        '누구에게 공유할지 선택하세요',
        'select',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'base_text',
        '기준 내용',
        '기본이 되는 요약본이나 원문 핵심을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'sharing_goal',
        '공유 목적',
        '단순 공유, 검토 요청, 승인 요청, 참고 전달 등 목적을 입력하세요',
        'text',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 보고용 요약·업무 공유 문안 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 협조 요청·자료 요청 문안 작성 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.760Z
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
        '협조 요청·자료 요청 문안 작성 프롬프트',
        '타부서나 동료에게 자료 제출, 확인 요청, 일정 협조, 업무 지원을 요청할 때 쓰는 정중하고 실무적인 문안을 만드는 프롬프트입니다.',
        '{"업무","협조요청","자료요청","확인요청","커뮤니케이션"}'::text[],
        'public',
        '## 소개

일반 업무에서는 무언가를 직접 처리하는 것만큼 다른 사람에게 적절히 요청하는 것도 중요합니다. 이 게시물은 협조 요청, 자료 요청, 확인 요청 문안을 빠르게 정리할 때 유용합니다.

먼저 요청 초안을 만들고,

[[PROMPT:0]]

필요하면 같은 내용을 재촉하지 않으면서도 일정이 보이게 후속 메시지로 바꿀 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 정중한 협조 요청 문안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '정중한 협조 요청 문안 작성',
        '당신은 실무 협조 요청 문안 작성 도우미입니다.

아래 정보를 바탕으로 협조 요청 문안을 작성해주세요.

[요청 대상]
{{target}}

[요청 내용]
{{request_detail}}

[요청 배경]
{{background}}

[희망 기한]
{{deadline}}

[원하는 톤]
{{tone}}

조건:
- 부담스럽지 않으면서도 요청 내용이 명확하게 드러나게 작성할 것
- 상대가 바로 이해할 수 있도록 항목을 정리할 것
- 필요한 경우 회신 요청 문구도 포함할 것',
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
        'target',
        '요청 대상',
        '동료, 상사, 타부서, 외부업체 등 대상 정보를 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'request_detail',
        '요청 내용',
        '무엇을 요청하는지 구체적으로 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'background',
        '요청 배경',
        '왜 필요한지 배경을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'deadline',
        '희망 기한',
        '회신 또는 자료 제출 기한을 입력하세요',
        'text',
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
        '원하는 요청 문체를 선택하세요',
        'select',
        4,
        NOW()
    );

    -- post_prompt[1]: 후속 리마인드 문안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '후속 리마인드 문안 작성',
        '아래 요청 건에 대해 정중한 후속 리마인드 문안을 작성해주세요.

[기존 요청 내용]
{{previous_request}}

[현재 상황]
{{current_context}}

[리마인드 목적]
{{remind_goal}}

조건:
- 재촉하는 느낌을 줄이면서도 일정과 필요성을 분명히 할 것
- 짧고 명확하게 작성할 것
- 메일용과 메신저용 2가지 버전으로 제시할 것',
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
        'previous_request',
        '기존 요청 내용',
        '이전에 보냈던 요청 내용을 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'current_context',
        '현재 상황',
        '기한 임박, 회신 없음, 추가 확인 필요 등 상황을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'remind_goal',
        '리마인드 목적',
        '회신 요청, 자료 제출 요청, 일정 확인 등 목적을 입력하세요',
        'text',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 협조 요청·자료 요청 문안 작성 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 업무 우선순위·오늘 할 일 정리 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.760Z
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
        '쌓여 있는 업무를 긴급도와 중요도 기준으로 정리하고, 오늘 실제로 끝낼 수 있는 실행 계획으로 바꾸는 범용 생산성 프롬프트입니다.',
        '{"업무","우선순위","할일","생산성","일정관리"}'::text[],
        'public',
        '## 소개

일반 업무에서는 해야 할 일이 많아질수록 무엇부터 처리할지 판단하는 데 시간이 많이 듭니다. 이 게시물은 업무를 재정렬하고 실행 가능한 계획으로 바꾸는 데 초점을 둡니다.

먼저 업무 목록을 우선순위 기준으로 정리하고,

[[PROMPT:0]]

그 결과를 바탕으로 오늘 일정표 형태의 실행 계획으로 전환할 수 있습니다.

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

아래 업무 목록을 보고 {{priority_framework}} 기준으로 우선순위를 정리해주세요.

[업무 목록]
{{task_list}}

[마감 일정 및 제약]
{{constraints}}

[현재 가장 중요한 목표]
{{main_goal}}

조건:
- 먼저 해야 할 업무부터 순서를 제시할 것
- 긴급하지만 중요하지 않은 일과 중요하지만 시간이 필요한 일을 구분할 것
- 보류 가능한 일도 따로 표시할 것',
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
        '현재 해야 할 일을 줄바꿈으로 입력하세요',
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
        '마감 및 제약',
        '오늘 마감, 회의 일정, 외부 의존성 등을 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'main_goal',
        '가장 중요한 목표',
        '오늘 또는 이번 주 가장 중요한 성과를 입력하세요',
        'text',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'priority_framework',
        '정리 기준',
        '원하는 정리 기준을 선택하세요',
        'select',
        3,
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
        '아래 우선순위 정리 결과를 바탕으로 오늘 실행 계획을 짜주세요.

[우선순위 결과]
{{priority_result}}

[사용 가능한 시간]
{{available_time}}

[추가 일정]
{{fixed_schedule}}

조건:
- 실제 끝낼 수 있는 수준으로 계획할 것
- 집중 업무와 단순 업무를 적절히 배치할 것
- 오전/오후 또는 시간대별로 구분할 것
- 마지막에 오늘 꼭 끝내야 할 핵심 3가지를 따로 정리할 것',
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
        '앞 단계에서 정리한 우선순위 결과를 입력하세요',
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
        '사용 가능한 시간',
        '오늘 실제로 업무 가능한 시간을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'fixed_schedule',
        '고정 일정',
        '회의, 외근, 보고 등 이미 잡힌 일정을 입력하세요',
        'textarea',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 업무 우선순위·오늘 할 일 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;

-- ============================================================
-- Bulk Insert: 인수인계·업무 진행상황 정리 프롬프트
-- Source: 2603081116_work.json
-- Generated: 2026-03-08T14:16:58.760Z
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
        '인수인계·업무 진행상황 정리 프롬프트',
        '현재 진행 중인 업무를 다른 사람에게 설명하거나, 스스로도 다시 파악할 수 있도록 상태·이슈·다음 할 일을 정리하는 범용 업무 프롬프트입니다.',
        '{"업무","인수인계","진행상황","업무정리","협업"}'::text[],
        'public',
        '## 소개

휴가, 부재, 담당 변경, 협업 상황에서는 내가 하던 일을 다른 사람이 빠르게 이해할 수 있게 정리해야 합니다. 이 게시물은 업무 현황과 다음 액션을 명확히 정리하는 데 적합합니다.

먼저 인수인계용 현황 정리를 만들고,

[[PROMPT:0]]

필요하면 진행상황 보고용으로 더 짧게 바꿀 수 있습니다.

[[PROMPT:1]]',
        0, 0, 0, 0, false,
        NOW(), NOW()
    )
    RETURNING id INTO v_prompt_id;

    -- 2. post_prompts 생성
    -- post_prompt[0]: 업무 인수인계 문서 초안 작성
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '업무 인수인계 문서 초안 작성',
        '당신은 업무 인수인계 문서 작성 도우미입니다.

아래 내용을 바탕으로 인수인계 문서를 작성해주세요.

[업무명]
{{work_title}}

[현재까지 진행 내용]
{{progress_summary}}

[남은 할 일]
{{remaining_tasks}}

[주의사항 또는 이슈]
{{issues}}

[참고 자료 또는 위치]
{{references}}

조건:
- 처음 보는 사람도 이해할 수 있게 작성할 것
- 현재 상태, 다음 할 일, 유의사항을 명확히 구분할 것
- 너무 장황하지 않게 실무용으로 정리할 것',
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
        'work_title',
        '업무명',
        '인수인계할 업무명을 입력하세요',
        'text',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'progress_summary',
        '진행 내용',
        '현재까지 무엇을 했는지 입력하세요',
        'textarea',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'remaining_tasks',
        '남은 할 일',
        '앞으로 처리해야 할 일을 입력하세요',
        'textarea',
        2,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'issues',
        '이슈 및 주의사항',
        '막힌 부분, 주의할 점, 확인 필요 사항을 입력하세요',
        'textarea',
        3,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_0,
        'references',
        '참고 자료',
        '파일 위치, 링크, 담당자 등 참고 정보를 입력하세요',
        'textarea',
        4,
        NOW()
    );

    -- post_prompt[1]: 진행상황 공유용으로 간단 재정리
    INSERT INTO post_prompts (
        id, prompt_id, title, template_body, sort_order, status,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(),
        v_prompt_id,
        '진행상황 공유용으로 간단 재정리',
        '아래 업무 현황을 {{share_format}} 형식으로 짧게 재정리해주세요.

[업무 현황]
{{work_status}}

[공유 대상]
{{audience}}

조건:
- 핵심만 빠르게 읽히게 정리할 것
- 현재 상태, 이슈, 다음 액션을 포함할 것
- 메신저나 짧은 메일에 붙여넣기 좋은 길이로 작성할 것',
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
        'work_status',
        '업무 현황',
        '인수인계 초안 또는 현재 업무 상태를 입력하세요',
        'textarea',
        0,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'audience',
        '공유 대상',
        '팀장, 동료, 협업자 등 공유 대상을 입력하세요',
        'text',
        1,
        NOW()
    );
    INSERT INTO post_prompt_variables (
        id, post_prompt_id, key, label, description, type, sort_order, created_at
    ) VALUES (
        gen_random_uuid(),
        v_pp_id_1,
        'share_format',
        '공유 형식',
        '원하는 결과 형식을 선택하세요',
        'select',
        2,
        NOW()
    );

    RAISE NOTICE 'INSERT OK: 인수인계·업무 진행상황 정리 프롬프트 (prompt_id=%)', v_prompt_id;
END $$;
