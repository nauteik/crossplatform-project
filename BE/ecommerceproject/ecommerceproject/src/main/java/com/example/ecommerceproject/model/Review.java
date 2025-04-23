package com.example.ecommerceproject.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "reviews")
@Data
@Getter
@Setter
public class Review {
    @Id
    private String id;
    private String productId;
    private String userId;
    private int rating; //danh gia sao
    private String comment;
    private List<Media> media = new ArrayList<>();
    
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime createdAt = LocalDateTime.now();
}

