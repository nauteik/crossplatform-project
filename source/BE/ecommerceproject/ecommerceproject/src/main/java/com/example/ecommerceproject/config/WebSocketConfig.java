package com.example.ecommerceproject.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Thiết lập prefix cho message broker (kênh gửi tin nhắn)
        registry.enableSimpleBroker("/topic");
        // Thiết lập prefix cho message mapping (điểm nhận tin nhắn từ client)
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Đăng ký endpoint cho WebSocket, cho phép kết nối từ mọi nguồn (cross-origin)
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*");
                
        // Vẫn giữ lại endpoint với SockJS cho các client sử dụng SockJS
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }
} 