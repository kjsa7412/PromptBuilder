package com.promptbuilder.security;

import com.promptbuilder.service.ProfileService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtValidator jwtValidator;
    private final ProfileService profileService;

    public JwtAuthenticationFilter(JwtValidator jwtValidator, ProfileService profileService) {
        this.jwtValidator = jwtValidator;
        this.profileService = profileService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            Map<String, Object> claims = null;

            // 1단계: JWT 검증 — 실패 시 익명으로 처리
            try {
                claims = jwtValidator.validate(token);
                String userId = (String) claims.get("sub");
                String role = extractRole(claims);

                UsernamePasswordAuthenticationToken auth =
                        new UsernamePasswordAuthenticationToken(
                                userId,
                                null,
                                List.of(new SimpleGrantedAuthority("ROLE_" + role))
                        );
                auth.setDetails(claims);
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (Exception e) {
                SecurityContextHolder.clearContext();
            }

            // 2단계: 프로필 upsert — JWT 인증과 독립적으로 실행 (실패해도 인증 유지)
            if (claims != null) {
                try {
                    profileService.upsertFromJwt(claims);
                } catch (Exception ignored) {
                    // 프로필 upsert 실패는 요청 처리에 영향 없음
                }
            }
        }

        filterChain.doFilter(request, response);
    }

    @SuppressWarnings("unchecked")
    private String extractRole(Map<String, Object> claims) {
        Object appMeta = claims.get("app_metadata");
        if (appMeta instanceof Map) {
            Object role = ((Map<String, Object>) appMeta).get("role");
            if ("admin".equals(role)) return "ADMIN";
        }
        return "USER";
    }
}
