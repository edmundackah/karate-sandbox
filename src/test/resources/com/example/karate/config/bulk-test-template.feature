Feature: Bulk Test Template - Efficient authentication for hundreds of test cases

Background:
  * url baseUrl
  * configure headers = defaultHeaders
  
  # Get authentication token once for all scenarios in this feature
  * url tokenUrl
  * configure headers = defaultHeaders
  Given request tokenConfig
  When method POST
  Then status 200
  And match response == { 'iam-claimsetjwt': '#string' }
  
  # Store token for use in all scenarios
  * def authToken = response['iam-claimsetjwt']
  * print 'Auth token obtained:', authToken
  
  # Reset URL and apply auth headers
  * url baseUrl
  * configure headers = karate.merge(defaultHeaders, { 'iam-claimsetjwt': authToken })

@bulk @auth @smoke
Scenario: Template - GET request with auth
  # Authentication is already applied in Background
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'GET request completed with authentication'

@bulk @auth @smoke
Scenario: Template - POST request with auth
  # Authentication is already applied in Background
  Given path '/api/users'
  And request { "name": "Bulk User", "email": "bulk@example.com" }
  When method POST
  Then status 201
  * print 'POST request completed with authentication'

@bulk @auth @smoke
Scenario: Template - PUT request with auth
  # Authentication is already applied in Background
  Given path '/api/users/1'
  And request { "name": "Updated Bulk User", "email": "updated@example.com" }
  When method PUT
  Then status 200
  * print 'PUT request completed with authentication'

@bulk @auth @smoke
Scenario: Template - DELETE request with auth
  # Authentication is already applied in Background
  Given path '/api/users/1'
  When method DELETE
  Then status 204
  * print 'DELETE request completed with authentication'

@bulk @auth @validation
Scenario: Template - Validate auth token
  # Authentication is already applied in Background
  Given path '/api/token/validate-auth-header'
  When method POST
  Then status 200
  And match response.valid == true
  * print 'Auth validation completed successfully'

@bulk @auth @products
Scenario: Template - Product operations with auth
  # Authentication is already applied in Background
  Given path '/api/products'
  When method GET
  Then status 200
  * print 'Product operations completed with authentication' 