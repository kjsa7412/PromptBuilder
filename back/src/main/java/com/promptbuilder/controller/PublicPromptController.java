package com.promptbuilder.controller;

import com.promptbuilder.common.ApiResponse;
import com.promptbuilder.service.PromptService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/public/prompts")
public class PublicPromptController {

    @Autowired
    private PromptService promptService;

    @GetMapping("/trending")
    public ResponseEntity<Map<String, Object>> trending(
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(ApiResponse.ok(promptService.getTrending(limit)));
    }

    @GetMapping("/random")
    public ResponseEntity<Map<String, Object>> random(
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(ApiResponse.ok(promptService.getRandom(limit)));
    }

    @GetMapping("/new")
    public ResponseEntity<Map<String, Object>> newPrompts(
            @RequestParam(defaultValue = "20") int limit) {
        return ResponseEntity.ok(ApiResponse.ok(promptService.getNew(limit)));
    }

    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String tag,
            @RequestParam(defaultValue = "new") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        Map<String, Object> result = promptService.search(q, tag, sort, page, size);
        Map<String, Object> meta = ApiResponse.meta(
                (long) result.get("total"), page, size);
        return ResponseEntity.ok(ApiResponse.ok(result.get("items"), meta));
    }

    @GetMapping("/{promptId}")
    public ResponseEntity<Map<String, Object>> detail(@PathVariable String promptId) {
        return ResponseEntity.ok(ApiResponse.ok(promptService.getDetail(promptId)));
    }

    @PostMapping("/{promptId}/generate")
    public ResponseEntity<Map<String, Object>> generate(
            @PathVariable String promptId,
            @RequestBody(required = false) Map<String, Object> body,
            Authentication auth,
            HttpServletRequest request) {

        if (body == null) body = Map.of();

        String userId = auth != null ? (String) auth.getPrincipal() : null;
        String sessionId = (String) body.getOrDefault("sessionId", null);
        String ip = request.getRemoteAddr();

        return ResponseEntity.ok(
                ApiResponse.ok(promptService.generate(promptId, body, userId, sessionId, ip))
        );
    }
}
