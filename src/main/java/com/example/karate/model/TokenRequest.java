package com.example.karate.model;

public class TokenRequest {
    private boolean isAws = false;
    private String service;
    private String environment;

    public TokenRequest() {}

    public TokenRequest(boolean isAws, String service, String environment) {
        this.isAws = isAws;
        this.service = service;
        this.environment = environment;
    }

    public boolean isAws() { return isAws; }
    public void setAws(boolean aws) { isAws = aws; }

    public String getService() { return service; }
    public void setService(String service) { this.service = service; }

    public String getEnvironment() { return environment; }
    public void setEnvironment(String environment) { this.environment = environment; }
}