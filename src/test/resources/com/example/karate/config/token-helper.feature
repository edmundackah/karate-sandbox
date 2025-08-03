Feature: Token Helper - Manages authentication tokens for different environments

Background:
  * url tokenUrl
  * configure headers = defaultHeaders

Scenario: Get authentication token
  Given request tokenConfig
  When method POST
  Then status 200
  And match response == { 'iam-claimsetjwt': '#string' }
  
  # Store token information for use in other tests
  * def authHeader = { 'iam-claimsetjwt': response['iam-claimsetjwt'] }
  * karate.set('authToken', response['iam-claimsetjwt'])
  * karate.set('authKey', 'iam-claimsetjwt')
  * karate.set('authHeader', authHeader)
  
  # Log token details for debugging
  * karate.log('Token obtained: iam-claimsetjwt =', response['iam-claimsetjwt'].substring(0, 20) + '...')