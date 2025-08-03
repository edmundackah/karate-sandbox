Feature: Integration Tests - End-to-end workflows

Background:
  * url baseUrl
  * configure headers = defaultHeaders
  # Get token if required for this environment
  * if (requiresToken) karate.call('classpath:com/example/karate/config/token-helper.feature')
      * if (requiresToken) karate.configure('headers', karate.merge(defaultHeaders, authHeader))

@integration @smoke @workflow
Scenario: Complete user and product workflow
  # Step 1: Create a new user
  * def newUser = 
    """
    {
      "name": "Integration Test User",
      "email": "integration@example.com",
      "role": "admin",
      "active": true
    }
    """
  
  Given path '/api/users'
  And request newUser
  When method POST
  Then status 201
  * def userId = response.id
  * match response contains newUser
  
  # Step 2: Verify user was created
  Given path '/api/users', userId
  When method GET
  Then status 200
  * match response.id == userId
  * match response.name == newUser.name
  
  # Step 3: Create a product associated with this workflow
  * def newProduct = 
    """
    {
      "name": "Integration Test Product",
      "description": "Product created in integration test",
      "price": 99.99,
      "category": "Test",
      "quantity": 1
    }
    """
  
  Given path '/api/products'
  And request newProduct
  When method POST
  Then status 201
  * def productId = response.id
  * match response contains newProduct
  
  # Step 4: Update product price
  * def priceUpdate = { "price": 89.99 }
  Given path '/api/products', productId
  And request priceUpdate
  When method PATCH
  Then status 200
  * match response.price == 89.99
  
  # Step 5: Search for our test data
  Given path '/api/users/search'
  And param query = 'integration'
  When method GET
  Then status 200
  * def foundUsers = response
  * match foundUsers[*].id contains userId
  
  # Step 6: Cleanup - Delete test data
  Given path '/api/products', productId
  When method DELETE
  Then status 204
  
  Given path '/api/users', userId
  When method DELETE
  Then status 204
  
  # Step 7: Verify cleanup
  Given path '/api/users', userId
  When method GET
  Then status 404
  
  Given path '/api/products', productId
  When method GET
  Then status 404

@integration @error-handling
Scenario: Error handling and recovery
  # Test various error conditions and recovery mechanisms
  
  # 1. Test 404 handling
  Given path '/api/users/99999'
  When method GET
  Then status 404
  
  # 2. Test 400 handling (invalid data)
  * def invalidUser = { "name": "", "email": "invalid" }
  Given path '/api/users'
  And request invalidUser
  When method POST
  Then status 400
  
  # 3. Test method not allowed
  Given path '/api/users'
  When method PATCH
  Then status 405
  
  # 4. Recovery - create valid user after errors
  * def validUser = 
    """
    {
      "name": "Recovery Test User",
      "email": "recovery@example.com",
      "role": "user",
      "active": true
    }
    """
  Given path '/api/users'
  And request validUser
  When method POST
  Then status 201
  * def recoveryUserId = response.id
  
  # Cleanup
  Given path '/api/users', recoveryUserId
  When method DELETE
  Then status 204

@integration @bulk-operations
Scenario: Bulk operations and batch processing
  # Demonstrate bulk operations using Karate's capabilities
  
  # Load bulk user data
  * def bulkUsers = read('classpath:testdata/users/bulk-users.json')
  * def createdUserIds = []
  
  # Create multiple users
  * def createUser = 
    """
    function(user) {
      var response = karate.http(baseUrl + '/api/users', 'POST', user, headers);
      if (response.status == 201) {
        createdUserIds.push(response.body.id);
        return response.body;
      }
      return null;
    }
    """
  
  * def createdUsers = karate.map(bulkUsers, createUser)
  * match createdUsers == '#[3]'
  * match each createdUsers == '#object'
  
  # Verify all users were created
  * assert createdUserIds.length == 3
  
  # Batch verification
  Given path '/api/users'
  When method GET
  Then status 200
  * def allUsers = response
  * def ourUserIds = karate.map(createdUsers, function(u){ return u.id })
  
  # Verify our created users exist in the response
  * def foundCount = 0
  * def foundCount = allUsers.filter(function(u){ return ourUserIds.includes(u.id) }).length
  * assert foundCount == 3
  
  # Bulk cleanup
  * def deleteUser = 
    """
    function(userId) {
      var response = karate.http(baseUrl + '/api/users/' + userId, 'DELETE', null, headers);
      return response.status == 204;
    }
    """
  
  * def deleteResults = karate.map(createdUserIds, deleteUser)
  * match each deleteResults == true