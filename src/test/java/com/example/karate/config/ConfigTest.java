package com.example.karate.config;

import com.intuit.karate.junit5.Karate;

/**
 * Test runner specifically for configuration and setup tests.
 */
public class ConfigTest {

    @Karate.Test
    Karate testConfig() {
        return Karate.run("classpath:com/example/karate/config").relativeTo(getClass());
    }
}