package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.model.ReviewSummary;
import com.example.ecommerceproject.repository.ReviewRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class BaseReviewService implements ReviewService {

    @Autowired
    private ReviewRepository reviewRepository;

    @Override
    public Review addReview(String productId, String userId, int rating, String comment, MultipartFile[] files) {
        Review review = new Review();
        review.setProductId(productId);
        review.setUserId(userId);
        review.setRating(rating);
        review.setComment(comment);
        return reviewRepository.save(review);
    }

    @Override
    public List<Review> getAllReviews() {
        return reviewRepository.findAll();
    }

    @Override
    public List<Review> getByProductId(String productId) {
        return reviewRepository.findByProductId(productId);
    }

    @Override
    public ReviewSummary getReviewSummary(String productId) {
        List<Review> reviews = reviewRepository.findByProductId(productId);
        ReviewSummary summary = new ReviewSummary(productId);
        
        if (!reviews.isEmpty()) {
            int totalReviews = reviews.size();
            double sum = 0;
            Map<Integer, Integer> distribution = new HashMap<>();
            
            // Initialize distribution map
            for (int i = 1; i <= 5; i++) {
                distribution.put(i, 0);
            }
            
            // Calculate sum and update distribution
            for (Review review : reviews) {
                int rating = review.getRating();
                sum += rating;
                
                // Update distribution count
                distribution.put(rating, distribution.getOrDefault(rating, 0) + 1);
            }
            
            double average = sum / totalReviews;
            
            // Round to 1 decimal place
            average = Math.round(average * 10.0) / 10.0;
            
            summary.setTotalReviews(totalReviews);
            summary.setAverageRating(average);
            summary.setRatingDistribution(distribution);
        } else {
            // No reviews yet
            summary.setTotalReviews(0);
            summary.setAverageRating(0);
        }
        
        return summary;
    }

    @Override
    public boolean deleteReview(String reviewId, String userId) {
        Optional<Review> review = reviewRepository.findById(reviewId);
        if (review.isPresent() && review.get().getUserId().equals(userId)) {
            reviewRepository.deleteById(reviewId);
            return true;
        }
        return false;
    }
}