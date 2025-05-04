package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/product")
@CrossOrigin(origins = "*")
public class ProductController {

    private final ProductService productService;

    @Autowired
    public ProductController(ProductService productService) {
        this.productService = productService;
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

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteProduct(@PathVariable String id) {
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
}