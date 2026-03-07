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
import java.security.AlgorithmParameters;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.ECGenParameterSpec;
import java.security.spec.ECParameterSpec;
import java.security.spec.ECPoint;
import java.security.spec.ECPublicKeySpec;
import java.security.spec.RSAPublicKeySpec;
import java.math.BigInteger;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class JwtValidator {

    @Value("${jwt.jwks-url}")
    private String jwksUrl;

    @Value("${jwt.issuer}")
    private String issuer;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @SuppressWarnings("unchecked")
    public Map<String, Object> validate(String token) {
        try {
            PublicKey publicKey = fetchPublicKey(token);
            Claims claims = Jwts.parser()
                    .verifyWith(publicKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            if (!issuer.equals(claims.getIssuer())) {
                throw new RuntimeException("Invalid issuer: " + claims.getIssuer());
            }

            return new HashMap<>(claims);
        } catch (Exception e) {
            throw new RuntimeException("JWT validation failed: " + e.getMessage(), e);
        }
    }

    @SuppressWarnings("unchecked")
    private PublicKey fetchPublicKey(String token) throws Exception {
        String[] parts = token.split("\\.");
        if (parts.length < 2) throw new RuntimeException("Invalid JWT format");

        String headerJson = new String(Base64.getUrlDecoder().decode(parts[0]));
        Map<String, Object> header = objectMapper.readValue(headerJson, Map.class);
        String kid = (String) header.get("kid");

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(jwksUrl))
                .build();
        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        Map<String, Object> jwks = objectMapper.readValue(response.body(), Map.class);
        List<Map<String, Object>> keys = (List<Map<String, Object>>) jwks.get("keys");

        for (Map<String, Object> key : keys) {
            if (kid == null || kid.equals(key.get("kid"))) {
                String alg = (String) key.get("alg");
                String kty = (String) key.get("kty");
                if ("ES256".equals(alg) || "EC".equals(kty)) {
                    return buildEcPublicKey(key);
                } else {
                    return buildRsaPublicKey(key);
                }
            }
        }
        throw new RuntimeException("No matching key found for kid: " + kid);
    }

    private PublicKey buildEcPublicKey(Map<String, Object> jwk) throws Exception {
        byte[] xBytes = Base64.getUrlDecoder().decode((String) jwk.get("x"));
        byte[] yBytes = Base64.getUrlDecoder().decode((String) jwk.get("y"));

        AlgorithmParameters params = AlgorithmParameters.getInstance("EC");
        params.init(new ECGenParameterSpec("secp256r1"));
        ECParameterSpec ecSpec = params.getParameterSpec(ECParameterSpec.class);

        ECPoint point = new ECPoint(new BigInteger(1, xBytes), new BigInteger(1, yBytes));
        return KeyFactory.getInstance("EC").generatePublic(new ECPublicKeySpec(point, ecSpec));
    }

    private PublicKey buildRsaPublicKey(Map<String, Object> jwk) throws Exception {
        BigInteger modulus  = new BigInteger(1, Base64.getUrlDecoder().decode((String) jwk.get("n")));
        BigInteger exponent = new BigInteger(1, Base64.getUrlDecoder().decode((String) jwk.get("e")));
        return KeyFactory.getInstance("RSA").generatePublic(new RSAPublicKeySpec(modulus, exponent));
    }
}
