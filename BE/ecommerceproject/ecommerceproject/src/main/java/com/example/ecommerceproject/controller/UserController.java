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

    @PostMapping("/add")
    public UserDTO addUser(@RequestBody UserDTO user) {
        return userRepo.save(user);
    }

    @GetMapping("/get")
    public List<UserDTO> getAllUser(){
        return userRepo.findAll();
    }
}

