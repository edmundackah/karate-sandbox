# Test Examples Explained - A Deep Dive

Each test example demonstrates specific Karate features. Let's walk through them step by step.

## Test File Structure

```plaintext
src/test/resources/com/example/karate/
├── config/                    # Framework setup
├── users/                     # User API examples  
├── products/                  # Product API examples
├── advanced/                  # Advanced techniques
└── integration/               # End-to-end workflows
```


## Configuration Tests (`config/`)

### `setup.feature` - Basic Health Checks

**Purpose**: Verify the API is running and configuration is correct.

```gherkin
@smoke
Scenario: Health check - API is accessible
  Given path '/actuator/health'
  When method GET
  Then status 200
  And match response.status == 'UP'
```

**What it does**:
1. Calls the health endpoint
2. Expects a 200 status (success)
3. Verifies the response says "UP"

**Why it's important**: This test fails fast if the API isn't running, saving time on other tests.

### Authentication System - Custom Function Approach

**Purpose**: Automatically handle authentication with zero configuration in tests.

**Usage in Tests**:
```gherkin
Background:
  * url baseUrl
  * configure headers = karate.merge(defaultHeaders, getAuthHeaders())
```

**How it Works**:
1. `getAuthHeaders()` checks if authentication is required (`requiresToken`)
2. If required: Gets or reuses a cached JWT token
3. If not required: Returns dummy headers for testing
4. Automatically manages token lifecycle

**Key Benefits**:
- **Zero Configuration** - Just call `getAuthHeaders()`
- **Automatic Caching** - Reuses tokens across tests
- **Environment Aware** - Different behavior per environment
- **Performance** - Minimizes token API calls

**Behind the Scenes**:
The function uses `token-helper.feature` to get real tokens when needed:
```gherkin
Scenario: Get authentication token
  Given request tokenConfig
  When method POST
  Then status 200
  * def authHeader = { 'iam-claimsetjwt': '#(response["iam-claimsetjwt"])' }
```

## User Tests (`users/`)

### `users-crud.feature` - Basic CRUD Operations

#### Example 1: Simple GET Request

```gherkin
@smoke @users @get
Scenario: GET - Retrieve all users with default pagination
  Given url baseUrl
  And path '/api/users'
  When method GET
  Then status 200
  And match response == '#[]'
  And match each response == { id: '#number', name: '#string', email: '#string', role: '#string', active: '#boolean' }
```

**Breakdown**:
- **Tags**: `@smoke` (essential), `@users` (category), `@get` (HTTP method)
- **Setup**: Set URL and path
- **Action**: Make GET request
- **Validation**: 
  - Status 200 (success)
  - Response is an array (`#[]`)
  - Each item has correct structure

**Key Learning**: This shows basic request structure and response validation.

#### Example 2: GET with Query Parameters

```gherkin
@users @get @queryparams
Scenario: GET - Retrieve users with query parameters
  Given param role = 'admin'
  And param active = true
  And param page = 0
  And param size = 5
  When method GET
  Then status 200
  And match each response.role == 'admin'
  And match each response.active == true
```

**What's New**:
- **`param`** - Adds query parameters (like `?role=admin&active=true`)
- **`each`** - Validates every item in an array

**Real URL**: `http://localhost:8085/api/users?role=admin&active=true&page=0&size=5`

#### Example 3: POST - Creating Data

```gherkin
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
```

**Key Concepts**:
- **`def`** - Creates a variable
- **`"""`** - Multi-line string for JSON
- **`request`** - Sets the request body
- **`status 201`** - "Created" status for new resources
- **`contains`** - Checks that response includes all fields from newUser

#### Example 4: PUT vs PATCH

**PUT (Replace Everything)**:
```gherkin
* def updatedUser = { "name": "Updated Name", "email": "updated@example.com", "role": "admin", "active": false }
Given path '/' + userId
And request updatedUser
When method PUT
Then status 200
```

**PATCH (Update Partially)**:
```gherkin
* def partialUpdate = { "name": "Patched Name" }
Given path '/' + userId  
And request partialUpdate
When method PATCH
Then status 200
And match response.name == 'Patched Name'
And match response.email == originalEmail  # Email unchanged
```

**The Difference**:
- **PUT**: Replaces the entire resource
- **PATCH**: Updates only specified fields

### `users-datatable.feature` - Data-Driven Testing

#### Example: Testing Multiple Scenarios

```gherkin
@users @datatable @parallel
Scenario Outline: Create multiple users with different data
  * def userData = 
    """
    {
      "name": "<name>",
      "email": "<email>",
      "role": "<role>",
      "active": <active>
    }
    """
  Given request userData
  When method POST
  Then status 201

  Examples:
    | name          | email                    | role    | active |
    | Alice Cooper  | alice.cooper@example.com | admin   | true   |
    | Bob Wilson    | bob.wilson@example.com   | user    | true   |
    | Carol Brown   | carol.brown@example.com  | user    | false  |
```

**How It Works**:
1. **`Scenario Outline`** - Template for multiple tests
2. **`<name>`** - Placeholder filled from Examples table
3. **`Examples:`** - Data table with test values
4. **`@parallel`** - Tests run simultaneously

**Result**: Creates 3 separate tests, one for each row in the table.

## Product Tests (`products/`)

### `products-crud.feature` - Advanced Features

#### Example 1: Reading Data from Files

```gherkin
@products @post @file
Scenario: POST - Create product from JSON file
  * def productData = read('classpath:testdata/products/new-product.json')
  * set productData.name = 'Test Product ' + karate.time()
  
  Given request productData
  When method POST
  Then status 201
```

