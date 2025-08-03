Feature: Authentication Template - Template for hundreds of test cases

Background:
  * url baseUrl
  * configure headers = defaultHeaders
  # Load auth helper functions
  * call read('classpath:com/example/karate/config/auth-helper.feature')

# Template for authenticated API tests
* def authenticatedRequest = 
"""
function(path, method, requestBody) {
  # Apply authentication headers
  var authApplied = call applyAuth;
  if (!authApplied) {
    karate.fail('Authentication failed');
  }
  
  # Set up the request
  karate.configure('url', baseUrl);
  if (requestBody) {
    karate.configure('request', requestBody);
  }
  
  # Make the request
  var response = karate.http(method, path);
  return response;
}
"""

# Template for authenticated GET requests
* def authenticatedGet = 
"""
function(path) {
  return call authenticatedRequest path 'GET' null;
}
"""

# Template for authenticated POST requests
* def authenticatedPost = 
"""
function(path, body) {
  return call authenticatedRequest path 'POST' body;
}
"""

# Template for authenticated PUT requests
* def authenticatedPut = 
"""
function(path, body) {
  return call authenticatedRequest path 'PUT' body;
}
"""

# Template for authenticated DELETE requests
* def authenticatedDelete = 
"""
function(path) {
  return call authenticatedRequest path 'DELETE' null;
}
"""

@template @auth
Scenario: Template - Authenticated GET request
  # Apply authentication automatically
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Make authenticated request
  Given path '/api/users'
  When method GET
  Then status 200
  * print 'Authenticated GET request completed'

@template @auth
Scenario: Template - Authenticated POST request
  # Apply authentication automatically
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Make authenticated request
  Given path '/api/users'
  And request { "name": "Template User", "email": "template@example.com" }
  When method POST
  Then status 201
  * print 'Authenticated POST request completed'

@template @auth
Scenario: Template - Authenticated PUT request
  # Apply authentication automatically
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Make authenticated request
  Given path '/api/users/1'
  And request { "name": "Updated User", "email": "updated@example.com" }
  When method PUT
  Then status 200
  * print 'Authenticated PUT request completed'

@template @auth
Scenario: Template - Authenticated DELETE request
  # Apply authentication automatically
  * def authApplied = call applyAuth
  * print 'Auth applied:', authApplied
  
  # Make authenticated request
  Given path '/api/users/1'
  When method DELETE
  Then status 204
  * print 'Authenticated DELETE request completed' 