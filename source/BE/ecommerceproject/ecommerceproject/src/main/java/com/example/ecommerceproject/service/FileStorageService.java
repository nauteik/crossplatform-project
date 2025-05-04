package com.example.ecommerceproject.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;
import java.util.logging.Logger;

@Service
public class FileStorageService {
    
    private static final Logger logger = Logger.getLogger(FileStorageService.class.getName());
    
    @Value("${upload.dir}")
    private String uploadDir;
    
    /**
     * Lưu tập tin và trả về tên tập tin đã lưu
     */
    public String saveFile(MultipartFile file) throws IOException {
        // Tạo thư mục lưu trữ nếu nó chưa tồn tại
        File uploadDirFile = new File(uploadDir);
        if (!uploadDirFile.exists()) {
            logger.info("Creating upload directory: " + uploadDirFile.getAbsolutePath());
            boolean created = uploadDirFile.mkdirs();
            if (!created) {
                logger.warning("Failed to create directory: " + uploadDirFile.getAbsolutePath());
            }
        }
        
        logger.info("Upload directory: " + uploadDirFile.getAbsolutePath());
        
        // Tạo tên file duy nhất để tránh việc ghi đè
        String originalFilename = file.getOriginalFilename();
        String fileExtension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            fileExtension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }
        String uniqueFilename = UUID.randomUUID().toString() + fileExtension;
        
        // Lưu file vào thư mục đã chỉ định
        Path targetLocation = Paths.get(uploadDir).resolve(uniqueFilename);
        logger.info("Saving file to: " + targetLocation.toAbsolutePath());
        Files.copy(file.getInputStream(), targetLocation, StandardCopyOption.REPLACE_EXISTING);
        
        logger.info("File saved successfully as: " + uniqueFilename);
        return uniqueFilename;
    }
    
    /**
     * Xóa file nếu nó tồn tại
     */
    public boolean deleteFile(String filename) {
        try {
            Path filePath = Paths.get(uploadDir).resolve(filename);
            logger.info("Deleting file: " + filePath.toAbsolutePath());
            boolean deleted = Files.deleteIfExists(filePath);
            logger.info("File deletion " + (deleted ? "successful" : "failed (file not found)"));
            return deleted;
        } catch (IOException e) {
            logger.severe("Error deleting file: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Cập nhật file bằng cách xóa file cũ và lưu file mới
     */
    public String updateFile(String oldFilename, MultipartFile newFile) throws IOException {
        // Xóa file cũ nếu nó tồn tại
        if (oldFilename != null && !oldFilename.isEmpty()) {
            deleteFile(oldFilename);
        }
        
        // Lưu file mới
        return saveFile(newFile);
    }
}