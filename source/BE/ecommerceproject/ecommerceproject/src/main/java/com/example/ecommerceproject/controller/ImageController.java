package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Instant;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/images")
@CrossOrigin(origins = "*")
public class ImageController {

    private static final Logger logger = Logger.getLogger(ImageController.class.getName());

    @Value("${upload.dir}")
    private String uploadDir;

    @GetMapping("/{imageName:.+}")
    public ResponseEntity<Resource> getImage(@PathVariable String imageName) {
        try {
            logger.info("Requested image: " + imageName);
            
            // Đường dẫn đầy đủ đến thư mục upload
            Path uploadedFile = Paths.get(uploadDir).resolve(imageName);
            logger.info("Looking for image at: " + uploadedFile.toAbsolutePath());
            
            // Check if the upload directory exists
            File uploadDirFile = new File(uploadDir);
            if (!uploadDirFile.exists()) {
                logger.warning("Upload directory does not exist: " + uploadDirFile.getAbsolutePath());
                // Try to create it
                boolean created = uploadDirFile.mkdirs();
                logger.info("Created upload directory: " + created);
            }
            
            Resource resource = null;
            
            if (Files.exists(uploadedFile)) {
                logger.info("Found image in uploads directory");
                // Nếu tìm thấy trong uploads, sử dụng FileSystemResource
                resource = new FileSystemResource(uploadedFile);
            } else {
                logger.info("Image not found in uploads, checking classpath at: " + imageName);
                // Nếu không tìm thấy, thử tìm trong classpath (static/images)
                resource = new ClassPathResource("static/images/" + imageName);
                if (!resource.exists() || !resource.isReadable()) {
                    logger.warning("Image not found in uploads or classpath: " + imageName);
                    return ResponseEntity.notFound().build();
                }
                logger.info("Found image in classpath");
            }
            
            // Xác định loại nội dung (content type) dựa trên phần mở rộng tệp
            String contentType = determineContentType(imageName);
            
            // Thêm các HTTP headers để ngăn cache
            HttpHeaders headers = new HttpHeaders();
            headers.add(HttpHeaders.CONTENT_DISPOSITION, "inline; filename=\"" + resource.getFilename() + "\"");
            headers.add(HttpHeaders.CACHE_CONTROL, "no-cache, no-store, must-revalidate");
            headers.add(HttpHeaders.PRAGMA, "no-cache");
            headers.add(HttpHeaders.EXPIRES, "0");
            
            // Thêm timestamp cho ETag để đảm bảo cập nhật khi thay đổi
            headers.setETag(String.valueOf(Instant.now().toEpochMilli()));
            
            return ResponseEntity.ok()
                .headers(headers)
                .contentType(MediaType.parseMediaType(contentType))
                .body(resource);
        } catch (Exception e) {
            logger.severe("Error serving image: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }

    private String determineContentType(String filename) {
        String extension = filename.substring(filename.lastIndexOf(".") + 1).toLowerCase();
        switch (extension) {
            case "png":
                return "image/png";
            case "jpg":
            case "jpeg":
                return "image/jpeg";
            case "gif":
                return "image/gif";
            case "svg":
                return "image/svg+xml";
            case "webp":
                return "image/webp";
            default:
                return "application/octet-stream";
        }
    }
}