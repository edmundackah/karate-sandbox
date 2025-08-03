#!/bin/bash

# Karate Sandbox Test Runner Script
# This script provides easy commands to run different test scenarios

set -e

echo "🚀 Karate Sandbox Test Runner"
echo "================================"

# Check if Maven is available
if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed or not in PATH."
    echo "Please install Maven from https://maven.apache.org/install.html"
    exit 1
fi

# Function to print usage
print_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  compile         - Compile the project"
    echo "  start-api       - Start the Spring Boot API"
    echo "  smoke           - Run Karate smoke tests"
    echo "  smoke-dev       - Run Karate smoke tests against dev environment"
    echo "  smoke-aws       - Run Karate smoke tests with AWS token service"
    echo "  help            - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 compile"
    echo "  $0 smoke"
    echo "  $0 smoke-dev"
    echo "  $0 smoke-aws"
}

# Parse command line arguments
COMMAND=${1:-help}

case $COMMAND in
    compile)
        echo "🔨 Compiling project..."
        mvn clean compile
        echo "✅ Compilation successful!"
        ;;
    
    start-api)
        echo "🌐 Starting Spring Boot API..."
        echo "API will be available at http://localhost:8085"
        echo "Health check: http://localhost:8085/actuator/health"
        echo "Press Ctrl+C to stop"
        mvn spring-boot:run
        ;;
    
    smoke)
        echo "🧪 Running Karate smoke tests (local environment)..."
        mvn clean test -Pkarate-smoke -Dtest.env=local
        echo "✅ Smoke tests completed!"
        ;;
    
    smoke-dev)
        echo "🧪 Running Karate smoke tests (dev environment)..."
        mvn clean test -Pkarate-smoke -Dtest.env=dev
        echo "✅ Dev smoke tests completed!"
        ;;
    
    smoke-aws)
        echo "🧪 Running Karate smoke tests with AWS token service..."
        mvn clean test -Pkarate-smoke -Dtest.env=prod -Dis.aws=true
        echo "✅ AWS smoke tests completed!"
        ;;
    
    reports)
        echo "📊 Generating test reports..."
        mvn clean test -Pkarate-smoke -Dtest.env=local
        echo "📋 Reports generated at: target/karate-reports/"
        echo "🌐 Opening reports in browser..."
        open target/karate-reports/com.example.karate.config.setup.html 2>/dev/null || echo "Open manually: target/karate-reports/"
        ;;
    
    help)
        print_usage
        ;;
    
    *)
        echo "❌ Unknown command: $COMMAND"
        echo ""
        print_usage
        exit 1
        ;;
esac

# Show report location if tests were run
if [[ "$COMMAND" =~ ^(smoke|smoke-dev|smoke-aws)$ ]]; then
    echo ""
    echo "📊 Test reports available at:"
    echo "   target/karate-reports/karate-summary.html"
fi