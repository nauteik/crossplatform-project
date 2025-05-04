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

import java.util.List;
import java.util.Map;

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
        System.out.println("Cart for user ID " + userId + ":" + cart);
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
    public ResponseEntity<?> removeItemFromCart(
            @PathVariable String userId,
            @PathVariable String productId) {
        ApiResponse<?> response = facadeService.removeFromCart(userId, productId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
    
    /**
     * Remove multiple items from cart after payment
     * This endpoint is used by the frontend to remove specific items after successful payment
     */
    @DeleteMapping("/{userId}/items")
    public ResponseEntity<?> removeMultipleItemsFromCart(
            @PathVariable String userId,
            @RequestBody Map<String, List<String>> request) {
        
        List<String> productIds = request.get("productIds");
        if (productIds == null || productIds.isEmpty()) {
            return ResponseEntity.badRequest().build();
        }
        
        cartService.removeItemsFromCart(userId, productIds);
        Cart updatedCart = cartService.getCartByUserId(userId);
        return ResponseEntity.ok(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Items removed successfully", updatedCart));
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<?> clearCart(@PathVariable String userId) {
        ApiResponse<?> response = facadeService.clearCart(userId);
        if (response.getStatus() == ApiStatus.SUCCESS.getCode()) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }
}