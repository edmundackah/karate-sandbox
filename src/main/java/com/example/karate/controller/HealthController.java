package com.example.karate.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "karate-sandbox-api");
        health.put("timestamp", System.currentTimeMillis());
        return health;
    }

    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> info = new HashMap<>();
        info.put("name", "Karate Sandbox API");
        info.put("version", "1.0.0");
        info.put("description", "Demo API for Karate testing framework");
        info.put("profiles", new String[]{"smoke", "karate-tests"});
        return info;
    }
}