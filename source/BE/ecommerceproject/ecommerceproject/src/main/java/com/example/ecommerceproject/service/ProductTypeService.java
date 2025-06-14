package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.repository.ProductTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ProductTypeService {

    private final ProductTypeRepository productTypeRepository;

    @Autowired
    public ProductTypeService(ProductTypeRepository productTypeRepository) {
        this.productTypeRepository = productTypeRepository;
    }

    public List<ProductType> getAllProductTypes() {
        return productTypeRepository.findAll();
    }

    public ProductType getProductTypeById(String id) {
        Optional<ProductType> productType = productTypeRepository.findById(id);
        return productType.orElse(null);
    }

    public ProductType createProductType(ProductType productType) {
        return productTypeRepository.save(productType);
    }

    public ProductType updateProductType(String id, ProductType productType) {
        if (!productTypeRepository.existsById(id)) {
            return null;
        }

        productType.setId(id);
        return productTypeRepository.save(productType);
    }

    public boolean deleteProductType(String id) {
        if (!productTypeRepository.existsById(id)) {
            return false;
        }
        productTypeRepository.deleteById(id);
        return true;
    }

    public int getProductTypeCount() {
        return (int) productTypeRepository.count();
    }

    // Lấy danh sách tên của tất cả các loại sản phẩm
    public List<String> getAllProductTypeNames() {
        List<ProductType> productTypes = productTypeRepository.findAll();
        return productTypes.stream()
                .map(ProductType::getName)
                .collect(Collectors.toList());
    }
} 