package com.promptbuilder.controller;

import com.promptbuilder.common.ApiResponse;
import com.promptbuilder.service.PromptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/public")
public class PublicStatsController {

    @Autowired
    private PromptService promptService;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        return ResponseEntity.ok(ApiResponse.ok(promptService.getStats()));
    }
}
