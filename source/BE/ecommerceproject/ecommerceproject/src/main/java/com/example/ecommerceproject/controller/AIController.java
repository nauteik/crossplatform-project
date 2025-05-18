package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/ai")
@CrossOrigin(origins = "*")
public class AIController {

    private static final Logger logger = Logger.getLogger(AIController.class.getName());
    private final ProductService productService;

    @Autowired
    public AIController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping("/product-context")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getProductContext() {
        try {
            logger.info("Getting product context for AI");
            
            // Lấy tất cả sản phẩm
            List<Product> allProducts = productService.getAllProducts();
            
            // Sắp xếp sản phẩm theo lượt bán và chỉ lấy 20 sản phẩm bán chạy nhất
            List<Product> topProducts = allProducts.stream()
                    .sorted(Comparator.comparing(Product::getSoldCount).reversed())
                    .limit(20)
                    .collect(Collectors.toList());
            
            logger.info("Found " + topProducts.size() + " top products for AI context");
            
            // Chuyển đổi sang định dạng đơn giản hơn cho AI
            List<Map<String, Object>> simplifiedProducts = topProducts.stream()
                    .map(product -> {
                        Map<String, Object> simplified = new HashMap<>();
                        simplified.put("id", product.getId());
                        simplified.put("name", product.getName());
                        simplified.put("price", product.getPrice());
                        
                        // Tính giá sau khi giảm giá
                        double discountPrice = 0;
                        if (product.getDiscountPercent() > 0) {
                            discountPrice = product.getPrice() * (1 - product.getDiscountPercent() / 100);
                        }
                        simplified.put("discountPrice", discountPrice);
                        
                        // Lấy thông tin loại sản phẩm
                        String category = "";
                        if (product.getProductType() != null && product.getProductType().getName() != null) {
                            category = (String) product.getProductType().getName();
                        }
                        simplified.put("category", category);
                        
                        // Lấy thông tin thương hiệu
                        String brand = "";
                        if (product.getBrand() != null && product.getBrand().getName() != null) {
                            brand = (String) product.getBrand().getName();
                        }
                        simplified.put("brand", brand);
                        
                        // Rút gọn mô tả
                        String shortDescription = product.getDescription();
                        if (shortDescription != null && shortDescription.length() > 100) {
                            shortDescription = shortDescription.substring(0, 100) + "...";
                        }
                        simplified.put("shortDescription", shortDescription);
                        
                        // Kiểm tra hàng tồn
                        simplified.put("inStock", product.getQuantity() > 0);
                        
                        // Số lượng đã bán
                        simplified.put("soldCount", product.getSoldCount());
                        
                        return simplified;
                    })
                    .collect(Collectors.toList());
            
            ApiResponse<List<Map<String, Object>>> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    simplifiedProducts
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.severe("Error getting product context for AI: " + e.getMessage());
            e.printStackTrace();
            
            ApiResponse<List<Map<String, Object>>> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error getting product context: " + e.getMessage()
            );
            
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/search-products")
    public ResponseEntity<ApiResponse<List<Product>>> searchProductsForAI(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "5") int limit) {
        
        try {
            logger.info("AI searching products with keyword: " + keyword);
            
            // Tìm kiếm sản phẩm theo từ khóa
            List<Product> searchResults = productService.searchProducts(keyword);
            
            // Giới hạn số lượng kết quả
            List<Product> limitedResults = searchResults.stream()
                    .limit(limit)
                    .collect(Collectors.toList());
            
            logger.info("Found " + limitedResults.size() + " products for AI search");
            
            ApiResponse<List<Product>> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    limitedResults
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.severe("Error searching products for AI: " + e.getMessage());
            e.printStackTrace();
            
            ApiResponse<List<Product>> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error searching products: " + e.getMessage()
            );
            
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/product-recommendations")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getProductRecommendations(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String brand,
            @RequestParam(defaultValue = "5") int limit) {
        
        try {
            logger.info("Getting product recommendations for AI");
            
            List<Product> allProducts = productService.getAllProducts();
            List<Product> filteredProducts = new ArrayList<>(allProducts);
            
            // Lọc theo danh mục nếu được chỉ định
            if (category != null && !category.isEmpty()) {
                filteredProducts = filteredProducts.stream()
                        .filter(product -> 
                            product.getProductType() != null && 
                            product.getProductType().getName() != null &&
                            ((String) product.getProductType().getName()).toLowerCase().contains(category.toLowerCase()))
                        .collect(Collectors.toList());
            }
            
            // Lọc theo thương hiệu nếu được chỉ định
            if (brand != null && !brand.isEmpty()) {
                filteredProducts = filteredProducts.stream()
                        .filter(product -> 
                            product.getBrand() != null && 
                            product.getBrand().getName() != null &&
                            ((String) product.getBrand().getName()).toLowerCase().contains(brand.toLowerCase()))
                        .collect(Collectors.toList());
            }
            
            // Sắp xếp theo lượt bán
            filteredProducts = filteredProducts.stream()
                    .sorted(Comparator.comparing(Product::getSoldCount).reversed())
                    .limit(limit)
                    .collect(Collectors.toList());
            
            // Tạo phản hồi gộp
            Map<String, Object> result = new HashMap<>();
            result.put("recommendations", filteredProducts);
            
            // Thêm một vài thống kê đơn giản
            double avgPrice = filteredProducts.stream()
                    .mapToDouble(Product::getPrice)
                    .average()
                    .orElse(0.0);
            
            result.put("averagePrice", avgPrice);
            result.put("totalProducts", filteredProducts.size());
            
            if (category != null && !category.isEmpty()) {
                result.put("category", category);
            }
            
            if (brand != null && !brand.isEmpty()) {
                result.put("brand", brand);
            }
            
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    result
            );
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            logger.severe("Error getting product recommendations: " + e.getMessage());
            e.printStackTrace();
            
            ApiResponse<Map<String, Object>> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error getting recommendations: " + e.getMessage()
            );
            
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<ApiResponse<String>> healthCheck() {
        ApiResponse<String> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(), 
                "AI Service is up and running"
        );
        return ResponseEntity.ok(response);
    }
}