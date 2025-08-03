# 🥋 Karate Sandbox - Complete API Testing Framework

A comprehensive **Karate API testing framework** with Spring Boot backend, demonstrating best practices for behavior-driven development (BDD) and API automation.

## **Build & Test**
```bash
# Build project (unit tests only) 
mvn clean install

# Run Karate API tests
mvn clean test -Pkarate-smoke -Dtest.env=local
```

### 2. **View Test Reports**
```bash
# Open test reports in browser
open target/karate-reports/*.html
```

### 3. **Test Different Environments**
```bash
# Local environment (default)
mvn clean test -Pkarate-smoke -Dtest.env=local

# Development environment
mvn clean test -Pkarate-smoke -Dtest.env=dev -Dis.aws=true
```

## **Test Examples**
- **Setup & Health Checks** - API connectivity validation
- **User CRUD Operations** - Complete lifecycle testing  
- **Advanced Scenarios** - Conditional logic and dynamic requests
- **E2E Tests** - End-to-end workflows

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
```

## **Documentation**
- **[SETUP.md](SETUP.md)** - Step-by-step installation instructions
- **[EXAMPLES.md](EXAMPLES.md)** - Detailed test examples with explanations
- **[TEST_EXAMPLES_EXPLAINED.md](TEST_EXAMPLES_EXPLAINED.md)** - In-depth test breakdowns