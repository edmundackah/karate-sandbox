Feature: Authentication Helper - Reusable authentication functions

Background:
  * url baseUrl
  * configure headers = defaultHeaders

# Helper function to apply authentication headers
* def applyAuth = 
"""
function() {
  if (authHeader && authHeader['iam-claimsetjwt']) {
    karate.configure('headers', karate.merge(defaultHeaders, authHeader));
    return true;
  } else {
    karate.log('No authentication token available');
    return false;
  }
}
"""

# Helper function to apply auth headers for a specific request
* def withAuth = 
"""
function(path) {
  if (authHeader && authHeader['iam-claimsetjwt']) {
    karate.configure('headers', karate.merge(defaultHeaders, authHeader));
    karate.log('Applied authentication headers for:', path);
    return true;
  } else {
    karate.log('No authentication token available for:', path);
    return false;
  }
}
"""

# Helper function to get the current auth token
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

# Helper function to validate current auth token
* def validateCurrentAuth = 
"""
function() {
  if (!authHeader || !authHeader['iam-claimsetjwt']) {
    karate.log('No authentication token to validate');
    return false;
  }
  
  var token = authHeader['iam-claimsetjwt'];
  var response = karate.http('POST', baseUrl + '/api/token/validate-auth-header').headers(karate.merge(defaultHeaders, { 'iam-claimsetjwt': token })).send();
  
  if (response.status === 200 && response.body.valid === true) {
    karate.log('Current authentication token is valid');
    return true;
  } else {
    karate.log('Current authentication token is invalid:', response.body);
    return false;
  }
}
""" 