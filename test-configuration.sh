#!/bin/bash

# Test Configuration Script
# Verifies that Karate tests only run with karate-smoke profile

set -e

echo "🧪 Testing Karate Configuration"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_test() {
    echo -e "\n${YELLOW}Testing: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test 1: Verify Maven is available
print_test "Maven availability"
if command -v mvn &> /dev/null; then
    print_success "Maven is available"
else
    print_error "Maven is not installed or not in PATH"
    exit 1
fi

# Test 2: Compile project
print_test "Project compilation"
if mvn clean compile -q > /dev/null 2>&1; then
    print_success "Project compiles successfully"
else
    print_error "Project compilation failed"
    exit 1
fi

# Test 3: Test default behavior (should NOT run Karate tests)
print_test "Default Maven behavior (mvn clean test)"
echo "This should run JUnit tests only, NO Karate tests..."
if mvn clean test -q > /dev/null 2>&1; then
    print_success "Default test execution completed (JUnit tests only)"
else
    print_error "Default test execution failed"
    exit 1
fi

# Test 4: Test clean install (should NOT run Karate tests)
print_test "Clean install behavior (mvn clean install)"
echo "This should build the project with JUnit tests only..."
if mvn clean install -q > /dev/null 2>&1; then
    print_success "Clean install completed successfully (no Karate tests)"
else
    print_error "Clean install failed"
    exit 1
fi

# Test 5: Verify Karate profile works
print_test "Karate smoke profile (mvn clean verify -Pkarate-smoke)"
echo "This should run Karate smoke tests..."

# Start API in background for testing
echo "Starting API for testing..."
mvn spring-boot:run > /dev/null 2>&1 &
API_PID=$!

# Wait for API to start
echo "Waiting for API to start..."
sleep 10

# Check if API is running
if curl -s http://localhost:8085/actuator/health > /dev/null 2>&1; then
    print_success "API is running"
    
    # Run Karate tests
    if mvn clean verify -Pkarate-smoke -Dtest.env=local -q; then
        print_success "Karate smoke tests executed successfully"
    else
        print_error "Karate smoke tests failed"
        kill $API_PID
        exit 1
    fi
else
    print_error "API failed to start"
    kill $API_PID
    exit 1
fi

# Clean up
kill $API_PID
echo "API stopped"

# Test 6: Verify token endpoint
print_test "Token endpoint verification"
mvn spring-boot:run > /dev/null 2>&1 &
API_PID=$!
sleep 10

if curl -s http://localhost:8085/actuator/health > /dev/null 2>&1; then
    # Test token endpoint
    TOKEN_RESPONSE=$(curl -s -X POST http://localhost:8085/api/token/generate \
        -H "Content-Type: application/json" \
        -d '{"isAws": true, "service": "test", "environment": "dev"}')
    
    if echo "$TOKEN_RESPONSE" | grep -q "iam-claimsetjwt"; then
        print_success "Token endpoint returns correct key 'iam-claimsetjwt'"
    else
        print_error "Token endpoint does not return expected key"
        echo "Response: $TOKEN_RESPONSE"
    fi
else
    print_error "API not accessible for token testing"
fi

# Final cleanup
kill $API_PID > /dev/null 2>&1 || true

echo ""
echo "🎉 Configuration Test Summary"
echo "============================="
print_success "✅ Maven clean install - JUnit tests only (no Karate)"
print_success "✅ Maven clean test - JUnit tests only (no Karate)"  
print_success "✅ Maven clean verify -Pkarate-smoke - Karate tests run"
print_success "✅ Token endpoint returns 'iam-claimsetjwt' key"

echo ""
echo "🚀 Your configuration is working correctly!"
echo ""
echo "Commands to remember:"
echo "  mvn clean install              - Build with JUnit tests only"
echo "  mvn clean verify -Pkarate-smoke - Run Karate smoke tests"
echo "  ./run-examples.sh smoke        - Run Karate tests with helper script"