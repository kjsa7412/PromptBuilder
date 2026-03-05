package com.promptbuilder.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.RSAPublicKeySpec;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.math.BigInteger;

@Component
public class JwtValidator {

    @Value("${jwt.jwks-url}")
    private String jwksUrl;

    @Value("${jwt.issuer}")
    private String issuer;

    @Value("${jwt.audience}")
    private String audience;

    private final ObjectMapper objectMapper = new ObjectMapper();

    /**
     * JWT를 검증하고 Claims를 Map으로 반환한다.
     * JWKS에서 공개키를 가져와 RS256 검증 수행.
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> validate(String token) {
        try {
            PublicKey publicKey = fetchPublicKey(token);
            Claims claims = Jwts.parser()
                    .verifyWith((java.security.interfaces.RSAPublicKey) publicKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            // issuer 검증
            if (!issuer.equals(claims.getIssuer())) {
                throw new RuntimeException("Invalid issuer");
            }

            Map<String, Object> result = new HashMap<>(claims);
            return result;
        } catch (Exception e) {
            throw new RuntimeException("JWT validation failed: " + e.getMessage(), e);
        }
    }

    @SuppressWarnings("unchecked")
    private PublicKey fetchPublicKey(String token) throws Exception {
        // JWT 헤더에서 kid 추출
        String[] parts = token.split("\\.");
        if (parts.length < 2) throw new RuntimeException("Invalid JWT format");

        String headerJson = new String(Base64.getUrlDecoder().decode(parts[0]));
        Map<String, Object> header = objectMapper.readValue(headerJson, Map.class);
        String kid = (String) header.get("kid");

        // JWKS에서 공개키 가져오기
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(jwksUrl))
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        Map<String, Object> jwks = objectMapper.readValue(response.body(), Map.class);
        List<Map<String, Object>> keys = (List<Map<String, Object>>) jwks.get("keys");

        for (Map<String, Object> key : keys) {
            if (kid == null || kid.equals(key.get("kid"))) {
                return buildPublicKey(key);
            }
        }
        throw new RuntimeException("No matching key found for kid: " + kid);
    }

    private PublicKey buildPublicKey(Map<String, Object> jwk) throws Exception {
        String n = (String) jwk.get("n");
        String e = (String) jwk.get("e");

        BigInteger modulus = new BigInteger(1, Base64.getUrlDecoder().decode(n));
        BigInteger exponent = new BigInteger(1, Base64.getUrlDecoder().decode(e));

        RSAPublicKeySpec spec = new RSAPublicKeySpec(modulus, exponent);
        KeyFactory factory = KeyFactory.getInstance("RSA");
        return factory.generatePublic(spec);
    }
}
