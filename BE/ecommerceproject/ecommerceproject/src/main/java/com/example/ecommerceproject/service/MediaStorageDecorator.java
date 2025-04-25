package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Media;
import com.example.ecommerceproject.model.Review;
import com.example.ecommerceproject.repository.ReviewRepository;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class MediaStorageDecorator extends ReviewDecorator {

    private final String uploadDir;
    private final ReviewRepository reviewRepository;

    public MediaStorageDecorator(ReviewService decoratedReviewService, String uploadDir, ReviewRepository reviewRepository) {
        super(decoratedReviewService);
        this.uploadDir = uploadDir;
        this.reviewRepository = reviewRepository;
        
        // In thông tin thư mục upload để debug
        System.out.println("MediaStorageDecorator initialized with upload directory: " + uploadDir);
        
        // Đảm bảo thư mục tồn tại
        File directory = new File(uploadDir);
        if (!directory.exists()) {
            boolean created = directory.mkdirs();
            System.out.println("Created upload directory: " + created);
        }
    }

    @Override
    public Review addReview(String productId, String userId, int rating, String comment, MultipartFile[] files) throws IOException {
        System.out.println("MediaStorageDecorator.addReview called");
        
        // Khởi tạo danh sách media trước khi gọi service
        List<Media> mediaList = new ArrayList<>();
        
        // Xử lý media trước
        if (files != null && files.length > 0) {
            System.out.println("Processing " + files.length + " files");
            
            for (MultipartFile file : files) {
                if (file != null && !file.isEmpty()) {
                    Media media = processMedia(file);
                    if (media != null) {
                        mediaList.add(media);
                    }
                }
            }
            
            System.out.println("Processed " + mediaList.size() + " media files");
        } else {
            System.out.println("No files to process");
        }
        
        // Gọi service tiếp theo trong chuỗi để lấy review
        Review review = super.addReview(productId, userId, rating, comment, files);
        
        // Thêm media vào review và lưu lại
        if (!mediaList.isEmpty()) {
            System.out.println("Adding " + mediaList.size() + " media items to review");
            review.getMedia().addAll(mediaList);
            review = reviewRepository.save(review);
        }
        
        return review;
    }

    private Media processMedia(MultipartFile file) throws IOException {
        if (file == null || file.isEmpty()) {
            return null;
        }
        
        try {
            // Tạo tên file duy nhất
            String originalFilename = file.getOriginalFilename();
            String fileName = UUID.randomUUID() + "_" + (originalFilename != null ? originalFilename : "file");
            
            // Đường dẫn đầy đủ
            Path filePath = Paths.get(uploadDir, fileName);
            
            System.out.println("Saving file to: " + filePath.toAbsolutePath());
            
            // Sao chép file
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);
            
            // Xác định loại file
            String contentType = file.getContentType();
            String fileType = (contentType != null && contentType.startsWith("video")) ? "video" : "image";
            
            // URL để truy cập
            String mediaUrl = "/media/" + fileName;
            
            System.out.println("File saved successfully: " + mediaUrl + " (Type: " + fileType + ")");
            
            // Trả về đối tượng Media
            return new Media(fileType, mediaUrl);
        } catch (IOException e) {
            System.err.println("Error saving file: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
}