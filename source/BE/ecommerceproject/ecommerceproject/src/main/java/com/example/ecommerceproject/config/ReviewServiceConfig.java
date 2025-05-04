package com.example.ecommerceproject.config;

import com.example.ecommerceproject.repository.ReviewRepository;
import com.example.ecommerceproject.service.BaseReviewService;
import com.example.ecommerceproject.service.ContentModerationDecorator;
import com.example.ecommerceproject.service.MediaStorageDecorator;
import com.example.ecommerceproject.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import java.io.File;

@Configuration
public class ReviewServiceConfig {

    @Value("${upload.path}")
    private String uploadDir;

    @Autowired
    private BaseReviewService baseReviewService;
    
    @Autowired
    private ReviewRepository reviewRepository;

    @Bean
    public ReviewService reviewService() {
        // Đảm bảo đường dẫn upload là đường dẫn tuyệt đối
        String absoluteUploadPath = new File(uploadDir).getAbsolutePath();
        
        System.out.println("Thư mục lưu trữ tệp: " + absoluteUploadPath);
        
        // Tạo thư mục nếu chưa tồn tại
        File directory = new File(absoluteUploadPath);
        if (!directory.exists()) {
            boolean created = directory.mkdirs();
            System.out.println("Tạo thư mục lưu trữ: " + (created ? "Thành công" : "Thất bại"));
        }
        
        // Áp dụng các decorator theo thứ tự
        // 1. Đầu tiên, kiểm duyệt nội dung
        ReviewService moderatedService = new ContentModerationDecorator(baseReviewService);
        // 2. Sau đó, xử lý và lưu trữ đa phương tiện
        return new MediaStorageDecorator(moderatedService, absoluteUploadPath, reviewRepository);
    }
}