Feature: Working Authentication Header Validation - Direct token usage

Background:
  * url baseUrl
  * configure headers = defaultHeaders

@auth @validation @smoke
Scenario: Validate authentication header with valid JWT token
  # Get token directly
  * url tokenUrl
  * configure headers = defaultHeaders
  Given request tokenConfig
  When method POST
  Then status 200
  And match response == { 'iam-claimsetjwt': '#string' }
  
  # Extract token and test validation
  * def jwtToken = response['iam-claimsetjwt']
  * print 'JWT Token:', jwtToken
  
  # Test the validation endpoint
  * url baseUrl
  Given path '/api/token/validate-auth-header'
  And header iam-claimsetjwt = jwtToken
  When method POST
  Then status 200
  And match response.valid == true
  And match response.status == 'VALID'
  And match response.message == 'JWT token is valid'
  * print 'Valid JWT token validation successful'

@auth @validation @error-handling
Scenario: Validate authentication header without JWT token
  # Test without any auth headers
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 401
  And match response.valid == false
  And match response.status == 'UNAUTHORIZED'
  And match response.error == 'Missing JWT token in iam-claimsetjwt header'
  * print 'Missing token validation successful'

@auth @validation @error-handling
Scenario: Validate authentication header with invalid JWT structure
  # Test with malformed JWT
  Given path '/api/token/validate-auth-header'
  And header iam-claimsetjwt = 'invalid.jwt.token'
  When method POST
  Then status 400
  And match response.valid == false
  And match response.status == 'INVALID_HEADER'
  And match response.error == 'Invalid JWT header'
  * print 'Invalid JWT structure validation successful' 