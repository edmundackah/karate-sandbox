Feature: Simple Authentication Example - Shows how to use auto-authentication

Background:
  * url baseUrl
  * configure headers = defaultHeaders

@auth @example @smoke
Scenario: Test with automatic authentication
  # Apply authentication headers automatically
  * call read('classpath:com/example/karate/config/simple-auth-helper.feature')
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Make API call with automatic auth headers
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'API call completed with automatic authentication'

@auth @example @validation
Scenario: Test auth token validation
  # Apply authentication headers automatically
  * call read('classpath:com/example/karate/config/simple-auth-helper.feature')
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Validate the current auth token
  * def isValid = call validateAuth
  * print 'Token is valid:', isValid
  
  # Make API call
  Given path '/api/products'
  When method GET
  Then status 200
  * print 'API call completed with validated authentication'

@auth @example @users
Scenario: Test user operations with auth
  # Apply authentication headers automatically
  * call read('classpath:com/example/karate/config/simple-auth-helper.feature')
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Test user creation
  Given path '/api/users'
  And request { "name": "Test User", "email": "test@example.com" }
  When method POST
  Then status 201
  
  # Test user retrieval
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'User operations completed with authentication' 