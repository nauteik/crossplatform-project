package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.ProductType;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProductTypeRepository extends MongoRepository<ProductType, String> {
    ProductType findByName(String name);
} 