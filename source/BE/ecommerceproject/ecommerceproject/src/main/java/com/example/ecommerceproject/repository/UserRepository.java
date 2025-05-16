package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.User;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends MongoRepository<User, String> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    List<User> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);
}
