package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Message;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.List;

public interface MessageRepository extends MongoRepository<Message, String> {
    List<Message> findByUserIdOrderByCreatedAtDesc(String userId);
    List<Message> findByAdminIdOrderByCreatedAtDesc(String adminId);
    List<Message> findByUserIdAndAdminIdOrderByCreatedAtDesc(String userId, String adminId);
    List<Message> findByIsReadFalseAndIsFromUserTrue();
} 