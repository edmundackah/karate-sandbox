Feature: Simple Authentication Helper - Easy-to-use auth functions

Background:
  * url baseUrl
  * configure headers = defaultHeaders

# Simple function to apply auth headers
* def applyAuth = 
"""
function() {
  if (authHeader && authHeader['iam-claimsetjwt']) {
    karate.configure('headers', karate.merge(defaultHeaders, authHeader));
    karate.log('Authentication headers applied successfully');
    return true;
  } else {
    karate.log('No authentication token available');
    return false;
  }
}
"""

# Function to get auth token
* def getAuthToken = 
"""
function() {
  if (authHeader && authHeader['iam-claimsetjwt']) {
    return authHeader['iam-claimsetjwt'];
  } else {
    karate.log('No authentication token available');
    return null;
  }
}
"""

# Function to validate auth token
* def validateAuth = 
"""
function() {
  if (!authHeader || !authHeader['iam-claimsetjwt']) {
    karate.log('No authentication token to validate');
    return false;
  }
  
  var token = authHeader['iam-claimsetjwt'];
  karate.configure('headers', karate.merge(defaultHeaders, { 'iam-claimsetjwt': token }));
  
  var response = karate.http('POST', baseUrl + '/api/token/validate-auth-header').send();
  
  if (response.status === 200 && response.body.valid === true) {
    karate.log('Authentication token is valid');
    return true;
  } else {
    karate.log('Authentication token is invalid:', response.body);
    return false;
  }
}
""" 