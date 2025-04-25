package com.example.ecommerceproject.exception;

public enum ApiStatus {
    SUCCESS(200, "Success"),
    NOT_FOUND(404, "Not Found"),
    SERVER_ERROR(500, "Internal Server Error"),
    USER_ALREADY_EXISTS(400, "Username is already taken!"),
    EMAIL_ALREADY_EXISTS(401, "Email is already in use!"),
    NOT_AUTHOR(405, "Not Author"),
    INVALID_CREDENTIALS(402, "Invalid username or password"),
    INVALID_TOKEN(406, "Invalid token"),
    BAD_REQUEST(400, "Bad Request");

    private final int code;
    private final String message;

    ApiStatus(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }
}

