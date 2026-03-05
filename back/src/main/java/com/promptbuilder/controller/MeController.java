package com.promptbuilder.controller;

import com.promptbuilder.common.ApiResponse;
import com.promptbuilder.service.BookmarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/me")
public class MeController {

    @Autowired
    private BookmarkService bookmarkService;

    private String getUserId(Authentication auth) {
        return (String) auth.getPrincipal();
    }

    @GetMapping("/bookmarks")
    public ResponseEntity<Map<String, Object>> getBookmarks(Authentication auth) {
        String userId = getUserId(auth);
        return ResponseEntity.ok(ApiResponse.ok(bookmarkService.getMyBookmarks(userId)));
    }

    @PostMapping("/bookmarks/{promptId}")
    public ResponseEntity<Map<String, Object>> addBookmark(
            @PathVariable String promptId, Authentication auth) {
        String userId = getUserId(auth);
        bookmarkService.addBookmark(userId, promptId);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(Map.of("promptId", promptId)));
    }

    @DeleteMapping("/bookmarks/{promptId}")
    public ResponseEntity<Void> removeBookmark(
            @PathVariable String promptId, Authentication auth) {
        String userId = getUserId(auth);
        bookmarkService.removeBookmark(userId, promptId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/prompts")
    public ResponseEntity<Map<String, Object>> createPrompt(
            @RequestBody Map<String, Object> body, Authentication auth) {
        // 최소 스켈레톤: title 필수
        String title = (String) body.get("title");
        if (title == null || title.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("VALID_001", "title은 필수입니다"));
        }
        // (확인 필요) 실제 구현 시 PromptService.createDraft() 호출
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(Map.of("message", "draft created (stub)")));
    }

    @PostMapping("/prompts/{promptId}/publish")
    public ResponseEntity<Map<String, Object>> publishPrompt(
            @PathVariable String promptId,
            @RequestBody(required = false) Map<String, Object> body,
            Authentication auth) {
        // (확인 필요) 실제 구현 시 visibility 변경
        return ResponseEntity.ok(ApiResponse.ok(Map.of("promptId", promptId, "status", "published")));
    }
}
