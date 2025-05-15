package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;
import java.util.List;
import java.util.Map;
import java.util.ArrayList;
import java.util.HashMap;
import java.time.LocalDateTime;

@Document(collection = "products")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Product {
    @Id
    private String id;
    
    private String name;
    private double price;
    private int quantity;
    private String description;
    private String primaryImageUrl; // Ảnh chính
    private List<String> imageUrls; // Danh sách các ảnh khác
    private int soldCount;
    private double discountPercent;
    private LocalDateTime createdAt = LocalDateTime.now(); // Thời gian tạo sản phẩm
    
    // Technical specifications for components
    private Map<String, String> specifications = new HashMap<>();
    
    @DBRef
    private Brand brand;
    
    @DBRef
    private ProductType productType;
    
    @DBRef
    private List<Tag> tags = new ArrayList<>();
    
    // Helper methods for component compatibility
    public String getSocketType() {
        if (specifications != null && specifications.containsKey("socket")) {
            return specifications.get("socket");
        } else if (description != null) {
            // Try to parse from description as fallback
            String desc = description.toLowerCase();
            
            // Common Intel sockets
            if (desc.contains("lga1700")) return "LGA1700";
            if (desc.contains("lga1200")) return "LGA1200";
            if (desc.contains("lga1151")) return "LGA1151";
            
            // Common AMD sockets
            if (desc.contains("am5")) return "AM5";
            if (desc.contains("am4")) return "AM4";
            if (desc.contains("tr4")) return "TR4"; // ThreadRipper
        }
        
        return null;
    }
    
    public String getChipset() {
        if (specifications != null && specifications.containsKey("chipset")) {
            return specifications.get("chipset");
        } else if (description != null) {
            String desc = description.toLowerCase();
            
            // Intel chipsets
            if (desc.contains("z690")) return "Z690";
            if (desc.contains("z590")) return "Z590";
            if (desc.contains("b660")) return "B660";
            
            // AMD chipsets
            if (desc.contains("x570")) return "X570";
            if (desc.contains("b550")) return "B550";
        }
        
        return null;
    }
    
    public String getRamType() {
        if (specifications != null && specifications.containsKey("memory_type")) {
            return specifications.get("memory_type");
        } else if (description != null) {
            String desc = description.toLowerCase();
            
            if (desc.contains("ddr5")) return "DDR5";
            if (desc.contains("ddr4")) return "DDR4";
            if (desc.contains("ddr3")) return "DDR3";
        }
        
        return null;
    }
}