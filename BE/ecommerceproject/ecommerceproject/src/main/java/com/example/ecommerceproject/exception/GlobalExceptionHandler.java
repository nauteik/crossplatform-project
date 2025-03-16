package com.example.ecommerceproject.exception;

import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ControllerAdvice;

@ControllerAdvice
public class GlobalExceptionHandler {


    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<String>> handleGeneralException(Exception ex) {
        return ResponseEntity.status(ApiStatus.SERVER_ERROR.getCode())
                .body(new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), "An error occurred: " + ex.getMessage(), null));
    }
}
