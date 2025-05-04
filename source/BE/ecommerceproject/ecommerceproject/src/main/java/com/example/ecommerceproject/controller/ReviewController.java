package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.model.ReviewSummary;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.ReviewService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin("*")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Review>> uploadReview(
            @RequestParam String productId,
            @RequestParam String userId,
            @RequestParam int rating,
            @RequestParam String comment,
            @RequestPart(required = false) MultipartFile[] files
    ) throws IOException {

        try {
            if (rating < 1 || rating > 5) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), "Rating phải từ 1 đến 5 sao", null)
                );
            }
            
            Review savedReview = reviewService.addReview(productId, userId, rating, comment, files);
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), ApiStatus.SUCCESS.getMessage(), savedReview));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Review>>> getAllReviews() {
        try {
            List<Review> reviews = reviewService.getAllReviews();
            if (reviews.isEmpty()) {
                return ResponseEntity.ok(new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "No reviews found", reviews));
            }
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), ApiStatus.SUCCESS.getMessage(), reviews));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ApiResponse<List<Review>>> getByProduct(@PathVariable String productId) {
        try {
            List<Review> reviews = reviewService.getByProductId(productId);
            if (reviews.isEmpty()) {
                return ResponseEntity.ok(new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "No reviews found for this product", reviews));
            }
            
            // Sort reviews by createdAt (newest first)
            reviews.sort((r1, r2) -> r2.getCreatedAt().compareTo(r1.getCreatedAt()));
            
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), ApiStatus.SUCCESS.getMessage(), reviews));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }
    
    @GetMapping("/summary/{productId}")
    public ResponseEntity<ApiResponse<ReviewSummary>> getAverageRating(@PathVariable String productId) {
        try {
            ReviewSummary summary = reviewService.getReviewSummary(productId);
            
            if (summary.getTotalReviews() > 0) {
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(), 
                    ApiStatus.SUCCESS.getMessage(), 
                    summary));
            } else {
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(), 
                    "No reviews found for this product", 
                    summary));
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }

    @DeleteMapping("/{reviewId}/{userId}")
    public ResponseEntity<ApiResponse<String>> deleteReview(@PathVariable String reviewId, @PathVariable String userId) {
        try {
            boolean deleted = reviewService.deleteReview(reviewId, userId);
            
            if (deleted) {
                return ResponseEntity.ok(
                    new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Đã xóa đánh giá thành công", reviewId)
                );
            } else {
                return ResponseEntity.status(403).body(
                    new ApiResponse<>(ApiStatus.NOT_AUTHOR.getCode(), "Bạn không có quyền xóa đánh giá này hoặc đánh giá không tồn tại", null)
                );
            }
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }
}

