package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Message;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/messages")
@CrossOrigin(origins = "*")
public class MessageController {

    private final MessageService messageService;

    @Autowired
    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    // Gửi tin nhắn từ user đến admin
    @PostMapping("/user-send")
    public ResponseEntity<ApiResponse<Message>> sendMessageFromUser(
            @RequestParam("userId") String userId,
            @RequestParam("content") String content,
            @RequestParam(value = "images", required = false) List<MultipartFile> images) {
        try {
            Message message = messageService.sendMessageFromUser(userId, content, images);
            ApiResponse<Message> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    message
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IOException e) {
            ApiResponse<Message> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error processing image upload: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // Gửi tin nhắn từ admin đến user
    @PostMapping("/admin-send")
    public ResponseEntity<ApiResponse<Message>> sendMessageFromAdmin(
            @RequestParam("adminId") String adminId,
            @RequestParam("userId") String userId,
            @RequestParam("content") String content,
            @RequestParam(value = "images", required = false) List<MultipartFile> images) {
        try {
            Message message = messageService.sendMessageFromAdmin(adminId, userId, content, images);
            ApiResponse<Message> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    message
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IOException e) {
            ApiResponse<Message> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error processing image upload: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // Lấy cuộc hội thoại giữa user và admin
    @GetMapping("/conversation")
    public ResponseEntity<ApiResponse<List<Message>>> getConversation(
            @RequestParam("userId") String userId,
            @RequestParam("adminId") String adminId) {
        List<Message> conversation = messageService.getConversationBetweenUserAndAdmin(userId, adminId);
        ApiResponse<List<Message>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                conversation
        );
        return ResponseEntity.ok(response);
    }

    // Lấy danh sách users đã gửi tin nhắn cho admin
    @GetMapping("/admin/{adminId}/users")
    public ResponseEntity<ApiResponse<List<User>>> getUsersWithMessages(@PathVariable String adminId) {
        List<User> users = messageService.getUsersWithMessages(adminId);
        ApiResponse<List<User>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                users
        );
        return ResponseEntity.ok(response);
    }

    // Đánh dấu tin nhắn đã đọc
    @PostMapping("/mark-read")
    public ResponseEntity<ApiResponse<Void>> markMessagesAsRead(
            @RequestParam("userId") String userId,
            @RequestParam("adminId") String adminId) {
        messageService.markAllMessagesAsRead(userId, adminId);
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage()
        );
        return ResponseEntity.ok(response);
    }

    // Đếm số lượng tin nhắn chưa đọc
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Map<String, Long>>> getUnreadMessageCount() {
        long count = messageService.countUnreadMessagesFromUsers();
        ApiResponse<Map<String, Long>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                Map.of("count", count)
        );
        return ResponseEntity.ok(response);
    }

    // Xóa tin nhắn
    @DeleteMapping("/delete/{messageId}")
    public ResponseEntity<ApiResponse<Void>> deleteMessage(@PathVariable String messageId) {
        boolean deleted = messageService.deleteMessage(messageId);
        if (deleted) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage()
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
} 