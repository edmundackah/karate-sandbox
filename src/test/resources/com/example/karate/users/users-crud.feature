Feature: User CRUD Operations - Comprehensive HTTP method examples

Background:
  * url baseUrl
  * path '/api/users'
  * configure headers = defaultHeaders
  # Get token if required for this environment
  * if (requiresToken) karate.call('classpath:com/example/karate/config/token-helper.feature')
      * if (requiresToken) karate.configure('headers', karate.merge(defaultHeaders, authHeader))

@smoke @users @get
Scenario: GET - Retrieve all users with default pagination
  When method GET
  Then status 200
  And match response == '#[]'
  And match each response == { id: '#number', name: '#string', email: '#string', role: '#string', active: '#boolean' }
  And assert response.length >= 0

@users @get @queryparams
Scenario: GET - Retrieve users with query parameters
  Given param role = 'admin'
  And param active = true
  And param page = 0
  And param size = 5
  When method GET
  Then status 200
  And match response == '#[]'
  And match each response.role == 'admin'
  And match each response.active == true

@users @get
Scenario: GET - Retrieve specific user by ID
  Given path '/1'
  When method GET
  Then status 200
  And match response == { id: 1, name: '#string', email: '#string', role: '#string', active: '#boolean' }
  And match response.id == 1

@users @get
Scenario: GET - Handle non-existent user
  Given path '/99999'
  When method GET
  Then status 404

@smoke @users @post
Scenario: POST - Create new user
  * def newUser = 
    """
    {
      "name": "Test User",
      "email": "test.user@example.com",
      "role": "user",
      "active": true
    }
    """
  Given request newUser
  When method POST
  Then status 201
  And match response contains newUser
  And match response.id == '#number'
      And assert response.id > 0
  * def createdUserId = response.id

@users @put
Scenario: PUT - Update entire user
  # First create a user to update
  * def newUser = { "name": "Update Test", "email": "update@example.com", "role": "user", "active": true }
  Given request newUser
  When method POST
  Then status 201
  * def userId = response.id
  
  # Now update the user
  * def updatedUser = { "name": "Updated Name", "email": "updated@example.com", "role": "admin", "active": false }
  Given path '/' + userId
  And request updatedUser
  When method PUT
  Then status 200
  And match response contains updatedUser
  And match response.id == userId

@users @patch
Scenario: PATCH - Partial update user
  # First create a user to update
  * def newUser = { "name": "Patch Test", "email": "patch@example.com", "role": "user", "active": true }
  Given request newUser
  When method POST
  Then status 201
  * def userId = response.id
  * def originalEmail = response.email
  
  # Partial update - only change name
  * def partialUpdate = { "name": "Patched Name" }
  Given path '/' + userId
  And request partialUpdate
  When method PATCH
  Then status 200
  And match response.name == 'Patched Name'
  And match response.email == originalEmail
  And match response.id == userId

@users @delete
Scenario: DELETE - Remove user
  # First create a user to delete
  * def newUser = { "name": "Delete Test", "email": "delete@example.com", "role": "user", "active": true }
  Given request newUser
  When method POST
  Then status 201
  * def userId = response.id
  
  # Delete the user
  Given path '/' + userId
  When method DELETE
  Then status 204
  
  # Verify user is deleted
  Given path '/' + userId
  When method GET
  Then status 404

@users @search
Scenario: GET - Search users with query string
  Given path '/search'
  And param query = 'john'
  When method GET
  Then status 200
  And match response == '#[]'