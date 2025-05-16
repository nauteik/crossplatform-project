package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Message;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.MessageRepository;
import com.example.ecommerceproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class MessageService {

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final FileStorageService fileStorageService;
    private final SimpMessagingTemplate messagingTemplate;

    @Autowired
    public MessageService(MessageRepository messageRepository, UserRepository userRepository, 
                         FileStorageService fileStorageService, SimpMessagingTemplate messagingTemplate) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
        this.fileStorageService = fileStorageService;
        this.messagingTemplate = messagingTemplate;
    }

    // Lấy admin mặc định (đầu tiên có role = 1)
    public User getDefaultAdmin() {
        return userRepository.findAll().stream()
                .filter(user -> user.getRole() == 1)
                .findFirst()
                .orElse(null);
    }

    // Gửi tin nhắn từ user đến admin
    public Message sendMessageFromUser(String userId, String content, 
                                      List<MultipartFile> images) throws IOException {
        Message message = new Message();
        message.setUserId(userId);
        message.setContent(content);
        message.setFromUser(true);
        message.setRead(false);
        
        // Lấy admin mặc định
        User admin = getDefaultAdmin();
        if (admin != null) {
            message.setAdminId(admin.getId());
        }
        
        // Xử lý các hình ảnh
        List<String> imageNames = new ArrayList<>();
        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {
                String imageName = fileStorageService.saveFile(image);
                imageNames.add(imageName);
            }
        }
        message.setImages(imageNames);
        
        Message savedMessage = messageRepository.save(message);
        
        // Gửi thông báo qua WebSocket sau khi lưu tin nhắn
        notifyMessageSent(savedMessage);
        
        return savedMessage;
    }
    
    // Gửi tin nhắn từ admin đến user
    public Message sendMessageFromAdmin(String adminId, String userId, String content, 
                                      List<MultipartFile> images) throws IOException {
        Message message = new Message();
        message.setAdminId(adminId);
        message.setUserId(userId);
        message.setContent(content);
        message.setFromUser(false);
        message.setRead(false);
        
        // Xử lý các hình ảnh
        List<String> imageNames = new ArrayList<>();
        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {
                String imageName = fileStorageService.saveFile(image);
                imageNames.add(imageName);
            }
        }
        message.setImages(imageNames);
        
        Message savedMessage = messageRepository.save(message);
        
        // Gửi thông báo qua WebSocket sau khi lưu tin nhắn
        notifyMessageSent(savedMessage);
        
        return savedMessage;
    }
    
    // Phương thức gửi thông báo qua WebSocket
    private void notifyMessageSent(Message message) {
        // Gửi tin nhắn đến kênh dành cho user
        messagingTemplate.convertAndSend(
            "/topic/messages/" + message.getUserId() + "/" + message.getAdminId(), 
            message
        );
        
        // Gửi tin nhắn đến kênh dành cho admin
        messagingTemplate.convertAndSend(
            "/topic/admin-messages/" + message.getAdminId() + "/" + message.getUserId(), 
            message
        );
    }
    
    // Lấy toàn bộ tin nhắn giữa user và admin
    public List<Message> getConversationBetweenUserAndAdmin(String userId, String adminId) {
        return messageRepository.findByUserIdAndAdminIdOrderByCreatedAtDesc(userId, adminId);
    }
    
    // Lấy danh sách users đã gửi tin nhắn cho admin
    public List<User> getUsersWithMessages(String adminId) {
        List<String> userIds = messageRepository.findByAdminIdOrderByCreatedAtDesc(adminId)
                .stream()
                .map(Message::getUserId)
                .distinct()
                .collect(Collectors.toList());
        
        List<User> users = new ArrayList<>();
        for (String userId : userIds) {
            Optional<User> user = userRepository.findById(userId);
            user.ifPresent(users::add);
        }
        
        return users;
    }
    
    // Đánh dấu tất cả tin nhắn của user đã được đọc
    public void markAllMessagesAsRead(String userId, String adminId) {
        List<Message> messages = messageRepository.findByUserIdAndAdminIdOrderByCreatedAtDesc(userId, adminId);
        for (Message message : messages) {
            if (!message.isRead() && message.isFromUser()) {
                message.setRead(true);
                messageRepository.save(message);
                
                // Thông báo tin nhắn đã đọc qua WebSocket
                messagingTemplate.convertAndSend(
                    "/topic/messages/read/" + userId + "/" + adminId, 
                    message.getId()
                );
            }
        }
    }
    
    // Đếm số lượng tin nhắn chưa đọc từ user
    public long countUnreadMessagesFromUsers() {
        return messageRepository.findByIsReadFalseAndIsFromUserTrue().size();
    }
    
    // Xóa tin nhắn
    public boolean deleteMessage(String messageId) {
        try {
            Optional<Message> messageOpt = messageRepository.findById(messageId);
            if (messageOpt.isPresent()) {
                Message message = messageOpt.get();
                
                // Xóa các ảnh trong tin nhắn
                for (String imageName : message.getImages()) {
                    fileStorageService.deleteFile(imageName);
                }
                
                messageRepository.deleteById(messageId);
                
                // Thông báo tin nhắn đã bị xóa qua WebSocket
                messagingTemplate.convertAndSend(
                    "/topic/messages/deleted/" + message.getUserId() + "/" + message.getAdminId(), 
                    messageId
                );
                
                return true;
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }
} 