**What's Happening**:
- **`read()`** - Loads data from external file
- **`set`** - Modifies the loaded data
- **`karate.time()`** - Generates unique timestamp

**Benefits**: 
- Reusable test data
- No hard-coded values in tests
- Easy to maintain

#### Example 2: Custom Headers

```gherkin
@products @put @headers
Scenario: PUT - Update product with custom headers
  * configure headers = karate.merge(defaultHeaders, { 'X-Update-Reason': 'price-change', 'X-Operator': 'test-system' })
  
  Given request updatedProduct
  When method PUT
  Then status 200
```

**Key Concepts**:
- **`configure headers`** - Sets headers for requests
- **`karate.merge()`** - Combines objects
- **Custom headers** - Add metadata to requests

#### Example 3: Conditional Logic

```gherkin
@products @patch @conditional
Scenario: PATCH - Conditional update based on current state
  * def priceIncrease = originalPrice < 500 ? 50 : 0
  * def priceUpdate = { "price": originalPrice + priceIncrease }
  
  Given request priceUpdate
  When method PATCH
  Then status 200
```

**JavaScript Features**:
- **Ternary operator** - `condition ? valueIfTrue : valueIfFalse`
- **Dynamic data** - Calculate values based on conditions


## Advanced Examples (`advanced/`)

### `advanced-examples.feature` - Complex Scenarios

#### Example 1: JavaScript Functions

```gherkin
@advanced @javascript
Scenario: JavaScript functions and data manipulation
  * def customFunction = 
    """
    function(data) {
      return {
        processedAt: new Date().toISOString(),
        count: data.length,
        names: data.map(function(item) { return item.name.toUpperCase(); }),
        summary: 'Processed ' + data.length + ' items'
      };
    }
    """
  
  * def processedData = customFunction(usersData)
  * match processedData.count == usersData.length
```

**What This Shows**:
- **Custom functions** - Write JavaScript to process data
- **Date handling** - Generate timestamps
- **Array manipulation** - Transform data
- **String operations** - Format text

#### Example 2: Retry Logic

```gherkin
@advanced @retry
Scenario: Retry mechanism example
  * configure retry = { count: 3, interval: 1000 }
  
  Given path '/api/users/1'
  When method GET
  Then status 200
```

**When to Use**: 
- APIs that might be temporarily unavailable
- Eventually consistent systems
- Network-dependent operations


## Integration Tests (`integration/`)

### `integration-tests.feature` - End-to-End Workflows

#### Example: Complete User Lifecycle

```gherkin
@integration @smoke @workflow
Scenario: Complete user and product workflow
  # Step 1: Create a new user
  * def newUser = { "name": "Integration Test User", ... }
  Given path '/api/users'
  And request newUser
  When method POST
  Then status 201
  * def userId = response.id
  
  # Step 2: Verify user was created
  Given path '/api/users', userId
  When method GET
  Then status 200
  
  # Step 3: Create related data
  * def newProduct = { "name": "Integration Test Product", ... }
  Given path '/api/products'
  And request newProduct
  When method POST
  Then status 201
  
  # Step 4: Cleanup
  Given path '/api/users', userId
  When method DELETE
  Then status 204
```

**Integration Testing Principles**:
1. **Test realistic workflows** - How users actually use the system
2. **Test data relationships** - How different entities interact
3. **Clean up after yourself** - Don't leave test data behind
4. **Verify state changes** - Confirm operations actually worked


## Best Practices Demonstrated

### 1. Test Organisation
- **Use descriptive scenario names** - Anyone should understand what's being tested
- **Group related tests** - Users, products, etc. in separate files
- **Tag appropriately** - Make it easy to run specific test types

### 2. Data Management
- **Use variables** - Don't repeat data
- **External files** - Keep test data separate from test logic
- **Generate unique values** - Avoid conflicts between test runs

### 3. Assertions
- **Check status codes** - Always verify the response status
- **Validate structure** - Ensure responses have expected format
- **Verify business logic** - Check that the right data was created/updated

### 4. Maintenance
- **Clean up test data** - Don't pollute the system
- **Handle authentication** - Abstract away complexity
- **Environment flexibility** - Tests should work in different environments


## Common Patterns Explained

### Pattern 1: Create-Verify-Cleanup
```gherkin
# Create
Given request newData
When method POST
Then status 201
* def resourceId = response.id

# Verify
Given path '/api/resource', resourceId
When method GET
Then status 200

# Cleanup
Given path '/api/resource', resourceId
When method DELETE
Then status 204
```

### Pattern 2: Smart Authentication with Custom Function
```gherkin
Background:
  # Automatic authentication - handles both auth and non-auth environments
  * configure headers = karate.merge(defaultHeaders, getAuthHeaders())
  
  # Or if you need the headers separately:
  * def authHeaders = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeaders)
```

### Pattern 3: Dynamic Test Data
```gherkin
* def uniqueEmail = 'test-' + karate.time() + '@example.com'
* def testUser = { "name": "Test User", "email": "#(uniqueEmail)" }
```

## Learning Progression

### Beginner
1. **setup.feature** - Basic health checks
2. **users-crud.feature** (GET scenarios) - Simple requests
3. **users-crud.feature** (POST scenarios) - Creating data

### Intermediate
1. **users-crud.feature** (PUT/PATCH/DELETE) - All HTTP methods
2. **users-datatable.feature** - Data-driven testing
3. **products-crud.feature** (file operations) - External data

### Advanced
1. **products-crud.feature** (headers/conditional) - Complex scenarios
2. **advanced-examples.feature** - JavaScript and functions
3. **integration-tests.feature** - End-to-end workflows
