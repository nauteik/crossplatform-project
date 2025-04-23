package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.CartService;
import com.example.ecommerceproject.service.FacadeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    @Autowired
    private FacadeService facadeService;

    @PostMapping("/{userId}/items")
    public ResponseEntity<?> addItemToCart(
            @PathVariable String userId,
            @RequestBody CartItem cartItem) {
        ApiResponse<?> response = facadeService.addItemToCart(userId, cartItem);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @DeleteMapping("/{userId}/items/{productId}")
    public ResponseEntity<?> removeItemFromCart(
            @PathVariable String userId,
            @PathVariable String productId) {
        ApiResponse<?> response = facadeService.removeItemFromCart(userId, productId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @GetMapping("/{userId}")
    public ResponseEntity<?> getCartByUserId(@PathVariable String userId) {
        ApiResponse<?> response = facadeService.getCartByUserId(userId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<?> clearCartItemsList(@PathVariable String userId) {
        ApiResponse<?> response = facadeService.clearCartItemsList(userId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}