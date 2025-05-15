package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Tag;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TagRepository extends MongoRepository<Tag, String> {
    Tag findByName(String name);
} 