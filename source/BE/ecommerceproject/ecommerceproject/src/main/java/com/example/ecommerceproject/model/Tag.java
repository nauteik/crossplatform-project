package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import java.time.LocalDateTime;

@Document(collection = "tags")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Tag {
    @Id
    private String id;
    private String name; // VD: "Promotional", "New", "Best Seller"
    private String color; // Mã màu để hiển thị (VD: "#FF0000" cho đỏ)
    private String description; // Mô tả chi tiết về tag
    private LocalDateTime createdAt = LocalDateTime.now();
    private boolean active = true; // Trạng thái tag có đang active hay không
} 