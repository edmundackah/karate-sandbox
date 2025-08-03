Feature: Hundreds Test Template - Pattern for hundreds of test cases with efficient authentication

Background:
  * url baseUrl
  * configure headers = defaultHeaders
  
  # Get authentication token ONCE for all scenarios in this feature
  * url tokenUrl
  * configure headers = defaultHeaders
  Given request tokenConfig
  When method POST
  Then status 200
  And match response == { 'iam-claimsetjwt': '#string' }
  
  # Store token for use in all scenarios
  * def authToken = response['iam-claimsetjwt']
  * print 'Auth token obtained for all scenarios:', authToken
  
  # Reset URL and apply auth headers for all scenarios
  * url baseUrl
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': authToken })

# ============================================================================
# TEMPLATE FOR HUNDREDS OF TEST CASES
# ============================================================================
# Copy this pattern for each test case:
# 
# @your-tag @auth
# Scenario: Your test description
#   # Authentication is already applied in Background
#   Given path '/your/endpoint'
#   When method GET/POST/PUT/DELETE
#   Then status 200/201/204/etc
#   * print 'Your test completed with authentication'
# ============================================================================

@hundreds @auth @smoke
Scenario: Template - GET request with auth
  # Authentication is already applied in Background
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'GET request completed with authentication'

@hundreds @auth @smoke
Scenario: Template - POST request with auth
  # Authentication is already applied in Background
  Given path '/api/users'
  And request { "name": "Hundreds User", "email": "hundreds@example.com" }
  When method POST
  Then status 201
  * print 'POST request completed with authentication'

@hundreds @auth @validation
Scenario: Template - Validate auth token
  # Authentication is already applied in Background
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 200
  And match response.valid == true
  * print 'Auth validation completed successfully'

@hundreds @auth @products
Scenario: Template - Product operations with auth
  # Authentication is already applied in Background
  Given path '/api/products'
  When method GET
  Then status 200
  * print 'Product operations completed with authentication'

@hundreds @auth @health
Scenario: Template - Health check with auth
  # Authentication is already applied in Background
  Given path '/actuator/health'
  When method GET
  Then status 200
  * print 'Health check completed with authentication'

# ============================================================================
# HOW TO USE THIS TEMPLATE FOR HUNDREDS OF TESTS:
# ============================================================================
# 1. Copy this entire feature file
# 2. Replace the scenarios with your actual test cases
# 3. Keep the Background section exactly as is
# 4. Each scenario will automatically have authentication applied
# 5. No need to call auth endpoints in each test
# 6. Much faster execution for hundreds of test cases
# ============================================================================ 