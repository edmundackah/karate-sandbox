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
}