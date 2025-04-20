package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Media;
import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.model.ReviewSummary;
import com.example.ecommerceproject.repository.ReviewRepository;
import com.example.ecommerceproject.response.ApiResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;

@RestController
@RequestMapping("/api/reviews")
@CrossOrigin("*")
public class ReviewController {

    @Value("${upload.path}")
    private String uploadDir;

    @Autowired
    private ReviewRepository reviewRepository;

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
            
            Review review = new Review();
            review.setProductId(productId);
            review.setUserId(userId);
            review.setRating(rating);
            review.setComment(comment);

            if (files != null) {
                for (MultipartFile file : files) {
                    if (file != null && !file.isEmpty()) {
                        String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
                        Path uploadPath = Paths.get(uploadDir);
                        
                        // Đảm bảo thư mục tồn tại
                        if (!Files.exists(uploadPath)) {
                            Files.createDirectories(uploadPath);
                        }
                        
                        Path path = Paths.get(uploadDir + "/" + fileName);
                        Files.copy(file.getInputStream(), path, StandardCopyOption.REPLACE_EXISTING);

                        String fileType = file.getContentType() != null && file.getContentType().startsWith("video") ? "video" : "image";
                        review.getMedia().add(new Media(fileType, "/media/" + fileName));
                    }
                }
            }

            Review savedReview = reviewRepository.save(review);
            return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), ApiStatus.SUCCESS.getMessage(), savedReview));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(
                new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
            );
        }
    }

    @GetMapping("/{productId}")
    public ResponseEntity<ApiResponse<List<Review>>> getByProduct(@PathVariable String productId) {
        try {
            List<Review> reviews = reviewRepository.findByProductId(productId);
            if (reviews.isEmpty()) {
                return ResponseEntity.ok(new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "No reviews found for this product", reviews));
            }
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
                
                return ResponseEntity.ok(new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(), 
                    ApiStatus.SUCCESS.getMessage(), 
                    summary));
            } else {
                // No reviews yet
                summary.setTotalReviews(0);
                summary.setAverageRating(0);
                
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
        // Tìm đánh giá theo ID
        Review review = reviewRepository.findById(reviewId).orElse(null);
        
        if (review == null) {
            return ResponseEntity.status(404).body(
                new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "Không tìm thấy đánh giá", null)
            );
        }
        
        // Kiểm tra nếu userId không khớp (bảo mật)
        if (!review.getUserId().equals(userId)) {
            return ResponseEntity.status(403).body(
                new ApiResponse<>(ApiStatus.NOT_AUTHOR.getCode(), "Bạn không có quyền xóa đánh giá này", null)
            );
        }
        
        // Xóa đánh giá
        reviewRepository.deleteById(reviewId);
        
        return ResponseEntity.ok(
            new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Đã xóa đánh giá thành công", reviewId)
        );
    } catch (Exception e) {
        return ResponseEntity.status(500).body(
            new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(), e.getMessage(), null)
        );
    }
}
}

