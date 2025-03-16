package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.UserDTO;
import org.springframework.data.mongodb.repository.MongoRepository;
import java.util.Optional;

public interface UserRepository extends MongoRepository<UserDTO, String> {
    Optional<UserDTO> findByUsername(String username);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
}
