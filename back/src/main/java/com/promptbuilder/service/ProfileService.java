package com.promptbuilder.service;

import com.promptbuilder.mapper.ProfileMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class ProfileService {

    @Autowired
    private ProfileMapper profileMapper;

    /**
     * JWT 검증 성공 시 호출 — 프로필이 없으면 생성, 있으면 updated_at 갱신
     * claims: Supabase JWT payload (sub, email, user_metadata 등)
     */
    public void upsertFromJwt(Map<String, Object> claims) {
        String userId = (String) claims.get("sub");
        if (userId == null) return;

        String displayName = extractDisplayName(claims);
        String avatarUrl = extractAvatarUrl(claims);

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("displayName", displayName);
        params.put("avatarUrl", avatarUrl);

        profileMapper.upsert(params);
    }

    @SuppressWarnings("unchecked")
    private String extractDisplayName(Map<String, Object> claims) {
        // Supabase JWT: user_metadata.full_name 또는 email 앞부분 사용
        Object meta = claims.get("user_metadata");
        if (meta instanceof Map) {
            Object name = ((Map<String, Object>) meta).get("full_name");
            if (name instanceof String && !((String) name).isBlank()) {
                return (String) name;
            }
        }
        String email = (String) claims.get("email");
        if (email != null && email.contains("@")) {
            return email.substring(0, email.indexOf('@'));
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    private String extractAvatarUrl(Map<String, Object> claims) {
        Object meta = claims.get("user_metadata");
        if (meta instanceof Map) {
            Object url = ((Map<String, Object>) meta).get("avatar_url");
            return url instanceof String ? (String) url : null;
        }
        return null;
    }
}
