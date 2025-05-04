package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.ProductTypeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/producttype")
@CrossOrigin(origins = "*")
public class ProductTypeController {

    private final ProductTypeService productTypeService;

    @Autowired
    public ProductTypeController(ProductTypeService productTypeService) {
        this.productTypeService = productTypeService;
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

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteProductType(@PathVariable String id) {
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