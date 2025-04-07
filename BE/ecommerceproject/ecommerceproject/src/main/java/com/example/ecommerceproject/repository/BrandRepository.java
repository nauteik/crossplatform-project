package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Brand;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BrandRepository extends MongoRepository<Brand, String> {
    Brand findByName(String name);
} 