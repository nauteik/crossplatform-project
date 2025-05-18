package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.Tag;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.FileStorageService;
import com.example.ecommerceproject.service.ProductService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@RestController
@RequestMapping("/api/product")
public class ProductController {

    private static final Logger logger = Logger.getLogger(ProductController.class.getName());

    private final ProductService productService;
    private final FileStorageService fileStorageService;
    private final ObjectMapper objectMapper;
    
    @Value("${upload.path}")
    private String uploadPath;

    @Autowired
    public ProductController(ProductService productService, FileStorageService fileStorageService, ObjectMapper objectMapper) {
        this.productService = productService;
        this.fileStorageService = fileStorageService;
        this.objectMapper = objectMapper;
    }

    @GetMapping("/products")
    public ResponseEntity<ApiResponse<List<Product>>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        ApiResponse<List<Product>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                products
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/products/paged")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getPagedProducts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Map<String, Object> pageResult = productService.getPagedProducts(page, size);
        ApiResponse<Map<String, Object>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                pageResult
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Product>> getProductById(@PathVariable String id) {
        Product product = productService.getProductById(id);
        if (product != null) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    product
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<Product> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<Product>>> searchProducts(@RequestParam String query) {
        List<Product> products = productService.searchProducts(query);
        ApiResponse<List<Product>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                products
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-brand/{brandId}")
    public ResponseEntity<ApiResponse<List<Product>>> getProductsByBrand(@PathVariable String brandId) {
        List<Product> products = productService.getProductsByBrand(brandId);
        ApiResponse<List<Product>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                products
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-type/{productTypeId}")
    public ResponseEntity<ApiResponse<List<Product>>> getProductsByProductType(@PathVariable String productTypeId) {
        List<Product> products = productService.getProductsByProductType(productTypeId);
        ApiResponse<List<Product>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                products
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/by-tag/{tagId}")
    public ResponseEntity<ApiResponse<List<Product>>> getProductsByTag(@PathVariable String tagId) {
        List<Product> products = productService.getProductsByTag(tagId);
        ApiResponse<List<Product>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                products
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<Product>> createProduct(@RequestBody Product product) {
        Product createdProduct = productService.createProduct(product);
        ApiResponse<Product> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                createdProduct
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping(value = "/create-with-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Product>> createProductWithImage(
            @RequestParam("product") String productJson,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            logger.info("Creating product with image");
            logger.info("Product JSON: " + productJson);
            
            // Parse JSON product data
            Product product = objectMapper.readValue(productJson, Product.class);
            
            // Save image if provided
            if (image != null && !image.isEmpty()) {
                logger.info("Image provided, original filename: " + image.getOriginalFilename());
                String imageName = fileStorageService.saveFile(image);
                logger.info("Image saved with name: " + imageName);
                product.setPrimaryImageUrl(imageName);
                logger.info("Set primaryImageUrl to: " + imageName);
            } else {
                logger.info("No image provided");
            }
            
            // Create product
            Product createdProduct = productService.createProduct(product);
            logger.info("Product created with ID: " + createdProduct.getId());
            logger.info("Saved image path: " + createdProduct.getPrimaryImageUrl());
            
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    createdProduct
            );
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (IOException e) {
            logger.severe("Error creating product with image: " + e.getMessage());
            e.printStackTrace();
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "Failed to create product: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<ApiResponse<Product>> updateProduct(@PathVariable String id, @RequestBody Product product) {
        Product updatedProduct = productService.updateProduct(id, product);
        if (updatedProduct != null) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProduct
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<Product> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @PutMapping(value = "/update-with-image/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<Product>> updateProductWithImage(
            @PathVariable String id,
            @RequestParam("product") String productJson,
            @RequestParam(value = "image", required = false) MultipartFile image) {
        try {
            logger.info("Updating product with ID: " + id);
            logger.info("Product JSON: " + productJson);
            
            // Lấy sản phẩm hiện tại để biết đường dẫn hình ảnh cũ
            Product existingProduct = productService.getProductById(id);
            if (existingProduct == null) {
                logger.warning("Product not found with ID: " + id);
                ApiResponse<Product> response = new ApiResponse<>(
                        ApiStatus.NOT_FOUND.getCode(),
                        ApiStatus.NOT_FOUND.getMessage()
                );
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            logger.info("Existing product found. Current image path: " + existingProduct.getPrimaryImageUrl());
            
            // Parse JSON product data
            Product productToUpdate = objectMapper.readValue(productJson, Product.class);
            
            // Xử lý hình ảnh nếu có
            if (image != null && !image.isEmpty()) {
                logger.info("New image provided, original filename: " + image.getOriginalFilename());
                
                // Lưu hình ảnh mới và cập nhật đường dẫn
                String oldImageName = existingProduct.getPrimaryImageUrl();
                logger.info("Old image name: " + oldImageName);
                
                String newImageName = fileStorageService.updateFile(oldImageName, image);
                logger.info("New image saved with name: " + newImageName);
                
                productToUpdate.setPrimaryImageUrl(newImageName);
                logger.info("Updated primaryImageUrl to: " + newImageName);
            } else {
                logger.info("No new image provided, keeping existing image");
                // Giữ nguyên đường dẫn hình ảnh cũ nếu không có hình ảnh mới
                productToUpdate.setPrimaryImageUrl(existingProduct.getPrimaryImageUrl());
            }
            
            // Cập nhật sản phẩm
            Product updatedProduct = productService.updateProduct(id, productToUpdate);
            logger.info("Product updated successfully");
            logger.info("Final image path: " + updatedProduct.getPrimaryImageUrl());
            
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProduct
            );
            return ResponseEntity.ok(response);
        } catch (IOException e) {
            logger.severe("Error updating product: " + e.getMessage());
            e.printStackTrace();
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "Failed to update product: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable String id) {
        // Lấy sản phẩm để biết đường dẫn hình ảnh
        Product existingProduct = productService.getProductById(id);
        if (existingProduct == null) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        // Xóa hình ảnh liên quan nếu có
        String primaryImageUrl = existingProduct.getPrimaryImageUrl();
        if (primaryImageUrl != null && !primaryImageUrl.isEmpty()) {
            logger.info("Deleting primary image: " + primaryImageUrl);
            fileStorageService.deleteFile(primaryImageUrl);
        }
        
        // Xóa các hình ảnh khác nếu có
        List<String> imageUrls = existingProduct.getImageUrls();
        if (imageUrls != null && !imageUrls.isEmpty()) {
            for (String imageUrl : imageUrls) {
                logger.info("Deleting additional image: " + imageUrl);
                fileStorageService.deleteFile(imageUrl);
            }
        }
        
        // Xóa sản phẩm
        boolean deleted = productService.deleteProduct(id);
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

    @PostMapping("/discount/{id}")
    public ResponseEntity<ApiResponse<Product>> applyDiscountToProduct(
            @PathVariable String id,
            @RequestBody Map<String, Double> discountRequest) {
        Double discountPercent = discountRequest.get("discountPercent");
        if (discountPercent == null) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    "Discount percent is required"
            );
            return ResponseEntity.badRequest().body(response);
        }

        Product product = productService.applyDiscountToProduct(id, discountPercent);
        if (product != null) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    product
            );
            return ResponseEntity.ok(response);
        }

        ApiResponse<Product> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @PostMapping("/discount-brand/{brandId}")
    public ResponseEntity<ApiResponse<Void>> applyDiscountToBrand(
            @PathVariable String brandId,
            @RequestBody Map<String, Double> discountRequest) {
        Double discountPercent = discountRequest.get("discountPercent");
        if (discountPercent == null) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    "Discount percent is required"
            );
            return ResponseEntity.badRequest().body(response);
        }

        productService.applyDiscountToBrand(brandId, discountPercent);
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage()
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/discount-type/{productTypeId}")
    public ResponseEntity<ApiResponse<Void>> applyDiscountToProductType(
            @PathVariable String productTypeId,
            @RequestBody Map<String, Double> discountRequest) {
        Double discountPercent = discountRequest.get("discountPercent");
        if (discountPercent == null) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(), 
                    "Discount percent is required"
            );
            return ResponseEntity.badRequest().body(response);
        }

        productService.applyDiscountToProductType(productTypeId, discountPercent);
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage()
        );
        return ResponseEntity.ok(response);
    }

    // Tag management for products
    @GetMapping("/{productId}/tags")
    public ResponseEntity<ApiResponse<List<Tag>>> getProductTags(@PathVariable String productId) {
        Product product = productService.getProductById(productId);
        if (product == null) {
            ApiResponse<List<Tag>> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    ApiStatus.NOT_FOUND.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        
        List<Tag> tags = product.getTags();
        ApiResponse<List<Tag>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                tags
        );
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{productId}/tags")
    public ResponseEntity<ApiResponse<Product>> addTagToProduct(
            @PathVariable String productId,
            @RequestBody Map<String, String> request) {
        String tagId = request.get("tagId");
        if (tagId == null) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "Tag ID is required"
            );
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            Product updatedProduct = productService.addTagToProduct(productId, tagId);
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProduct
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }

    @DeleteMapping("/{productId}/tags/{tagId}")
    public ResponseEntity<ApiResponse<Product>> removeTagFromProduct(
            @PathVariable String productId,
            @PathVariable String tagId) {
        try {
            Product updatedProduct = productService.removeTagFromProduct(productId, tagId);
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedProduct
            );
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            ApiResponse<Product> response = new ApiResponse<>(
                    ApiStatus.NOT_FOUND.getCode(),
                    e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }
}