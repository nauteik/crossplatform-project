package com.example.ecommerceproject.controller;

import java.util.List;

import com.example.ecommerceproject.model.UserDTO;
import com.example.ecommerceproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class UserController {

    @Autowired
    private UserRepository userRepo;

    // Save method is predefine method in Mongo Repository
    // with this method we will save user in our database
    @PostMapping("/addUser")
    public UserDTO addUser(@RequestBody UserDTO user) {
        return userRepo.save(user);
    }

    @GetMapping("/getAllUser")
    public List<UserDTO> getAllUser(){
        return userRepo.findAll();
    }
}

