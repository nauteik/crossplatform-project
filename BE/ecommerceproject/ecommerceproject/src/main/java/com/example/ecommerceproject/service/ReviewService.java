package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.model.ReviewSummary;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public interface ReviewService {
    Review addReview(String productId, String userId, int rating, String comment, MultipartFile[] files) throws IOException;
    List<Review> getAllReviews();
    List<Review> getByProductId(String productId);
    ReviewSummary getReviewSummary(String productId);
    boolean deleteReview(String reviewId, String userId);
}