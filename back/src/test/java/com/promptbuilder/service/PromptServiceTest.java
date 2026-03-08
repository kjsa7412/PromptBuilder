package com.promptbuilder.service;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * PromptService 단위 테스트
 */
@ExtendWith(MockitoExtension.class)
class PromptServiceTest {

    @InjectMocks
    private PromptService promptService;

    @Mock
    private com.promptbuilder.mapper.PromptMapper promptMapper;

    @Mock
    private com.promptbuilder.mapper.UsageEventMapper usageEventMapper;

    @Test
    void renderPrompt_shouldReplaceAllVariables() {
        String template = "Hello {{name}}, your role is {{role}}.";
        Map<String, Object> values = Map.of("name", "World", "role", "developer");

        String result = promptService.renderPrompt(template, values);

        assertEquals("Hello World, your role is developer.", result);
    }

    @Test
    void renderPrompt_shouldReplaceWithEmptyStringForMissingOptional() {
        String template = "Hello {{name}}{{optional}}.";
        Map<String, Object> values = Map.of("name", "Alice");

        String result = promptService.renderPrompt(template, values);

        assertEquals("Hello Alice.", result);
    }

    @Test
    void renderPrompt_shouldHandleSpacesInPlaceholder() {
        String template = "Value: {{ key_with_space }}.";
        Map<String, Object> values = Map.of("key_with_space", "test");

        String result = promptService.renderPrompt(template, values);

        assertEquals("Value: test.", result);
    }

    @Test
    void renderPrompt_shouldHandleNullTemplate() {
        String result = promptService.renderPrompt(null, Map.of());
        assertEquals("", result);
    }

    @Test
    void renderPrompt_shouldHandleNoPlaceholders() {
        String template = "Static text with no placeholders.";
        String result = promptService.renderPrompt(template, Map.of());
        assertEquals(template, result);
    }

    @Test
    void renderPrompt_shouldSupportKoreanVariables() {
        String template = "{{이름}}님, {{역할}}로서 작업해주세요.";
        Map<String, Object> values = Map.of("이름", "홍길동", "역할", "개발자");
        String result = promptService.renderPrompt(template, values);
        assertEquals("홍길동님, 개발자로서 작업해주세요.", result);
    }

    @Test
    void renderPrompt_shouldHandleMixedKoreanEnglishVariables() {
        String template = "{{name}}의 {{역할}}은 {{role}}입니다.";
        Map<String, Object> values = Map.of("name", "Alice", "역할", "역할", "role", "developer");
        String result = promptService.renderPrompt(template, values);
        assertEquals("Alice의 역할은 developer입니다.", result);
    }
}
