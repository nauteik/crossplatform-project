package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Review;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class ContentModerationDecorator extends ReviewDecorator {

    private static final List<String> BANNED_WORDS = Arrays.asList(
        "badword1", "badword2", "badword3", "badword4", "badword5"
    );

    public ContentModerationDecorator(ReviewService decoratedReviewService) {
        super(decoratedReviewService);
    }

    @Override
    public Review addReview(String productId, String userId, int rating, String comment, MultipartFile[] files) throws IOException {
        // Kiểm duyệt nội dung bình luận
        String moderatedComment = moderateContent(comment);
        return decoratedReviewService.addReview(productId, userId, rating, moderatedComment, files);
    }

    private String moderateContent(String comment) {
        if (comment == null) {
            return "";
        }
        
        String moderatedComment = comment;
        for (String bannedWord : BANNED_WORDS) {
            // Thay thế từ ngữ không phù hợp bằng dấu sao
            moderatedComment = moderatedComment.replaceAll("(?i)" + bannedWord, "***");
        }
        
        return moderatedComment;
    }
}