package com.example.karate;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

/**
 * Karate smoke test runner that properly fails Maven build on test failures
 * and generates JUnit XML reports for CI/CD integration.
 * 
 * Usage:
 * - mvn clean test -Pkarate-smoke -Dtest.env=local
 * 
 * Reports generated:
 * - target/karate-reports/karate-summary.html (HTML)
 * - target/surefire-reports/TEST-*.xml (JUnit XML for GitLab CI)
 */
public class SmokeTestRunner {

    @Test
    void testSmoke() {
        Results results = Runner.path("classpath:com/example/karate")
                .tags("@smoke")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .reportDir("target/karate-reports")
                .parallel(6);
        
        // This will fail the Maven build if any scenarios fail
        assertTrue(results.getFailCount() == 0,
            String.format("Karate tests failed! Failed scenarios: %d. Details: %s", 
                results.getFailCount(), results.getErrorMessages()));
    }
}