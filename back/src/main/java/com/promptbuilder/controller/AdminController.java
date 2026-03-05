package com.promptbuilder.controller;

import com.promptbuilder.common.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @PostMapping("/prompts/{promptId}/moderate")
    public ResponseEntity<Map<String, Object>> moderate(
            @PathVariable String promptId,
            @RequestBody Map<String, Object> body) {
        String action = (String) body.get("action");
        if (action == null) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("VALID_001", "action은 필수입니다"));
        }
        // (확인 필요) 실제 moderation_actions 테이블에 기록
        return ResponseEntity.ok(
                ApiResponse.ok(Map.of("promptId", promptId, "action", action))
        );
    }
}
