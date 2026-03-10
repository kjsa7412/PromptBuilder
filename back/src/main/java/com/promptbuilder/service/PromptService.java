package com.promptbuilder.service;

import com.promptbuilder.common.ApiException;
import com.promptbuilder.mapper.PromptMapper;
import com.promptbuilder.mapper.UsageEventMapper;
import org.springframework.context.annotation.Lazy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

@Service
public class PromptService {

    private static final Pattern PLACEHOLDER_PATTERN =
            Pattern.compile("\\{\\{\\s*([a-zA-Z0-9_가-힣]+)\\s*\\}\\}");

    @Autowired
    private PromptMapper promptMapper;

    @Autowired
    private UsageEventMapper usageEventMapper;

    @Autowired
    @Lazy
    private PostPromptService postPromptService;

    @Value("${app.rate-limit.generate-daily-per-user:50}")
    private int generateDailyLimitPerUser;

    public Map<String, Object> createPrompt(String userId, Map<String, Object> body) {
        String title = (String) body.get("title");
        String description = body.containsKey("description") ? (String) body.get("description") : null;
        String templateBody = body.containsKey("templateBody") ? (String) body.get("templateBody") : "";
        String visibility = body.containsKey("visibility") ? (String) body.get("visibility") : "draft";
        String bodyMarkdown = body.containsKey("bodyMarkdown") ? (String) body.get("bodyMarkdown") : null;

        String promptId = UUID.randomUUID().toString();
        String versionId = UUID.randomUUID().toString();

        // tags 파싱
        @SuppressWarnings("unchecked")
        List<String> tagList = body.containsKey("tags") ? (List<String>) body.get("tags") : List.of();
        String tagsArray = null;
        if (!tagList.isEmpty()) {
            tagsArray = "{" + tagList.stream()
                .map(t -> "\"" + t.replace("\"", "\\\"") + "\"")
                .collect(Collectors.joining(",")) + "}";
        }

        // 1. prompts 생성
        Map<String, Object> promptParams = new HashMap<>();
        promptParams.put("id", promptId);
        promptParams.put("userId", userId);
        promptParams.put("title", title);
        promptParams.put("description", description);
        promptParams.put("tags", tagsArray);
        promptParams.put("visibility", visibility);
        promptParams.put("bodyMarkdown", bodyMarkdown);
        promptMapper.insertPrompt(promptParams);

        // 2. prompt_versions 생성
        Map<String, Object> versionParams = new HashMap<>();
        versionParams.put("id", versionId);
        versionParams.put("promptId", promptId);
        versionParams.put("templateBody", templateBody);
        promptMapper.insertVersion(versionParams);

        // 3. current_version_id 업데이트
        Map<String, Object> cvParams = new HashMap<>();
        cvParams.put("promptId", promptId);
        cvParams.put("versionId", versionId);
        promptMapper.setCurrentVersion(cvParams);

        // 4. 변수 파싱 후 저장
        Matcher matcher = PLACEHOLDER_PATTERN.matcher(templateBody != null ? templateBody : "");
        Set<String> seen = new LinkedHashSet<>();
        while (matcher.find()) seen.add(matcher.group(1));

        int order = 0;
        for (String key : seen) {
            Map<String, Object> varParams = new HashMap<>();
            varParams.put("promptId", promptId);
            varParams.put("versionId", versionId);
            varParams.put("key", key);
            varParams.put("sortOrder", order++);
            promptMapper.insertVariable(varParams);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("id", promptId);
        result.put("versionId", versionId);
        return result;
    }

    public List<Map<String, Object>> getMyPrompts(String userId) {
        return promptMapper.findMyPrompts(userId);
    }

    public List<Map<String, Object>> getTrending(int limit, int offset) {
        return promptMapper.findTrending(Math.min(limit, 50), offset);
    }

    public List<Map<String, Object>> getRandom(int limit) {
        return promptMapper.findRandom(Math.min(limit, 50));
    }

    public List<Map<String, Object>> getNew(int limit, int offset) {
        return promptMapper.findNew(Math.min(limit, 50), offset);
    }

    public Map<String, Object> search(String q, String tag, String author, String sort, int page, int size) {
        int offset = page * size;
        List<Map<String, Object>> items = promptMapper.search(q, tag, author, sort, offset, size);
        long total = promptMapper.countSearch(q, tag, author);

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
        // MyBatis camelCase mapping: "version_id" alias -> "versionId" key; UUID type -> toString
        Object versionIdObj = prompt.get("versionId");
        if (versionIdObj == null) versionIdObj = prompt.get("version_id");
        String versionId = versionIdObj != null ? versionIdObj.toString() : null;
        if (versionId != null) {
            List<Map<String, Object>> variables = promptMapper.findVariablesByVersionId(versionId);
            prompt.put("variables", variables);
        } else {
            prompt.put("variables", Collections.emptyList());
        }

        // post_prompts 포함
        List<Map<String, Object>> postPrompts = postPromptService.getByPromptId(promptId);
        prompt.put("postPrompts", postPrompts);

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

        // MyBatis camelCase mapping: "template_body" -> "templateBody"
        Object templateBodyObj = prompt.get("templateBody");
        if (templateBodyObj == null) templateBodyObj = prompt.get("template_body");
        String templateBody = templateBodyObj != null ? templateBodyObj.toString() : "";

        @SuppressWarnings("unchecked")
        Map<String, Object> values = body.containsKey("values")
                ? (Map<String, Object>) body.get("values")
                : Collections.emptyMap();

        // 변수 목록 로드
        // MyBatis camelCase mapping: "version_id" alias -> "versionId"; UUID type -> toString
        Object versionIdObj = prompt.get("versionId");
        if (versionIdObj == null) versionIdObj = prompt.get("version_id");
        String versionId = versionIdObj != null ? versionIdObj.toString() : null;
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

    public Map<String, Object> updatePrompt(String userId, String promptId, Map<String, Object> body) {
        String title = (String) body.getOrDefault("title", "");
        if (title.isBlank()) throw new IllegalArgumentException("title은 필수입니다");

        String description = (String) body.get("description");
        String visibility = (String) body.getOrDefault("visibility", "draft");
        String bodyMarkdown = (String) body.get("bodyMarkdown");

        @SuppressWarnings("unchecked")
        List<String> tagList = body.containsKey("tags") ? (List<String>) body.get("tags") : List.of();
        String tagsArray = null;
        if (!tagList.isEmpty()) {
            tagsArray = "{" + tagList.stream()
                .map(t -> "\"" + t.replace("\"", "\\\"") + "\"")
                .collect(Collectors.joining(",")) + "}";
        }

        Map<String, Object> params = new HashMap<>();
        params.put("id", promptId);
        params.put("userId", userId);
        params.put("title", title);
        params.put("description", description);
        params.put("tags", tagsArray);
        params.put("bodyMarkdown", bodyMarkdown);
        params.put("visibility", visibility);
        promptMapper.updatePromptFull(params);

        Map<String, Object> result = new HashMap<>();
        result.put("id", promptId);
        return result;
    }

    public void deletePrompt(String userId, String promptId) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", promptId);
        params.put("userId", userId);
        promptMapper.softDeletePrompt(params);
    }

    public Map<String, Object> updateVisibility(String userId, String promptId, String visibility) {
        if (!List.of("public", "private", "draft").contains(visibility)) {
            throw new IllegalArgumentException("유효하지 않은 visibility 값입니다");
        }
        Map<String, Object> params = new HashMap<>();
        params.put("id", promptId);
        params.put("userId", userId);
        params.put("visibility", visibility);
        promptMapper.updateVisibility(params);
        Map<String, Object> result = new HashMap<>();
        result.put("id", promptId);
        result.put("visibility", visibility);
        return result;
    }

    public Map<String, Object> getDetailForOwner(String promptId, String userId) {
        Map<String, Object> params = new HashMap<>();
        params.put("id", promptId);
        params.put("userId", userId);
        Map<String, Object> prompt = promptMapper.findByIdForOwner(params);
        if (prompt == null) {
            throw ApiException.notFound("프롬프트를 찾을 수 없습니다");
        }

        Object versionIdObj = prompt.get("versionId");
        if (versionIdObj == null) versionIdObj = prompt.get("version_id");
        String versionId = versionIdObj != null ? versionIdObj.toString() : null;
        if (versionId != null) {
            List<Map<String, Object>> variables = promptMapper.findVariablesByVersionId(versionId);
            prompt.put("variables", variables);
        } else {
            prompt.put("variables", Collections.emptyList());
        }

        List<Map<String, Object>> postPrompts = postPromptService.getByPromptId(promptId);
        prompt.put("postPrompts", postPrompts);
        return prompt;
    }

    /**
     * 템플릿의 {{key}} 를 values로 치환한다.
     */
    public List<Map<String, Object>> getTagsWithCount() {
        return promptMapper.findTagsWithCount();
    }

    public Map<String, Object> getStats() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalPrompts", promptMapper.countPublic());
        return stats;
    }

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
