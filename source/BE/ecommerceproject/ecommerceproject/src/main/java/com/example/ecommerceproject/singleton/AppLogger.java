package com.example.ecommerceproject.singleton;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AppLogger {
    private static AppLogger instance;
    private final Logger logger;

    private AppLogger() {
        this.logger = LoggerFactory.getLogger("AppLogger");
    }

    public static synchronized AppLogger getInstance() {
        if (instance == null) {
            instance = new AppLogger();
        }
        return instance;
    }

    public void info(String message) {
        logger.info(message);
    }

    public void info(String message, Object... args) {
        logger.info(message, args);
    }

    public void warn(String message, Object... args) {
        logger.warn(message, args);
    }

    public void error(String message, Object... args) {
        logger.error(message, args);
    }

    public void debug(String message, Object... args) {
        logger.debug(message, args);
    }

    public void trace(String message, Object... args) {
        logger.trace(message, args);
    }
}