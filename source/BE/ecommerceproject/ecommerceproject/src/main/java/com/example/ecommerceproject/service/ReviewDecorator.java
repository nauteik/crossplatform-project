package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.model.ReviewSummary;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

public abstract class ReviewDecorator implements ReviewService {
    protected final ReviewService decoratedReviewService;

    public ReviewDecorator(ReviewService decoratedReviewService) {
        this.decoratedReviewService = decoratedReviewService;
    }

    @Override
    public Review addReview(String productId, String userId, int rating, String comment, MultipartFile[] files) throws IOException {
        return decoratedReviewService.addReview(productId, userId, rating, comment, files);
    }

    @Override
    public List<Review> getAllReviews() {
        return decoratedReviewService.getAllReviews();
    }

    @Override
    public List<Review> getByProductId(String productId) {
        return decoratedReviewService.getByProductId(productId);
    }

    @Override
    public ReviewSummary getReviewSummary(String productId) {
        return decoratedReviewService.getReviewSummary(productId);
    }

    @Override
    public boolean deleteReview(String reviewId, String userId) {
        return decoratedReviewService.deleteReview(reviewId, userId);
    }
}