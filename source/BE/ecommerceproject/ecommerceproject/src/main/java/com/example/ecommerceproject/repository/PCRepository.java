package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.pc.PC;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PCRepository extends MongoRepository<PC, String> {
    List<PC> findByUserId(String userId);
}