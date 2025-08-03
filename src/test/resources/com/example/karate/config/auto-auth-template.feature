Feature: Auto-Authentication Template - Template for hundreds of test cases

Background:
  * url baseUrl
  * configure headers = defaultHeaders
  
  # Auto-apply authentication headers if available
  * if (authHeader && authHeader['iam-claimsetjwt']) karate.configure('headers', karate.merge(defaultHeaders, authHeader))

@auth @template @smoke
Scenario: Template - GET request with auto-auth
  # Authentication is automatically applied in Background
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'GET request completed with automatic authentication'

@auth @template @smoke
Scenario: Template - POST request with auto-auth
  # Authentication is automatically applied in Background
  Given path '/api/users'
  And request { "name": "Template User", "email": "template@example.com" }
  When method POST
  Then status 201
  * print 'POST request completed with automatic authentication'

@auth @template @smoke
Scenario: Template - PUT request with auto-auth
  # Authentication is automatically applied in Background
  Given path '/api/users/1'
  And request { "name": "Updated User", "email": "updated@example.com" }
  When method PUT
  Then status 200
  * print 'PUT request completed with automatic authentication'

@auth @template @smoke
Scenario: Template - DELETE request with auto-auth
  # Authentication is automatically applied in Background
  Given path '/api/users/1'
  When method DELETE
  Then status 204
  * print 'DELETE request completed with automatic authentication'

@auth @template @validation
Scenario: Template - Validate auth token
  # Authentication is automatically applied in Background
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 200
  And match response.valid == true
  * print 'Auth validation completed successfully' 