package com.example.ecommerceproject.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CorsFilter extends OncePerRequestFilter {

    // Danh sách các domain được phép truy cập
    private final List<String> allowedOrigins = Arrays.asList(
            "https://hkt-user.netlify.app",
            "https://hkt-admin.netlify.app",
            "http://localhost:3000",
            "http://localhost:8080"
    );

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        
        String origin = request.getHeader("Origin");
        
        // Kiểm tra xem origin có trong danh sách được phép không
        if (origin != null && allowedOrigins.contains(origin)) {
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Access-Control-Allow-Credentials", "true");
        } else if (origin != null) {
            // Nếu không có trong danh sách nhưng vẫn có origin, log và cho phép trong môi trường dev
            logger.info("Request from unauthorized origin: " + origin);
            response.setHeader("Access-Control-Allow-Origin", origin);
            response.setHeader("Access-Control-Allow-Credentials", "true");
        } else {
            // Mặc định nếu không có origin
            response.setHeader("Access-Control-Allow-Origin", "*");
        }
        
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, PATCH");
        response.setHeader("Access-Control-Max-Age", "3600");
        response.setHeader("Access-Control-Allow-Headers", "authorization, content-type, x-auth-token, x-requested-with, accept, origin, access-control-request-method, access-control-request-headers");
        response.setHeader("Access-Control-Expose-Headers", "x-auth-token, authorization");
        
        // Xử lý riêng cho preflight request (OPTIONS)
        if ("OPTIONS".equals(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            filterChain.doFilter(request, response);
        }
    }
} 