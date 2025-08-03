#!/bin/bash

# Karate Sandbox Setup Validation Script
# This script validates that the project is set up correctly

set -e

echo "🔍 Karate Sandbox Setup Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $2 -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check Java
echo "Checking Java installation..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_status "Java found: $JAVA_VERSION" 0
    
    # Check if Java 17+
    if java -version 2>&1 | grep -q "1[7-9]\|[2-9][0-9]"; then
        print_status "Java version is 17 or higher" 0
    else
        print_status "Java version should be 17 or higher" 1
        echo "  Current version: $JAVA_VERSION"
        echo "  Download from: https://adoptium.net/"
    fi
else
    print_status "Java installation" 1
    echo "  Please install Java 17+ from https://adoptium.net/"
fi

# Check Maven
echo ""
echo "Checking Maven installation..."
if command -v mvn &> /dev/null; then
    MAVEN_VERSION=$(mvn -version 2>&1 | head -n 1 | cut -d' ' -f3)
    print_status "Maven found: $MAVEN_VERSION" 0
    
    # Check Maven version
    if mvn -version 2>&1 | grep -q "Apache Maven 3\.[8-9]\|Apache Maven [4-9]"; then
        print_status "Maven version is 3.8 or higher" 0
    else
        print_warning "Maven version should be 3.8 or higher for best compatibility"
        echo "  Current version: $MAVEN_VERSION"
    fi
else
    print_status "Maven installation" 1
    echo "  Please install Maven from https://maven.apache.org/download.cgi"
    echo "  Or use package manager:"
    echo "    macOS: brew install maven"
    echo "    Ubuntu: apt-get install maven"
fi

# Check project structure
echo ""
echo "Checking project structure..."

check_file() {
    if [ -f "$1" ]; then
        print_status "$1 exists" 0
    else
        print_status "$1 missing" 1
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        print_status "$1/ directory exists" 0
    else
        print_status "$1/ directory missing" 1
    fi
}

# Check key files
check_file "pom.xml"
check_file "README.md"
check_file "SETUP.md"
check_file "EXAMPLES.md"
check_file "run-examples.sh"
check_file ".gitignore"

# Check directory structure
check_dir "src/main/java"
check_dir "src/main/resources"
check_dir "src/test/java"
check_dir "src/test/resources"

# Check specific important files
check_file "src/main/java/com/example/karate/Application.java"
check_file "src/test/java/com/example/karate/KarateTest.java"
check_file "src/test/resources/karate-config.js"

# Check feature files
echo ""
echo "Checking feature files..."
check_file "src/test/resources/com/example/karate/config/setup.feature"
check_file "src/test/resources/com/example/karate/config/token-helper.feature"
check_file "src/test/resources/com/example/karate/users/users-crud.feature"
check_file "src/test/resources/com/example/karate/products/products-crud.feature"

# Check test data
echo ""
echo "Checking test data files..."
check_file "src/test/resources/testdata/products/new-product.json"
check_file "src/test/resources/testdata/users/bulk-users.json"

# Try compilation if Maven is available
echo ""
echo "Testing project compilation..."
if command -v mvn &> /dev/null; then
    echo "Running: mvn clean compile -q"
    if mvn clean compile -q; then
        print_status "Project compiles successfully" 0
        
        # Test that Karate tests are skipped by default
        echo ""
        echo "Testing default Maven behavior (should skip Karate tests)..."
        if mvn clean install -q > /dev/null 2>&1; then
            print_status "Default build skips Karate tests correctly" 0
        else
            print_status "Default build configuration needs review" 1
        fi
    else
        print_status "Project compilation failed" 1
        echo "  Run 'mvn clean compile' for detailed error messages"
    fi
else
    print_warning "Skipping compilation test (Maven not available)"
fi

# Summary
echo ""
echo "========================================"
echo "🎯 Validation Complete!"
echo ""
echo "📚 Next Steps:"
echo "1. Install any missing prerequisites"
echo "2. Run './run-examples.sh smoke' to test the framework"
echo "3. Start the API with './run-examples.sh start-api'"
echo "4. Explore the documentation in README.md"
echo ""
echo "🚀 Quick Commands:"
echo "  ./run-examples.sh help        - Show all available commands"
echo "  ./run-examples.sh smoke       - Run Karate smoke tests"
echo "  ./run-examples.sh start-api   - Start the Spring Boot API"
echo "  mvn clean install             - Build with JUnit tests only"
echo ""
echo "📊 After running tests, check reports at:"
echo "  target/karate-reports/karate-summary.html"