package com.promptbuilder.controller;

import com.promptbuilder.common.ApiResponse;
import com.promptbuilder.service.ClipService;
import com.promptbuilder.service.PostPromptService;
import com.promptbuilder.service.LikeService;
import com.promptbuilder.service.PromptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/me")
public class MeController {

    @Autowired
    private ClipService clipService;

    @Autowired
    private PostPromptService postPromptService;

    @Autowired
    private LikeService likeService;

    @Autowired
    private PromptService promptService;

    private String getUserId(Authentication auth) {
        return (String) auth.getPrincipal();
    }

    @GetMapping("/clips")
    public ResponseEntity<Map<String, Object>> getClips(Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(clipService.getMyClips(getUserId(auth))));
    }

    @PostMapping("/clips/{promptId}")
    public ResponseEntity<Map<String, Object>> addClip(
            @PathVariable String promptId, Authentication auth) {
        clipService.addClip(getUserId(auth), promptId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(Map.of("promptId", promptId)));
    }

    @DeleteMapping("/clips/{promptId}")
    public ResponseEntity<Void> removeClip(
            @PathVariable String promptId, Authentication auth) {
        clipService.removeClip(getUserId(auth), promptId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/likes")
    public ResponseEntity<Map<String, Object>> getLikes(Authentication auth) {
        String userId = getUserId(auth);
        return ResponseEntity.ok(ApiResponse.ok(likeService.getMyLikes(userId)));
    }

    @PostMapping("/likes/{promptId}")
    public ResponseEntity<Map<String, Object>> addLike(
            @PathVariable String promptId, Authentication auth) {
        String userId = getUserId(auth);
        Map<String, Object> result = likeService.addLike(userId, promptId);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(result));
    }

    @DeleteMapping("/likes/{promptId}")
    public ResponseEntity<Void> removeLike(
            @PathVariable String promptId, Authentication auth) {
        String userId = getUserId(auth);
        likeService.removeLike(userId, promptId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/prompts")
    public ResponseEntity<Map<String, Object>> getMyPrompts(Authentication auth) {
        String userId = getUserId(auth);
        List<Map<String, Object>> prompts = promptService.getMyPrompts(userId);
        return ResponseEntity.ok(ApiResponse.ok(prompts));
    }

    @PostMapping("/prompts")
    public ResponseEntity<Map<String, Object>> createPrompt(
            @RequestBody Map<String, Object> body, Authentication auth) {
        String title = (String) body.get("title");
        if (title == null || title.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("VALID_001", "title은 필수입니다"));
        }
        String userId = getUserId(auth);
        Map<String, Object> created = promptService.createPrompt(userId, body);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @GetMapping("/prompts/{promptId}/post-prompts")
    public ResponseEntity<Map<String, Object>> getPostPrompts(
            @PathVariable String promptId, Authentication auth) {
        return ResponseEntity.ok(ApiResponse.ok(postPromptService.getByPromptId(promptId)));
    }

    @PostMapping("/prompts/{promptId}/post-prompts")
    public ResponseEntity<Map<String, Object>> createPostPrompt(
            @PathVariable String promptId,
            @RequestBody Map<String, Object> body, Authentication auth) {
        Map<String, Object> created = postPromptService.create(promptId, body);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(created));
    }

    @PutMapping("/prompts/{promptId}/post-prompts/{id}")
    public ResponseEntity<Map<String, Object>> updatePostPrompt(
            @PathVariable String promptId,
            @PathVariable String id,
            @RequestBody Map<String, Object> body, Authentication auth) {
        Map<String, Object> updated = postPromptService.update(promptId, id, body);
        return ResponseEntity.ok(ApiResponse.ok(updated));
    }

    @DeleteMapping("/prompts/{promptId}/post-prompts/{id}")
    public ResponseEntity<Void> deletePostPrompt(
            @PathVariable String promptId,
            @PathVariable String id, Authentication auth) {
        postPromptService.delete(promptId, id);
        return ResponseEntity.noContent().build();
    }
}
