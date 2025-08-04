Feature: Advanced Karate Examples - Complex scenarios and utilities

Background:
  * url baseUrl
  * def authHeader = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeader)

@advanced @javascript @ignore
Scenario: JavaScript functions and data manipulation
  # Demonstrate JavaScript usage in Karate
  * def customFunction = 
    """
    function(data) {
      // Complex data manipulation
      return {
        processedAt: new Date().toISOString(),
        count: data.length,
        names: data.map(function(item) { return item.name.toUpperCase(); }),
        summary: 'Processed ' + data.length + ' items'
      };
    }
    """
  
  # Get users data
  Given path '/api/users'
  When method GET
  Then status 200
  * def usersData = response
  
  # Process data with custom function
  * def processedData = customFunction(usersData)
  * match processedData.count == usersData.length
  * match processedData.names == '#[]'
  * match each processedData.names == '#string'

@advanced @conditional @smoke
Scenario: Conditional logic and dynamic requests
  # Dynamic request based on environment
  * def requestPath = env == 'prod' ? '/api/users?active=true' : '/api/users'
  Given path requestPath
  When method GET
  Then status 200
  
  # Conditional assertions
  * if (env == 'prod') karate.assert(response.length > 0)
  * if (env != 'prod') karate.log('Non-production environment, skipping user count assertion')

@advanced @retry
Scenario: Retry mechanism example
  # Simulate a call that might need retry (useful for async operations)
  * configure retry = { count: 3, interval: 1000 }
  * def attemptCounter = 0
  
  Given path '/api/users/1'
  When method GET
  Then status 200
  * def attemptCounter = attemptCounter + 1
  * karate.log('Attempt:', attemptCounter)

@advanced @parallel @performance
Scenario: Parallel execution demonstration
  # This scenario will run in parallel when using Scenario Outline
  * def startTime = karate.time()
  
  Given path '/api/products'
  And param page = 0
  And param size = 10
  When method GET
  Then status 200
  
  * def endTime = karate.time()
  * def executionTime = endTime - startTime
  * karate.log('Execution time:', executionTime, 'ms')
  * assert executionTime >= 0

@advanced @database @ignore
Scenario: Database validation example (requires database setup)
  # This is an example of how you might validate database state
  # Note: Requires additional database configuration
  
  # Create a user
  Given path '/api/users'
  And request { name: 'DB Test User', email: 'dbtest@example.com', role: 'user', active: true }
  When method POST
  Then status 201
  * def userId = response.id
  
  # Simulate database check (replace with actual DB validation)
  * def dbValidation = 
    """
    function(id) {
      // In real scenario, this would query the database
      // For demo, we'll simulate it
      karate.log('Validating user ID in database:', id);
      return { exists: true, id: id };
    }
    """
  * def dbResult = dbValidation(userId)
  * match dbResult.exists == true
  * match dbResult.id == userId
