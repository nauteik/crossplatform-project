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
    private CartService cartService;

    @Autowired
    private FacadeService facadeService;

    @GetMapping("/{userId}")
    public ResponseEntity<?> getCart(@PathVariable String userId) {
        Cart cart = cartService.getCartByUserId(userId);
        return ResponseEntity.status(HttpStatus.OK).body(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Cart Items List", cart));
    }

    @PostMapping("/{userId}/items")
    public ResponseEntity<?> addItemToCart(
            @PathVariable String userId,
            @RequestBody CartItem cartItem) {
        ApiResponse<?> response = facadeService.addToCart(userId, cartItem);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }


    @DeleteMapping("/{userId}/items/{productId}")
    public ResponseEntity<?> removeFromCart(
            @PathVariable String userId,
            @PathVariable String productId) {
        ApiResponse<?> response = facadeService.removeFromCart(userId, productId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
//        Cart updatedCart = cartService.removeItemFromCart(userId, productId);
//        return ResponseEntity.ok(updatedCart);
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> clearCart(@PathVariable String userId) {
        cartService.clearCart(userId);
        return ResponseEntity.noContent().build();
    }
}