# 🥋 Karate API Testing Sandbox

## Overview

This Karate Sandbox project includes comprehensive documentation to help you get started quickly and write efficient test suites.

## **Build & Test**
```bash
# Build project (unit tests only) 
mvn clean install

# Run all Karate API tests
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local

# Run specific test features
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="classpath:com/example/karate/config/auth-header-validation.feature"
```

### **Using Tags for Selective Testing**
```bash
# Run tests with specific tags
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @smoke"
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @auth"
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @validation"
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @users"
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @products"

# Run multiple tags (AND logic)
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @smoke @auth"

# Run multiple tags (OR logic)
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @smoke,@auth"
```

### **View Test Reports**
```bash
# Open test reports in browser
open target/karate-reports/*.html
```

### **Test Different Environments**
```bash
# Local environment (default)
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local

# Development environment
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=dev -Dis.aws=true

# Production environment
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=prod
```

## ** Test Examples**
- **Setup & Health Checks** - API connectivity validation
- **User CRUD Operations** - Complete lifecycle testing  
- **Advanced Scenarios** - Conditional logic and dynamic requests
- **E2E Tests** - End-to-end workflows
- **Authentication Header Validation** - JWT token validation and testing

### **Available Test Tags**
- `@smoke` - Quick smoke tests for basic functionality
- `@auth` - Authentication and authorization tests
- `@validation` - Input validation and error handling tests
- `@users` - User management CRUD operations
- `@products` - Product catalog operations
- `@integration` - End-to-end integration tests
- `@error-handling` - Error scenarios and edge cases

### **API Endpoints**
```bash
# Health checks
GET  http://localhost:8085/api/health
GET  http://localhost:8085/actuator/health

# User management  
GET    http://localhost:8085/api/users
POST   http://localhost:8085/api/users
PUT    http://localhost:8085/api/users/{id}
DELETE http://localhost:8085/api/users/{id}

# Product catalog
GET  http://localhost:8085/api/products

# Authentication  
POST http://localhost:8085/api/token/generate
POST http://localhost:8085/api/token/validate-auth-header
```

## ** Authentication System**

- **Automatic Token Management**: Handles token generation and caching automatically
- **Environment-Aware**: Returns real tokens or dummy headers based on configuration
- **Zero Configuration**: Just call `getAuthHeaders()` in your tests

### **Authentication Endpoints**
- **POST** `/api/token/generate` - Generates JWT tokens
- **POST** `/api/token/validate-auth-header` - Validates JWT tokens in the `iam-claimsetjwt` header

### **How to Use in Tests**
```gherkin
Background:
  * url baseUrl
  * configure headers = karate.merge(defaultHeaders, getAuthHeaders())

Scenario: Your test
  Given path '/api/users'
  When method GET
  Then status 200
```

## **Run Tests with Different Environments**
```bash
# Run with authentication (default)
mvn clean test -Dtest.env=local

# Run without authentication (mock environment)
mvn clean test -Dtest.env=mock

# Run specific authentication tests
mvn clean test -Dkarate.options="--tags @auth"
```