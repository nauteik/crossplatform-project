package com.example.ecommerceproject.model;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.HashMap;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReviewSummary {
    private String productId;
    private int totalReviews;
    private double averageRating;
    private Map<Integer, Integer> ratingDistribution; // {rating: count}
    
    public ReviewSummary(String productId) {
        this.productId = productId;
        this.totalReviews = 0;
        this.averageRating = 0.0;
        this.ratingDistribution = new HashMap<>();
        // Initialize distribution map with all possible ratings
        for (int i = 1; i <= 5; i++) {
            this.ratingDistribution.put(i, 0);
        }
    }
}