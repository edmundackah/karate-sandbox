Feature: Token Helper - Manages authentication tokens

Background:
  * url tokenUrl
  * configure headers = defaultHeaders

Scenario: Get authentication token
  * print '<<<<<<<<<< GENERATING NEW TOKEN >>>>>>>>>>'
  Given request tokenConfig
  When method POST
  Then status 200
  And match response == { 'iam-claimsetjwt': '#string' }

  # The 'authHeader' variable will be returned to the caller.
  * def authHeader = { 'iam-claimsetjwt': '#(response["iam-claimsetjwt"])' }
  * karate.set('authToken', authHeader)
  * karate.log('Token obtained: iam-claimsetjwt =', response['iam-claimsetjwt'].substring(0, 20) + '...')
