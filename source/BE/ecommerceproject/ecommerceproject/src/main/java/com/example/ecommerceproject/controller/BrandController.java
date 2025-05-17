package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.BrandService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/brand")
@CrossOrigin(origins = "*")
public class BrandController {

    private final BrandService brandService;

    @Autowired
    public BrandController(BrandService brandService) {
        this.brandService = brandService;
    }

    @GetMapping("/brands")
    public ResponseEntity<ApiResponse<List<Brand>>> getAllBrands() {
        List<Brand> brands = brandService.getAllBrands();
        ApiResponse<List<Brand>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                brands
        );
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Brand>> getBrandById(@PathVariable String id) {
        Brand brand = brandService.getBrandById(id);
        if (brand != null) {
            ApiResponse<Brand> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    brand
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<Brand> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @PostMapping("/create")
    public ResponseEntity<ApiResponse<Brand>> createBrand(@RequestBody Brand brandRequest) {
        Brand createdBrand = brandService.createBrand(brandRequest);
        ApiResponse<Brand> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                createdBrand
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<ApiResponse<Brand>> updateBrand(@PathVariable String id, @RequestBody Brand brandRequest) {
        Brand updatedBrand = brandService.updateBrand(id, brandRequest);
        if (updatedBrand != null) {
            ApiResponse<Brand> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    updatedBrand
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<Brand> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteBrand(@PathVariable String id) {
        boolean deleted = brandService.deleteBrand(id);
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