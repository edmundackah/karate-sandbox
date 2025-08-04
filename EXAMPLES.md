# Karate Test Examples

## Running Examples

### 1. Basic Test Execution
```bash
# Run smoke tests
mvn clean test -Pkarate-smoke

# Run with specific environment
mvn clean test -Pkarate-smoke -Dtest.env=local
```

### 2. Environment-Specific Testing
```bash
# Local environment (no token required)
mvn clean test -Pkarate-smoke -Dtest.env=local

# Development with token
mvn clean test -Pkarate-smoke -Dtest.env=dev

# Production with AWS token service
mvn clean test -Pkarate-smoke -Dtest.env=prod -Dis.aws=true
```

## Test Features Demonstrated

### 1. HTTP Methods

#### GET Requests
```gherkin
# Basic GET
Given path '/api/users'
When method GET
Then status 200

# GET with query parameters
Given path '/api/users'
And param role = 'admin'
And param active = true
When method GET
Then status 200
```

#### POST Requests
```gherkin
# Create with inline JSON
* def newUser = { "name": "John Doe", "email": "john@example.com", "role": "user", "active": true }
Given path '/api/users'
And request newUser
When method POST
Then status 201

# Create from file
* def userData = read('classpath:testdata/users/new-user.json')
Given path '/api/users'
And request userData
When method POST
Then status 201
```

#### PUT Requests
```gherkin
# Full update
* def updatedUser = { "name": "Jane Doe", "email": "jane@example.com", "role": "admin", "active": true }
Given path '/api/users/1'
And request updatedUser
When method PUT
Then status 200
```

#### PATCH Requests
```gherkin
# Partial update
* def partialUpdate = { "role": "admin" }
Given path '/api/users/1'
And request partialUpdate
When method PATCH
Then status 200
```

#### DELETE Requests
```gherkin
# Delete resource
Given path '/api/users/1'
When method DELETE
Then status 204
```

### 2. Headers and Authentication

#### Custom Headers
```gherkin
# Add custom headers
* configure headers = { 'X-Request-ID': karate.uuid(), 'X-Client-Version': '1.0' }

# Merge with existing headers
* configure headers = karate.merge(defaultHeaders, { 'X-Custom': 'value' })
```

#### Token Authentication
```gherkin
# Simple one-line authentication using custom function
* configure headers = karate.merge(defaultHeaders, getAuthHeaders())

# Or if you need the headers separately
* def authHeaders = getAuthHeaders()
* configure headers = karate.merge(defaultHeaders, authHeaders)

# Force authentication even when not required
* def authHeaders = getAuthHeaders(true)
```

### 3. Query Parameters

```gherkin
# Single parameter
Given param category = 'Electronics'

# Multiple parameters
Given param category = 'Electronics'
And param minPrice = 100
And param maxPrice = 1000

# Dynamic parameters
* def filterParams = { category: 'Electronics', active: true }
* param filterParams
```

### 4. File Operations

#### Reading JSON Files
```gherkin
# Read test data from file
* def testData = read('classpath:testdata/products/new-product.json')

# Modify file data
* set testData.name = 'Modified ' + testData.name
* set testData.price = testData.price * 1.1
```

#### Reading CSV Files
```gherkin
# Read CSV for data-driven tests
* def csvData = read('classpath:testdata/test-cases.csv')
* def testCases = karate.mapCsv(csvData)
```

### 5. Data Tables and Parallel Execution

```gherkin
@parallel
Scenario Outline: Test with multiple data sets
  * def testData = { "name": "<name>", "email": "<email>", "role": "<role>" }
  Given path '/api/users'
  And request testData
  When method POST
  Then status 201

  Examples:
    | name     | email              | role  |
    | Alice    | alice@example.com  | admin |
    | Bob      | bob@example.com    | user  |
    | Charlie  | charlie@example.com| user  |
```

### 6. JavaScript Functions

