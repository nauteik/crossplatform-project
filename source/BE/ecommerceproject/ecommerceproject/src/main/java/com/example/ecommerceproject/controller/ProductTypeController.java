package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.ProductTypeService;
import com.example.ecommerceproject.service.FileStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/producttype")
public class ProductTypeController {

    private static final Logger logger = Logger.getLogger(ProductTypeController.class.getName());
    
    private final ProductTypeService productTypeService;
    private final FileStorageService fileStorageService;

    @Autowired
    public ProductTypeController(ProductTypeService productTypeService, FileStorageService fileStorageService) {
        this.productTypeService = productTypeService;
        this.fileStorageService = fileStorageService;
    }

    @GetMapping("/types")
    public ResponseEntity<ApiResponse<List<ProductType>>> getAllProductTypes() {
        List<ProductType> productTypes = productTypeService.getAllProductTypes();
        ApiResponse<List<ProductType>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                productTypes
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductType>> getProductTypeById(@PathVariable String id) {
        ProductType productType = productTypeService.getProductTypeById(id);
        if (productType != null) {
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    productType
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<ProductType> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<ProductType>> createProductType(@RequestBody ProductType productType) {
        ProductType createdProductType = productTypeService.createProductType(productType);
        ApiResponse<ProductType> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                createdProductType
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping(value = "/create-with-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductType>> createProductTypeWithImage(
            @RequestParam("name") String name,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            logger.info("Creating product type with image");
            logger.info("Product type name: " + name);
            
            ProductType productType = new ProductType();
            productType.setName(name);
            
            // Save image if provided
            if (image != null && !image.isEmpty()) {
                logger.info("Image provided, original filename: " + image.getOriginalFilename());
                String imageName = fileStorageService.saveFile(image);
                logger.info("Image saved with name: " + imageName);
                productType.setImage(imageName);
            } else {
                // Default image based on name
                productType.setImage(name.toLowerCase() + ".png");
                logger.info("No image provided, using default: " + productType.getImage());
            }
            
            // Create product type
            ProductType createdProductType = productTypeService.createProductType(productType);
            logger.info("Product type created with ID: " + createdProductType.getId());
            
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    createdProductType
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (Exception e) {
            logger.severe("Error creating product type with image: " + e.getMessage());
            e.printStackTrace();
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "Failed to create product type: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<ApiResponse<ProductType>> updateProductType(@PathVariable String id, @RequestBody ProductType productType) {
        ProductType updatedProductType = productTypeService.updateProductType(id, productType);
        if (updatedProductType != null) {
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProductType
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<ProductType> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @PutMapping(value = "/update-with-image/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<ProductType>> updateProductTypeWithImage(
            @PathVariable String id,
            @RequestParam("name") String name,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            logger.info("Updating product type with ID: " + id);
            
            // Lấy product type hiện tại
            ProductType existingProductType = productTypeService.getProductTypeById(id);
            if (existingProductType == null) {
                logger.warning("Product type not found with ID: " + id);
                ApiResponse<ProductType> response = new ApiResponse<>(
                        ApiStatus.NOT_FOUND.getCode(),
                        ApiStatus.NOT_FOUND.getMessage()
                );
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            logger.info("Existing product type found. Current image: " + existingProductType.getImage());
            
            // Cập nhật thông tin
            existingProductType.setName(name);
            
            // Xử lý hình ảnh nếu có
            if (image != null && !image.isEmpty()) {
                logger.info("New image provided, original filename: " + image.getOriginalFilename());
                
                // Lưu hình ảnh mới và cập nhật đường dẫn
                String oldImageName = existingProductType.getImage();
                logger.info("Old image name: " + oldImageName);
                
                String newImageName = fileStorageService.updateFile(oldImageName, image);
                logger.info("New image saved with name: " + newImageName);
                
                existingProductType.setImage(newImageName);
            }
            
            // Cập nhật product type
            ProductType updatedProductType = productTypeService.updateProductType(id, existingProductType);
            logger.info("Product type updated successfully");
            
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProductType
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.severe("Error updating product type: " + e.getMessage());
            e.printStackTrace();
            ApiResponse<ProductType> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "Failed to update product type: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteProductType(@PathVariable String id) {
        // Lấy product type để biết đường dẫn hình ảnh
        ProductType existingProductType = productTypeService.getProductTypeById(id);
        if (existingProductType == null) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        // Xóa hình ảnh liên quan nếu có
        String image = existingProductType.getImage();
        if (image != null && !image.isEmpty()) {
            logger.info("Deleting image: " + image);
            fileStorageService.deleteFile(image);
        }
        
        boolean deleted = productTypeService.deleteProductType(id);
        if (deleted) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage()
            );
            return ResponseEntity.ok(response);
        }
        
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
} 