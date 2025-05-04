package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.HashMap;
import java.util.Map;

@Document(collection = "custom_pcs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PC {
    @Id
    private String id;
    
    private String name;
    private String userId;
    private double totalPrice;
    
    @DBRef
    private Product cpu;
    
    @DBRef
    private Product motherboard;
    
    @DBRef
    private Product gpu;
    
    @DBRef
    private Product ram;
    
    @DBRef
    private Product storage;
    
    @DBRef
    private Product powerSupply;
    
    @DBRef
    private Product pcCase;
    
    @DBRef
    private Product cooling;
    
    private Map<String, String> compatibilityNotes = new HashMap<>();
    private boolean isComplete = false;
    private String buildStatus; // "compatible", "incompatible", "incomplete"
}