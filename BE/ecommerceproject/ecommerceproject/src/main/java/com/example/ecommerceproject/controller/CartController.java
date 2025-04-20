package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItemRequest;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.CartService;
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

    @GetMapping("/{userId}")
    public ResponseEntity<?> getCart(@PathVariable String userId) {
        Cart cart = cartService.getCartByUserId(userId);
        System.out.println("Cart for user ID " + userId + ":" + cart);
        return ResponseEntity.status(HttpStatus.OK).body(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Cart Items List", cart));
    }

    @PostMapping("/{userId}/items")
    public ResponseEntity<ApiResponse<?>> addItemToCart(
            @PathVariable String userId,
            @RequestBody Cart.CartItem cartItem) {

        System.out.println("Adding item to cart with the following details:");
        System.out.println("User ID: " + userId);
        System.out.println("Product ID: " + cartItem.getProductId());
        System.out.println("Quantity: " + cartItem.getQuantity());

        Cart updatedCart = cartService.addItemToCart(
                userId, cartItem);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Item added to cart successfully!", updatedCart));
    }


    @DeleteMapping("/{userId}/items/{productId}")
    public ResponseEntity<Cart> removeItemFromCart(
            @PathVariable String userId,
            @PathVariable String productId) {
        Cart updatedCart = cartService.removeItemFromCart(userId, productId);
        return ResponseEntity.ok(updatedCart);
    }

    @DeleteMapping("/{userId}")
    public ResponseEntity<Void> clearCart(@PathVariable String userId) {
        cartService.clearCart(userId);
        return ResponseEntity.noContent().build();
    }
}