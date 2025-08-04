function authUtils() {
  
  /**
   * Get authentication headers based on whether auth is required
   * @param {Object} config - The karate config object
   * @param {boolean} forceAuth - Force authentication even if not required (optional)
   * @returns {Object} Headers object with either real auth token or dummy headers
   */
  var getAuthHeaders = function(config, forceAuth) {
    // If config is not passed, try to get it from karate context
    if (!config || typeof config !== 'object') {
      config = karate.get('config') || {};
    }
    var requiresAuth = forceAuth || config.requiresToken;
    
    if (!requiresAuth) {
      // Return dummy headers when auth is not required
      karate.log('Authentication not required, returning dummy headers');
      return {
        'X-Dummy-Auth': 'no-auth-required',
        'X-Request-ID': java.util.UUID.randomUUID().toString()
      };
    }
    
    // Check if we already have a cached token
    var cachedToken = karate.get('authToken');
    if (cachedToken && cachedToken['iam-claimsetjwt']) {
      karate.log('Using cached authentication token');
      return cachedToken;
    }
    
    // Get a new token
    karate.log('Getting new authentication token...');
    var tokenHelper = karate.call('classpath:com/example/karate/config/token-helper.feature', config);
    
    if (tokenHelper && tokenHelper.authHeader) {
      karate.log('Authentication token obtained successfully');
      return tokenHelper.authHeader;
    } else {
      karate.log('Failed to obtain authentication token');
      throw new Error('Unable to obtain authentication token');
    }
  };
  
  /**
   * Clear cached authentication token
   */
  var clearAuthToken = function() {
    karate.log('Clearing cached authentication token');
    karate.set('authToken', null);
  };
  
  /**
   * Check if current environment requires authentication
   * @param {Object} config - The karate config object
   * @returns {boolean} True if authentication is required
   */
  var isAuthRequired = function(config) {
    return config.requiresToken === true;
  };
  
  return {
    getAuthHeaders: getAuthHeaders,
    clearAuthToken: clearAuthToken,
    isAuthRequired: isAuthRequired
  };
}