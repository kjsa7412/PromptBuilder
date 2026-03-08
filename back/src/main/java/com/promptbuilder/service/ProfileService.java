package com.promptbuilder.service;

import com.promptbuilder.mapper.ProfileMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class ProfileService {

    private static final String[] ADJECTIVES = {"부끄러운", "용감한", "귀여운", "재빠른", "느긋한", "활발한", "영리한", "다정한", "씩씩한", "호기심 많은"};
    private static final String[] ANIMALS = {"여우", "토끼", "고양이", "강아지", "판다", "원숭이", "코끼리", "기린", "펭귄", "수달"};
    private static final java.util.Random RANDOM = new java.util.Random();

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

    public String generateRandomNickname() {
        return ADJECTIVES[RANDOM.nextInt(ADJECTIVES.length)] + " " + ANIMALS[RANDOM.nextInt(ANIMALS.length)];
    }

    public Map<String, Object> getProfile(String userId) {
        Map<String, Object> profile = profileMapper.findByUserId(userId);
        if (profile == null) {
            String nickname = generateRandomNickname();
            Map<String, Object> params = new HashMap<>();
            params.put("userId", userId);
            params.put("username", nickname.replace(" ", "_").toLowerCase());
            params.put("displayName", nickname);
            params.put("avatarUrl", null);
            profileMapper.upsert(params);
            profile = profileMapper.findByUserId(userId);
        }
        return profile;
    }

    public Map<String, Object> updateProfile(String userId, Map<String, Object> body) {
        String username = body.containsKey("username") ? (String) body.get("username") : null;
        String displayName = body.containsKey("displayName") ? (String) body.get("displayName") : null;
        String avatarUrl = body.containsKey("avatarUrl") ? (String) body.get("avatarUrl") : null;

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("username", username);
        params.put("displayName", displayName);
        params.put("avatarUrl", avatarUrl);
        profileMapper.updateProfile(params);
        return profileMapper.findByUserId(userId);
    }
}
