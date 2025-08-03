#!/bin/bash

# Authentication Header Verification Script
# This script runs the auth verification test to confirm headers are properly sent

echo "🔐 Verifying Authentication Headers..."
echo "======================================"

# Set environment (default to local if not specified)
ENV=${1:-local}
echo "Environment: $ENV"

# Run the auth verification test
mvn clean test \
    -Dtest=SmokeTestRunner \
    -Dtest.env=$ENV \
    -Dkarate.options="--tags @smoke" \
    -Dkarate.options="classpath:com/example/karate/config/auth-verification.feature"

echo ""
echo "✅ Authentication header verification completed!"
echo "Check the logs above to confirm headers are being sent correctly."
echo ""
echo "📊 Reports available at:"
echo "   - target/karate-reports/karate-summary.html"
echo "   - target/surefire-reports/" 