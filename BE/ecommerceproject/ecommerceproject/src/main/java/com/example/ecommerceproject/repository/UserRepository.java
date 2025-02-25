package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.UserDTO;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface UserRepository extends MongoRepository<UserDTO, String> {

}
