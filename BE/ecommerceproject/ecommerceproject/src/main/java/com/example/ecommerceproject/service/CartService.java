package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.repository.CartRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CartService {

    @Autowired
    private CartRepository cartRepository;

    public Cart getCartByUserId(String userId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (cartOptional.isPresent()) {
            return cartOptional.get();
        } else {
            // Create a new cart if none exists
            Cart newCart = new Cart();
            newCart.setUserId(userId);
            newCart = cartRepository.save(newCart);
            return newCart;
        }
    }

    public Cart addItemToCart(String userId, CartItem cartItem) {
        // Get or create cart
        Cart cart = getOrCreateCart(userId);

        // Check if product already exists in cart
        boolean productExists = false;

        for (CartItem item : cart.getItems()) {
            if (item.getProductId().equals(cartItem.getProductId())) {
                // Update existing item quantity
                item.setQuantity(item.getQuantity() + cartItem.getQuantity());
                productExists = true;
                break;
            }
        }

        // Add new item if it doesn't exist
        if (!productExists) {
            // We need to modify the Cart.CartItem class to include imageUrl
            // For now, we'll use the existing constructor but this needs to be updated
            cart.getItems().add(cartItem);

            // Note: Update Cart.CartItem class to include imageUrl and use:
            // cart.getItems().add(new Cart.CartItem(productId, productName, quantity, price, imageUrl));
        }

        // Recalculate total price
        updateCartTotalPrice(cart);

        // Save and return updated cart
        return cartRepository.save(cart);
    }

    public Cart removeItemFromCart(String userId, String productId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (!cartOptional.isPresent()) {
            // Return empty cart if user has no cart
            return new Cart();
        }

        Cart cart = cartOptional.get();

        // Remove item with the given productId
        cart.setItems(cart.getItems().stream()
                .filter(item -> !item.getProductId().equals(productId))
                .collect(Collectors.toList()));

        // Recalculate total price
        updateCartTotalPrice(cart);

        // Save and return updated cart
        return cartRepository.save(cart);
    }

    public void clearCart(String userId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (cartOptional.isPresent()) {
            Cart cart = cartOptional.get();
            cart.getItems().clear();
            cart.setTotalPrice(0);
            cartRepository.save(cart);
        }
    }

    // Helper methods
    private Cart getOrCreateCart(String userId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (cartOptional.isPresent()) {
            return cartOptional.get();
        } else {
            Cart newCart = new Cart();
            newCart.setUserId(userId);
            return cartRepository.save(newCart);
        }
    }

    private void updateCartTotalPrice(Cart cart) {
        double total = cart.getItems().stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();
        cart.setTotalPrice(total);
    }
}