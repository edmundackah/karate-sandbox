Feature: Authentication Header Validation - Tests JWT token validation endpoint

Background:
  * url baseUrl
  * configure headers = defaultHeaders

@auth @validation @smoke
Scenario: Validate authentication header with valid JWT token
  * def authHeader = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeader)
  
  # Test the validation endpoint
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 200
  And match response.valid == true
  And match response.status == 'VALID'
  And match response.message == 'JWT token is valid'
  And match response.tokenInfo.header contains 'JWT'
  And match response.tokenInfo.payload contains 'sub'
  And match response.tokenInfo.payload contains 'iat'
  And match response.tokenInfo.payload contains 'exp'
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
Scenario: Validate authentication header with empty JWT token
  # Test with empty auth header
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': '' })
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 401
  And match response.valid == false
  And match response.status == 'UNAUTHORIZED'
  And match response.error == 'Missing JWT token in iam-claimsetjwt header'
  * print 'Empty token validation successful'

@auth @validation @error-handling
Scenario: Validate authentication header with invalid JWT structure
  # Test with malformed JWT
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': 'invalid.jwt.token' })
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 400
  And match response.valid == false
  And match response.status == 'INVALID_HEADER'
  And match response.error == 'Invalid JWT header'
  * print 'Invalid JWT structure validation successful'

@auth @validation @error-handling
Scenario: Validate authentication header with malformed JWT header
  # Test with invalid JWT header
  * def malformedHeader = 'eyJ0eXAiOiJJTlZBTElEIiwiYWxnIjoiSFMyNTYifQ'
  * def payload = 'eyJzdWIiOiJrYXJhdGUtdGVzdCIsImlhdCI6MTYzMzQ1Njc4OSwiZXhwIjoxNjMzNDYwMzg5fQ'
  * def signature = 'dGVzdC1zaWduYXR1cmU'
  * def malformedJwt = malformedHeader + '.' + payload + '.' + signature
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': malformedJwt })
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 400
  And match response.valid == false
  And match response.status == 'INVALID_HEADER'
  And match response.error == 'Invalid JWT header'
  * print 'Invalid JWT header validation successful'

@auth @validation @error-handling
Scenario: Validate authentication header with malformed JWT payload
  # Test with invalid JWT payload (missing required claims)
  * def header = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9'
  * def malformedPayload = 'eyJzdWIiOiJrYXJhdGUtdGVzdCJ9'
  * def signature = 'dGVzdC1zaWduYXR1cmU'
  * def malformedJwt = header + '.' + malformedPayload + '.' + signature
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': malformedJwt })
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 400
  And match response.valid == false
  And match response.status == 'INVALID_PAYLOAD'
  And match response.error == 'Invalid JWT payload - missing required claims'
  * print 'Invalid JWT payload validation successful'

@auth @validation @expired
Scenario: Validate authentication header with expired JWT token
  # Test with expired JWT (exp time in the past)
  * def header = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9'
  * def expiredPayload = 'eyJzdWIiOiJrYXJhdGUtdGVzdCIsImlhdCI6MTYzMzQ1Njc4OSwiZXhwIjoxNjMzNDU2Nzg5fQ'
  * def signature = 'dGVzdC1zaWduYXR1cmU'
  * def expiredJwt = header + '.' + expiredPayload + '.' + signature
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': expiredJwt })
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 401
  And match response.valid == false
  And match response.status == 'EXPIRED'
  And match response.error == 'JWT token has expired'
  * print 'Expired JWT validation successful'

@auth @validation @integration
Scenario: End-to-end authentication header validation workflow
  * def authHeader = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeader)
  
  # Step 1: Validate the token
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 200
  And match response.valid == true
  And match response.status == 'VALID'
  
  # Step 2: Extract token info for verification
  * def tokenInfo = response.tokenInfo
  * print 'Token validation successful with info:', tokenInfo
  
  # Step 3: Verify token structure
  * match tokenInfo.header contains 'JWT'
  * match tokenInfo.payload contains 'sub'
  * match tokenInfo.payload contains 'iat'
  * match tokenInfo.payload contains 'exp'
  
  # Step 4: Test that the same token works for other endpoints
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'End-to-end authentication workflow completed successfully'
