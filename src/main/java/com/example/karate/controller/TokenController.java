package com.example.karate.controller;

import com.example.karate.model.TokenRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/token")
public class TokenController {

    @PostMapping("/generate")
    public ResponseEntity<Map<String, String>> generateToken(@RequestBody TokenRequest request) {
        
        // Generate a mock JWT token
        String header = Base64.getEncoder().encodeToString("{\"typ\":\"JWT\",\"alg\":\"HS256\"}".getBytes());
        String payload = Base64.getEncoder().encodeToString(
            String.format("{\"sub\":\"karate-test\",\"iat\":%d,\"exp\":%d}", 
                System.currentTimeMillis()/1000, (System.currentTimeMillis()/1000) + 3600)
            .getBytes());
        String signature = Base64.getEncoder().encodeToString(UUID.randomUUID().toString().getBytes());
        
        String jwtToken = String.format("%s.%s.%s", header, payload, signature);
        
        // Return simple JSON with just the required key-value pair
        Map<String, String> response = new HashMap<>();
        response.put("iam-claimsetjwt", jwtToken);
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/validate")
    public ResponseEntity<String> validateToken(@RequestHeader("Authorization") String token) {
        if (token != null && token.startsWith("Bearer ")) {
            return ResponseEntity.ok("Token is valid");
        }
        return ResponseEntity.badRequest().body("Invalid token");
    }

    @PostMapping("/validate-auth-header")
    public ResponseEntity<Map<String, Object>> validateAuthHeader(@RequestHeader(value = "iam-claimsetjwt", required = false) String jwtToken) {
        Map<String, Object> response = new HashMap<>();
        
        if (jwtToken == null || jwtToken.trim().isEmpty()) {
            response.put("valid", false);
            response.put("error", "Missing JWT token in iam-claimsetjwt header");
            response.put("status", "UNAUTHORIZED");
            return ResponseEntity.status(401).body(response);
        }
        
        try {
            // Basic JWT structure validation
            String[] parts = jwtToken.split("\\.");
            if (parts.length != 3) {
                response.put("valid", false);
                response.put("error", "Invalid JWT structure - expected 3 parts");
                response.put("status", "INVALID_TOKEN");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Decode and validate header
            String headerJson = new String(Base64.getDecoder().decode(parts[0]));
            if (!headerJson.contains("\"typ\":\"JWT\"") || !headerJson.contains("\"alg\":")) {
                response.put("valid", false);
                response.put("error", "Invalid JWT header");
                response.put("status", "INVALID_HEADER");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Decode and validate payload
            String payloadJson = new String(Base64.getDecoder().decode(parts[1]));
            if (!payloadJson.contains("\"sub\"") || !payloadJson.contains("\"iat\"") || !payloadJson.contains("\"exp\"")) {
                response.put("valid", false);
                response.put("error", "Invalid JWT payload - missing required claims");
                response.put("status", "INVALID_PAYLOAD");
                return ResponseEntity.badRequest().body(response);
            }
            
            // Check if token is expired
            long currentTime = System.currentTimeMillis() / 1000;
            if (payloadJson.contains("\"exp\":")) {
                try {
                    String expStr = payloadJson.split("\"exp\":")[1].split("}")[0];
                    long expTime = Long.parseLong(expStr);
                    if (currentTime > expTime) {
                        response.put("valid", false);
                        response.put("error", "JWT token has expired");
                        response.put("status", "EXPIRED");
                        return ResponseEntity.status(401).body(response);
                    }
                } catch (Exception e) {
                    // If we can't parse the expiration, we'll assume it's valid for now
                    // In a real implementation, you might want to be more strict
                }
            }
            
            // Token is valid
            response.put("valid", true);
            response.put("message", "JWT token is valid");
            response.put("status", "VALID");
            response.put("tokenInfo", Map.of(
                "header", headerJson,
                "payload", payloadJson,
                "signature", parts[2]
            ));
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("valid", false);
            response.put("error", "Failed to validate JWT token: " + e.getMessage());
            response.put("status", "VALIDATION_ERROR");
            return ResponseEntity.badRequest().body(response);
        }
    }
}