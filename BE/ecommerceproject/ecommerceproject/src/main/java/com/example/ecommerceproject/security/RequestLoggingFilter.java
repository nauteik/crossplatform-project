package com.example.ecommerceproject.security;

import com.example.ecommerceproject.singleton.AppLogger;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Enumeration;

@Component
public class RequestLoggingFilter implements Filter {

    private static final AppLogger logger = AppLogger.getInstance();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Log thông tin request
        logger.info("REQUEST: {} {}", httpRequest.getMethod(), httpRequest.getRequestURI());
        logger.info("QUERY STRING: {}", httpRequest.getQueryString());
        
        // Log các headers
        Enumeration<String> headerNames = httpRequest.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String headerName = headerNames.nextElement();
            logger.info("HEADER {}: {}", headerName, httpRequest.getHeader(headerName));
        }
        
        // Tiếp tục chuỗi filter
        chain.doFilter(request, response);
        
        // Log status code
        logger.info("RESPONSE STATUS: {}", httpResponse.getStatus());
        
        // Đặc biệt log các redirect (3xx)
        if (httpResponse.getStatus() >= 300 && httpResponse.getStatus() < 400) {
            logger.info("REDIRECT URL: {}", httpResponse.getHeader("Location"));
        }
    }
}