package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.model.Message;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
public class WebSocketController {

    private final SimpMessagingTemplate messagingTemplate;

    @Autowired
    public WebSocketController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    // Phương thức này sẽ được gọi khi một tin nhắn được gửi đến từ client
    @MessageMapping("/chat/{userId}/{adminId}")
    public void processMessage(@DestinationVariable String userId, 
                              @DestinationVariable String adminId, 
                              @Payload Message message) {
        // Gửi tin nhắn đến kênh dành cho user
        messagingTemplate.convertAndSend("/topic/messages/" + userId + "/" + adminId, message);
        
        // Gửi tin nhắn đến kênh dành cho admin
        messagingTemplate.convertAndSend("/topic/admin-messages/" + adminId + "/" + userId, message);
    }
} 