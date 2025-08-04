function fn() {
  // Get environment from system property (passed from Maven)
  var env = karate.properties['test.env'] || 'local';
  var isAws = karate.properties['is.aws'] === 'true';
  
  karate.log('Environment:', env);
  karate.log('Is AWS:', isAws);
  
  // Environment-specific configuration
  var config = {
    env: env,
    isAws: isAws
  };

  // Base URL configuration per environment
  if (env === 'local') {
    config.baseUrl = 'http://localhost:8085';
    config.tokenUrl = 'http://localhost:8085/api/token/generate';
    config.requiresToken = true;
  } else if (env === 'dev') {
    config.baseUrl = 'https://dev-api.example.com';
    config.tokenUrl = 'https://dev-token.example.com/api/token/generate';
    config.requiresToken = true;
  } else if (env === 'staging') {
    config.baseUrl = 'https://staging-api.example.com';
    config.tokenUrl = 'https://staging-token.example.com/api/token/generate';
    config.requiresToken = true;
  } else if (env === 'prod') {
    config.baseUrl = 'https://api.example.com';
    config.tokenUrl = 'https://token.example.com/api/token/generate';
    config.requiresToken = true;
  } else if (env === 'mock') {
    // Example of environment that doesn't require authentication
    config.baseUrl = 'http://localhost:3000';
    config.tokenUrl = null;
    config.requiresToken = false;
  }

  // Common configuration
  config.defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };

  // Token configuration
  config.tokenConfig = {
    isAws: isAws,
    service: 'karate-tests',
    environment: env
  };

  // Initialize authHeader to prevent reference errors
  config.authHeader = {};

  // Note: Authentication will be handled in individual test features
  // This prevents issues with HTTP calls during configuration loading

  // Load authentication utility functions
  var authUtilsFeature = karate.callSingle('classpath:helpers/auth-utils.js');
  config.authUtils = authUtilsFeature;
  
  // Convenience function to get auth headers
  config.getAuthHeaders = function(forceAuth) {
    return authUtilsFeature.getAuthHeaders(config, forceAuth);
  };

  karate.log('Configuration loaded:', config);
  
  // Global variables
  karate.set('authToken', null);
  karate.set('config', config);

  return config;
}
