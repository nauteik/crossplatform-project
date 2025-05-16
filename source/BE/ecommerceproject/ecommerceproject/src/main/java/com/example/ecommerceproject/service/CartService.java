package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.repository.CartRepository;
import com.example.ecommerceproject.singleton.AppLogger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CartService {

    private static final AppLogger logger = AppLogger.getInstance();

    @Autowired
    private CartRepository cartRepository;

    public Cart getCartByUserId(String userId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (cartOptional.isPresent()) {
            return cartOptional.get();
        } else {
            Cart newCart = new Cart();
            newCart.setUserId(userId);
            newCart = cartRepository.save(newCart);
            return newCart;
        }
    }

    public Cart addItemToCart(String userId, CartItem cartItem) {
        Cart cart = getOrCreateCart(userId);

        boolean productExists = false;

        for (CartItem item : cart.getItems()) {
            if (item.getProductId().equals(cartItem.getProductId())) {
                item.setQuantity(item.getQuantity() + cartItem.getQuantity());
                productExists = true;
                break;
            }
        }

        if (!productExists) {
            cart.getItems().add(cartItem);
        }

        updateCartTotalPrice(cart);

        return cartRepository.save(cart);
    }


    public Cart removeItemFromCart(String userId, String productId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (!cartOptional.isPresent()) {
            return new Cart();
        }

        Cart cart = cartOptional.get();

        cart.setItems(cart.getItems().stream()
                .filter(item -> !item.getProductId().equals(productId))
                .collect(Collectors.toList()));

        updateCartTotalPrice(cart);

        return cartRepository.save(cart);
    }

    /**
     * Remove multiple items from the cart by product IDs
     * This is used after successful payment to remove only the purchased items
     * 
     * @param userId User ID
     * @param productIds List of product IDs to remove
     */
    public void removeItemsFromCart(String userId, List<String> productIds) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (!cartOptional.isPresent()) {
            logger.warn("Attempted to remove items from non-existent cart for user: {}", userId);
            return;
        }

        Cart cart = cartOptional.get();
        int initialCount = cart.getItems().size();
        
        // Filter out the items with product IDs in the list
        cart.setItems(cart.getItems().stream()
                .filter(item -> !productIds.contains(item.getProductId()))
                .collect(Collectors.toList()));
        
        int removedCount = initialCount - cart.getItems().size();
        logger.info("Removed {} items from cart for user: {}", removedCount, userId);

        // Recalculate total price
        updateCartTotalPrice(cart);

        // Save the updated cart
        cartRepository.save(cart);
    }

    public void clearCartItemsList(String userId) {
        Optional<Cart> cartOptional = cartRepository.findByUserId(userId);

        if (cartOptional.isPresent()) {
            Cart cart = cartOptional.get();
            cart.getItems().clear();
            cart.setTotalPrice(0);
            cartRepository.save(cart);
        }
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