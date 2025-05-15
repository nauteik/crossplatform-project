package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Order;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.time.LocalDateTime;

@Repository
public interface OrderRepository extends MongoRepository<Order, String> {
    List<Order> findByUserId(String userId);
    List<Order> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}