```gherkin
# Custom validation function
* def validateUser = 
  """
  function(user) {
    if (!user.name || !user.email) return false;
    if (!user.email.includes('@')) return false;
    return true;
  }
  """

# Data transformation
* def transformData = 
  """
  function(items) {
    return items.map(function(item) {
      return {
        id: item.id,
        displayName: item.name.toUpperCase(),
        status: item.active ? 'ACTIVE' : 'INACTIVE'
      };
    });
  }
  """
```

### 7. Conditional Logic

```gherkin
# Environment-based conditions
* if (env == 'prod') karate.configure('connectTimeout', 10000)
* if (env == 'local') karate.log('Running in local mode')

# Response-based conditions
* def userId = response.id
* if (userId > 0) karate.set('validUser', true)
```

### 8. Response Validation

#### Schema Validation
```gherkin
# Exact match
And match response == { id: 1, name: 'John Doe', email: 'john@example.com' }

# Schema match
And match response == { id: '#number', name: '#string', email: '#string' }

# Array validation
And match response == '#[]'
And match each response == { id: '#number', name: '#string' }
```

#### JSONPath and Fuzzy Matching
```gherkin
# JSONPath
And match response.users[*].id == '#[] #number'
And match response.users[?(@.active == true)] == '#[3]'

# Fuzzy matching
And match response.price == '#? _ > 0'
And match response.email == '#regex .+@.+\\..+'
```

### 9. Error Handling

```gherkin
# Test error responses
Given path '/api/users/99999'
When method GET
Then status 404

# Validate error structure
And match response == { error: '#string', message: '#string' }

# Test validation errors
* def invalidData = { name: '', email: 'invalid' }
Given path '/api/users'
And request invalidData
When method POST
Then status 400
```

### 10. Database Integration (Example)

```gherkin
# Example of database validation (requires setup)
* def dbConfig = { url: 'jdbc:h2:mem:test', username: 'sa', password: '' }
* def DbUtils = Java.type('com.example.karate.util.DbUtils')

# Validate database state
* def dbResult = DbUtils.query(dbConfig, 'SELECT COUNT(*) as count FROM users WHERE email = ?', email)
* match dbResult[0].count == 1
```

### 11. Performance Testing

```gherkin
# Simple performance measurement
* def startTime = karate.time()
Given path '/api/users'
When method GET
Then status 200
* def endTime = karate.time()
* def responseTime = endTime - startTime
* assert responseTime < 1000
```

### 12. Retry Logic

```gherkin
# Configure retry for flaky tests
* configure retry = { count: 3, interval: 1000 }

# Test with retry
Given path '/api/async-operation'
When method GET
Then status 200
```

## Advanced Patterns

### 1. Test Data Setup and Cleanup

```gherkin
Background:
  # Setup test data
  * def testUserId = call read('classpath:helpers/create-test-user.js')

# Test scenarios here...

# Cleanup (can be in a separate scenario or hook)
* call read('classpath:helpers/cleanup-test-data.js') { userId: testUserId }
```

### 2. Dynamic Test Configuration

```gherkin
# Load environment-specific test data
* def testConfig = read('classpath:config/' + env + '-test-config.json')
* url testConfig.baseUrl
* def testData = read('classpath:testdata/' + env + '/test-users.json')
```

### 3. API Chaining

```gherkin
# Create user, then create product for that user
* def user = call read('create-user.feature')
* def product = call read('create-product.feature') { ownerId: user.id }

# Verify relationship
Given path '/api/users', user.id, 'products'
When method GET
Then status 200
And match response[*].id contains product.id
```

## Tag Usage Examples

### Test Organisation
```gherkin
@smoke @users @critical
Scenario: Critical user functionality

@regression @products @extended  
Scenario: Extended product testing

@integration @workflow @slow
Scenario: End-to-end workflow

@parallel @datatable @performance
Scenario Outline: Performance testing with data table
```

### Running Specific Test Types
```bash
# Critical tests only
mvn verify -Pkarate-all -Dkarate.options="--tags @critical"

# Everything except slow tests
mvn verify -Pkarate-all -Dkarate.options="--tags ~@slow"

# Smoke tests for specific module
mvn verify -Pkarate-all -Dkarate.options="--tags @smoke and @users"
```
