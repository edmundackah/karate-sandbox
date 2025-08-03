Feature: Debug Authentication Header

Background:
  * url baseUrl
  * configure headers = defaultHeaders

@debug
Scenario: Debug auth header contents
  # Get token if required
  * if (requiresToken) karate.call('classpath:com/example/karate/config/token-helper.feature')
  * if (requiresToken) karate.configure('headers', karate.merge(defaultHeaders, authHeader))
  
  # Debug the auth header
  * print 'authHeader:', authHeader
  * print 'authHeader type:', typeof authHeader
  * print 'authHeader keys:', Object.keys(authHeader)
  
  # Test the validation endpoint with explicit header
  * def testToken = authHeader['iam-claimsetjwt']
  * print 'testToken:', testToken
  
  Given path '/api/token/validate-auth-header'
  And header iam-claimsetjwt = testToken
  When method POST
  Then status 200
  * print 'Validation successful with explicit header' 