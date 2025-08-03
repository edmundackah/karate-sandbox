# 🥋 Karate Sandbox - Complete API Testing Framework

A comprehensive **Karate API testing framework** with Spring Boot backend, demonstrating best practices for behavior-driven development (BDD) and API automation.

## **🚀 Quick Start**

### 1. **Build & Test**
```bash
# Build project (unit tests only) 
mvn clean install

# Run all Karate API tests
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local

# Run specific test features
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="classpath:com/example/karate/config/working-auth-validation.feature"
```

### 2. **Using Tags for Selective Testing**
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

### 3. **View Test Reports**
```bash
# Open test reports in browser
open target/karate-reports/*.html
```

### 4. **Test Different Environments**
```bash
# Local environment (default)
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local

# Development environment
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=dev -Dis.aws=true

# Production environment
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=prod
```

## **🧪 Test Examples**
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

## **📚 Documentation**
- **[SETUP.md](SETUP.md)** - Step-by-step installation instructions
- **[EXAMPLES.md](EXAMPLES.md)** - Detailed test examples with explanations
- **[TEST_EXAMPLES_EXPLAINED.md](TEST_EXAMPLES_EXPLAINED.md)** - In-depth test breakdowns

## **🔐 Authentication Header Validation**

The sandbox includes a comprehensive JWT token validation system:

### **New Authentication Endpoint**
- **POST** `/api/token/validate-auth-header` - Validates JWT tokens in the `iam-claimsetjwt` header

### **Validation Features**
- ✅ JWT structure validation (header.payload.signature)
- ✅ JWT header validation (type and algorithm)
- ✅ JWT payload validation (required claims: sub, iat, exp)
- ✅ Token expiration checking
- ✅ Detailed error responses with status codes

### **Test the Authentication Validation**
```bash
# Run authentication validation tests
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="classpath:com/example/karate/config/working-auth-validation.feature"

# Run all authentication tests
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @auth"

# Run validation tests only
mvn clean test -Dtest=SmokeTestRunner -Dtest.env=local -Dkarate.options="--tags @validation"
```