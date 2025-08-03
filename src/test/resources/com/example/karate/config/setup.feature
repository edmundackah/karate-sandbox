Feature: Setup and Configuration Tests

Background:
  * url baseUrl
  * configure headers = defaultHeaders

@smoke
Scenario: Verify configuration is loaded correctly
  * print 'Environment:', env
  * print 'Base URL:', baseUrl
  * print 'Requires Token:', requiresToken
  * print 'Is AWS:', isAws
  * assert env != null
  * assert baseUrl != null

@smoke  
Scenario: Health check - API is accessible via custom endpoint
  Given path '/api/health'
  When method GET
  Then status 200
  And match response.status == 'UP'

@smoke
Scenario: Health check - API is accessible via actuator
  Given path '/actuator/health'
  When method GET
  Then status 200
  And match response.status == 'UP'

Scenario: Get authentication token if required
  * if (requiresToken) karate.call('classpath:com/example/karate/config/token-helper.feature')
  * if (requiresToken) print 'Authentication token obtained'
  * if (!requiresToken) print 'No authentication required for', env, 'environment'