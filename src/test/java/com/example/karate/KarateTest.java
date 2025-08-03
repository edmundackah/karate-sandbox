package com.example.karate;

import com.intuit.karate.junit5.Karate;

/**
 * Main Karate test runner that executes all feature files.
 * This class is picked up by Maven Failsafe plugin when running integration tests.
 */
public class KarateTest {

    @Karate.Test
    Karate testAll() {
        return Karate.run().relativeTo(getClass());
    }
}