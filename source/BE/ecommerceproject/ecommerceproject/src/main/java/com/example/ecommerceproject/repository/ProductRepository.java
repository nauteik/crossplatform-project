package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.ProductType;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProductRepository extends MongoRepository<Product, String> {
    List<Product> findByBrand(Brand brand);
    List<Product> findByProductType(ProductType productType);
    List<Product> findByNameContainingIgnoreCase(String name);
    List<Product> findByBrandAndProductType(Brand brand, ProductType productType);
    List<Product> findByProductType_Name(String productTypeName);
}