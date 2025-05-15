package com.example.ecommerceproject.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "messages")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Message {
    @Id
    private String id;
    private String userId;     // ID của người dùng gửi tin nhắn
    private String adminId;    // ID của admin nhận tin nhắn
    private String content;    // Nội dung tin nhắn
    private List<String> images = new ArrayList<>();  // Danh sách tên file ảnh
    private boolean isFromUser; // true nếu tin nhắn từ user, false nếu từ admin
    private boolean isRead;    // Trạng thái đã đọc
    
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt = LocalDateTime.now();
}
