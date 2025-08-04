Feature: Product CRUD Operations - Advanced HTTP examples with headers and file operations

Background:
  * url baseUrl
  * path '/api/products'
  * def authHeader = getAuthHeaders()
  * configure headers = karate.merge(defaultHeaders, authHeader)

@smoke @products @get
Scenario: GET - Retrieve all products with filtering
  Given param category = 'Electronics'
  And param minPrice = 100
  And param maxPrice = 1000
  When method GET
  Then status 200
  And match response == '#[]'
  And match each response == 
    """
    {
      id: '#number',
      name: '#string',
      description: '#string',
      price: '#number',
      category: '#string',
      quantity: '#number'
    }
    """
  # Validate filtering worked - response should be an array
  And match response == '#[]'
  And match each response == 
    """
    {
      id: '#number',
      name: '#string', 
      description: '#string',
      price: '#number',
      category: 'Electronics',
      quantity: '#number'
    }
    """
  And match each response == '#? _.price >= 100 && _.price <= 1000'

@products @post @file
Scenario: POST - Create product from JSON file
  # Read product data from external file
  * def productData = read('classpath:testdata/products/new-product.json')
  * set productData.name = 'Test Product ' + karate.time()
  
  # Add custom headers for this request
  * configure headers = karate.merge(defaultHeaders, { 'X-Request-ID': karate.uuid(), 'X-Client-Version': '1.0' })

  
  Given request productData
  When method POST
  Then status 201
  And match response contains productData
  And match response.id == '#number'
  
  # Store created product ID for cleanup
  * def createdProductId = response.id

@products @put @headers
Scenario: PUT - Update product with custom headers
  # Create a product first
  * def newProduct = read('classpath:testdata/products/new-product.json')
  Given request newProduct
  When method POST
  Then status 201
  * def productId = response.id
  
  # Update with custom headers
  * def updatedProduct = read('classpath:testdata/products/updated-product.json')
  * configure headers = karate.merge(defaultHeaders, { 'X-Update-Reason': 'price-change', 'X-Operator': 'test-system' })

  
  Given path '/' + productId
  And request updatedProduct
  When method PUT
  Then status 200
  And match response contains updatedProduct

@products @patch @conditional
Scenario: PATCH - Conditional update based on current state
  # Create a product first
  * def newProduct = read('classpath:testdata/products/new-product.json')
  Given request newProduct
  When method POST
  Then status 201
  * def productId = response.id
  * def originalPrice = response.price
  
  # Conditional update - increase price only if it's below a threshold
  * def priceIncrease = originalPrice < 500 ? 50 : 0
  * def priceUpdate = { "price": originalPrice + priceIncrease }
  
  Given path '/' + productId
  And request priceUpdate
  When method PATCH
  Then status 200
  And match response.price == originalPrice + priceIncrease

@products @get @categories
Scenario: GET - Retrieve product categories
  Given path '/categories'
  When method GET
  Then status 200
  And match response == '#[]'
  And match each response == '#string'

@regression @products @delete @cleanup
Scenario: DELETE - Cleanup test products
  # This scenario demonstrates cleanup operations
  # First, get all products to find test products
  When method GET
  Then status 200
  * def allProducts = response
  
  # Filter test products (those created by our tests)
  * def testProducts = karate.filter(allProducts, function(p){ return p.name.includes('Test Product') })
  
  # Delete each test product
  * def deleteProduct = 
    """
    function(product) {
      var result = karate.http(baseUrl + '/api/products/' + product.id, 'DELETE', null, defaultHeaders);
      return result.status == 204;
    }
    """
  * def deleteResults = karate.map(testProducts, deleteProduct)
  
  # Verify all deletions were successful
  * match each deleteResults == true