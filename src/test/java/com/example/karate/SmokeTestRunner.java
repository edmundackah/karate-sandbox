package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Karate smoke test runner using updated karatelabs dependency.
 * This runs tests tagged with @smoke and generates a single consolidated HTML report.
 * 
 * Usage:
 * - mvn clean test -Pkarate-smoke -Dtest.env=local
 * 
 * Report will be generated at: target/karate-reports/karate-summary.html
 */
public class SmokeTestRunner {

    @Karate.Test
    Karate testSmoke() {
        return Karate.run("classpath:com/example/karate")
                .tags("@smoke")
                .karateEnv("local")
                .relativeTo(getClass());
    }
}