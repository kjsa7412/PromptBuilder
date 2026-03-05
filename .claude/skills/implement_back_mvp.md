# Skill: implement_back_mvp

## 목적
Spring Boot + MyBatis(Map) MVP API를 구현한다.

## 레이어 구조
```
Controller → Service → Mapper(MyBatis XML) → PostgreSQL
```

## MyBatis Map-only 규칙
```java
// Mapper 인터페이스
@Mapper
public interface PromptMapper {
    List<Map<String, Object>> findTrending(@Param("limit") int limit);
    Map<String, Object> findById(@Param("id") String id);
}

// Service
List<Map<String, Object>> trending = mapper.findTrending(20);
```

## JWT 검증
```java
// JwtFilter: Authorization 헤더에서 Bearer 토큰 추출
// JwksValidator: SUPABASE_JWKS_URL로 공개키 가져와 RS256 검증
// SecurityContext에 userId(sub), role(app_metadata.role) 저장
```

## 에러 응답
```java
// ApiResponse.error("AUTH_001", "인증 토큰이 유효하지 않습니다")
{ "code": "AUTH_001", "message": "...", "details": {} }
```

## 최소 테스트
```java
@SpringBootTest
class PromptServiceTest {
    @Test
    void renderPrompt_shouldReplaceAllVariables() {
        String rendered = service.renderPrompt("Hello {{name}}", Map.of("name", "World"));
        assertEquals("Hello World", rendered);
    }
}
```
