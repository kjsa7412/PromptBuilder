package com.promptbuilder.service;

import com.promptbuilder.common.ApiException;
import com.promptbuilder.mapper.PromptMapper;
import com.promptbuilder.mapper.UsageEventMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class PromptService {

    private static final Pattern PLACEHOLDER_PATTERN =
            Pattern.compile("\\{\\{\\s*([a-zA-Z0-9_]+)\\s*\\}\\}");

    @Autowired
    private PromptMapper promptMapper;

    @Autowired
    private UsageEventMapper usageEventMapper;

    @Value("${app.rate-limit.generate-daily-per-user:50}")
    private int generateDailyLimitPerUser;

    public List<Map<String, Object>> getTrending(int limit) {
        return promptMapper.findTrending(Math.min(limit, 50));
    }

    public List<Map<String, Object>> getRandom(int limit) {
        return promptMapper.findRandom(Math.min(limit, 50));
    }

    public List<Map<String, Object>> getNew(int limit) {
        return promptMapper.findNew(Math.min(limit, 50));
    }

    public Map<String, Object> search(String q, String tag, String sort, int page, int size) {
        int offset = page * size;
        List<Map<String, Object>> items = promptMapper.search(q, tag, sort, offset, size);
        long total = promptMapper.countSearch(q, tag);

        Map<String, Object> result = new HashMap<>();
        result.put("items", items);
        result.put("total", total);
        result.put("page", page);
        result.put("size", size);
        return result;
    }

    public Map<String, Object> getDetail(String promptId) {
        Map<String, Object> prompt = promptMapper.findById(promptId);
        if (prompt == null) {
            throw ApiException.notFound("프롬프트를 찾을 수 없습니다");
        }

        // 변수 목록 추가
        String versionId = (String) prompt.get("version_id");
        if (versionId != null) {
            List<Map<String, Object>> variables = promptMapper.findVariablesByVersionId(versionId);
            prompt.put("variables", variables);
        } else {
            prompt.put("variables", Collections.emptyList());
        }

        return prompt;
    }

    /**
     * Generate 처리:
     * 1. 일일 제한 확인
     * 2. 프롬프트 로드 및 변수 치환
     * 3. usage_events 기록
     * 4. generate_count 증가
     */
    public Map<String, Object> generate(String promptId, Map<String, Object> body,
                                         String userId, String sessionId, String ip) {
        // 일일 제한 확인
        if (userId != null) {
            int todayCount = usageEventMapper.countGenerateByUserToday(userId);
            if (todayCount >= generateDailyLimitPerUser) {
                throw ApiException.tooManyRequests("일일 Generate 한도를 초과했습니다");
            }
        }

        Map<String, Object> prompt = promptMapper.findById(promptId);
        if (prompt == null) {
            throw ApiException.notFound("프롬프트를 찾을 수 없습니다");
        }

        String templateBody = (String) prompt.get("template_body");
        if (templateBody == null) templateBody = "";

        @SuppressWarnings("unchecked")
        Map<String, Object> values = body.containsKey("values")
                ? (Map<String, Object>) body.get("values")
                : Collections.emptyMap();

        // 변수 목록 로드
        String versionId = (String) prompt.get("version_id");
        List<Map<String, Object>> variables = versionId != null
                ? promptMapper.findVariablesByVersionId(versionId)
                : Collections.emptyList();

        // 필수 변수 미입력 검사
        List<String> missingRequired = new ArrayList<>();
        for (Map<String, Object> variable : variables) {
            Boolean required = (Boolean) variable.get("required");
            String key = (String) variable.get("key");
            if (Boolean.TRUE.equals(required)) {
                Object val = values.get(key);
                if (val == null || val.toString().isBlank()) {
                    missingRequired.add(key);
                }
            }
        }

        // 템플릿 치환
        String rendered = renderPrompt(templateBody, values);

        // usage_events 기록
        Map<String, Object> eventParams = new HashMap<>();
        eventParams.put("promptId", promptId);
        eventParams.put("versionId", versionId);
        eventParams.put("userId", userId);
        eventParams.put("sessionId", sessionId);
        eventParams.put("eventType", "generate");
        eventParams.put("ipAddress", ip != null ? ip : "0.0.0.0");

        try {
            usageEventMapper.insert(eventParams);
            promptMapper.incrementGenerateCount(promptId);
        } catch (Exception e) {
            // 이벤트 기록 실패해도 generate는 성공
        }

        Map<String, Object> result = new HashMap<>();
        result.put("renderedPrompt", rendered);
        result.put("missingRequired", missingRequired);
        return result;
    }

    /**
     * 템플릿의 {{key}} 를 values로 치환한다.
     */
    public String renderPrompt(String template, Map<String, Object> values) {
        if (template == null) return "";
        Matcher matcher = PLACEHOLDER_PATTERN.matcher(template);
        StringBuffer sb = new StringBuffer();
        while (matcher.find()) {
            String key = matcher.group(1);
            Object val = values.get(key);
            matcher.appendReplacement(sb, val != null ? val.toString() : "");
        }
        matcher.appendTail(sb);
        return sb.toString();
    }
}
