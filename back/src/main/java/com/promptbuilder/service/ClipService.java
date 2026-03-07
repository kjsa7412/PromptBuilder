package com.promptbuilder.service;

import com.promptbuilder.mapper.ClipMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ClipService {

    @Autowired
    private ClipMapper clipMapper;

    public List<Map<String, Object>> getMyClips(String userId) {
        return clipMapper.findByUserId(userId);
    }

    public void addClip(String userId, String promptId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("promptId", promptId);
        clipMapper.insert(params);
        clipMapper.incrementClipCount(promptId);
    }

    public void removeClip(String userId, String promptId) {
        int count = clipMapper.countByUserAndPrompt(userId, promptId);
        if (count > 0) {
            clipMapper.delete(userId, promptId);
            clipMapper.decrementClipCount(promptId);
        }
    }

    public boolean isClipped(String userId, String promptId) {
        return clipMapper.countByUserAndPrompt(userId, promptId) > 0;
    }
}
