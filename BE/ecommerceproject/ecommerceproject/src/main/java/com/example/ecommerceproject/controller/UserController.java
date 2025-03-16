package com.example.ecommerceproject.controller;

import java.util.List;

import com.example.ecommerceproject.model.UserDTO;
import com.example.ecommerceproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(path = "/user")
public class UserController {

    @Autowired
    private UserRepository userRepo;

    // Save method is predefine method in Mongo Repository
    // with this method we will save user in our database
    @PostMapping("/add")
    public UserDTO addUser(@RequestBody UserDTO user) {
        return userRepo.save(user);
    }

    @GetMapping("/get")
    public List<UserDTO> getAllUser(){
        return userRepo.findAll();
    }
}

