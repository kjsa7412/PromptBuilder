package com.promptbuilder.service;

import com.promptbuilder.common.ApiException;
import com.promptbuilder.mapper.PostPromptMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class PostPromptService {

    private static final Pattern PLACEHOLDER_PATTERN =
            Pattern.compile("\\{\\{\\s*([a-zA-Z0-9_가-힣]+)\\s*\\}\\}");

    @Autowired
    private PostPromptMapper postPromptMapper;

    public List<Map<String, Object>> getByPromptId(String promptId) {
        List<Map<String, Object>> postPrompts = postPromptMapper.findByPromptId(promptId);
        for (Map<String, Object> pp : postPrompts) {
            Object ppId = pp.get("id");
            if (ppId != null) {
                List<Map<String, Object>> vars = postPromptMapper.findVariablesByPostPromptId(ppId.toString());
                pp.put("variables", vars);
            }
        }
        return postPrompts;
    }

    public Map<String, Object> create(String promptId, Map<String, Object> body) {
        String id = UUID.randomUUID().toString();
        String title = body.containsKey("title") ? (String) body.get("title") : "새 프롬프트";
        String templateBody = body.containsKey("templateBody") ? (String) body.get("templateBody") : "";
        int sortOrder = body.containsKey("sortOrder") ? ((Number) body.get("sortOrder")).intValue() :
                        (int) postPromptMapper.countByPromptId(promptId);
        String status = body.containsKey("status") ? (String) body.get("status") : "draft";

        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("promptId", promptId);
        params.put("title", title);
        params.put("templateBody", templateBody);
        params.put("sortOrder", sortOrder);
        params.put("status", status);
        postPromptMapper.insert(params);

        saveVariables(id, templateBody, body);

        return postPromptMapper.findById(id);
    }

    public Map<String, Object> update(String promptId, String id, Map<String, Object> body) {
        Map<String, Object> existing = postPromptMapper.findById(id);
        if (existing == null) throw ApiException.notFound("세부 프롬프트를 찾을 수 없습니다");

        String title = body.containsKey("title") ? (String) body.get("title") : (String) existing.get("title");
        String templateBody = body.containsKey("templateBody") ? (String) body.get("templateBody") :
                              (String) existing.get("templateBody");
        int sortOrder = body.containsKey("sortOrder") ? ((Number) body.get("sortOrder")).intValue() :
                        ((Number) existing.get("sortOrder")).intValue();
        String status = body.containsKey("status") ? (String) body.get("status") : (String) existing.get("status");

        Map<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("promptId", promptId);
        params.put("title", title);
        params.put("templateBody", templateBody);
        params.put("sortOrder", sortOrder);
        params.put("status", status);
        postPromptMapper.update(params);

        postPromptMapper.deleteVariablesByPostPromptId(id);
        saveVariables(id, templateBody, body);

        Map<String, Object> result = postPromptMapper.findById(id);
        if (result != null) {
            result.put("variables", postPromptMapper.findVariablesByPostPromptId(id));
        }
        return result;
    }

    public void delete(String promptId, String id) {
        postPromptMapper.deleteVariablesByPostPromptId(id);
        postPromptMapper.delete(id, promptId);
    }

    @SuppressWarnings("unchecked")
    private void saveVariables(String postPromptId, String templateBody, Map<String, Object> body) {
        List<Map<String, Object>> varDescs = body.containsKey("variables") ?
                (List<Map<String, Object>>) body.get("variables") : null;

        Set<String> seen = new LinkedHashSet<>();
        if (templateBody != null) {
            Matcher m = PLACEHOLDER_PATTERN.matcher(templateBody);
            while (m.find()) seen.add(m.group(1));
        }

        int order = 0;
        for (String key : seen) {
            String label = key;
            String description = null;
            String type = "text";

            if (varDescs != null) {
                for (Map<String, Object> vd : varDescs) {
                    if (key.equals(vd.get("key"))) {
                        if (vd.get("label") != null) label = (String) vd.get("label");
                        if (vd.get("description") != null) description = (String) vd.get("description");
                        if (vd.get("type") != null) type = (String) vd.get("type");
                        break;
                    }
                }
            }

            Map<String, Object> varParams = new HashMap<>();
            varParams.put("postPromptId", postPromptId);
            varParams.put("key", key);
            varParams.put("label", label);
            varParams.put("description", description);
            varParams.put("type", type);
            varParams.put("sortOrder", order++);
            postPromptMapper.insertVariable(varParams);
        }
    }
}
