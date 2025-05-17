package com.example.ecommerceproject.repository;

import com.example.ecommerceproject.model.Address;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface AddressRepository extends MongoRepository<Address, String> {
    List<Address> findByUserId(String userId);
    Optional<Address> findByUserIdAndIsDefaultTrue(String userId);
    void deleteByUserId(String userId);
    List<Address> findByUserIdOrderByIsDefaultDesc(String userId);
} 