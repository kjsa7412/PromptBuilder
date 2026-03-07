package com.promptbuilder.service;

import com.promptbuilder.mapper.LikeMapper;
import com.promptbuilder.mapper.PromptMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class LikeService {

    @Autowired
    private LikeMapper likeMapper;

    @Autowired
    private PromptMapper promptMapper;

    public List<Map<String, Object>> getMyLikes(String userId) {
        return likeMapper.findByUserId(userId);
    }

    public Map<String, Object> addLike(String userId, String promptId) {
        int exists = likeMapper.countByUserAndPrompt(userId, promptId);
        if (exists > 0) {
            return Map.of("promptId", promptId, "liked", true, "alreadyLiked", true);
        }
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("promptId", promptId);
        likeMapper.insert(params);
        // like_count 증가
        try {
            Map<String, Object> updateParams = new HashMap<>();
            updateParams.put("id", promptId);
            updateParams.put("delta", 1);
            promptMapper.incrementLikeCount(updateParams);
        } catch (Exception ignored) {}
        return Map.of("promptId", promptId, "liked", true);
    }

    public void removeLike(String userId, String promptId) {
        int exists = likeMapper.countByUserAndPrompt(userId, promptId);
        if (exists > 0) {
            likeMapper.delete(userId, promptId);
            // like_count 감소
            try {
                Map<String, Object> updateParams = new HashMap<>();
                updateParams.put("id", promptId);
                updateParams.put("delta", -1);
                promptMapper.incrementLikeCount(updateParams);
            } catch (Exception ignored) {}
        }
    }

    public boolean isLiked(String userId, String promptId) {
        return likeMapper.countByUserAndPrompt(userId, promptId) > 0;
    }
}
