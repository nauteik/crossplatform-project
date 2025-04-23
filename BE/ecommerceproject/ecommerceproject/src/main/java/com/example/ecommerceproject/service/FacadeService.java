package com.example.ecommerceproject.service;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@Service
public class FacadeService {
    private final CartService cartService;
    private final ProductService productService;
    private final UserService userService;

    @Autowired
    public FacadeService(CartService cartService, ProductService productService, UserService userService) {
        this.cartService = cartService;
        this.productService = productService;
        this.userService = userService;
    }

    // Quy trình thêm sản phẩn vào giỏ hàng
    @Transactional
    public ApiResponse<?> addItemToCart(String userId, CartItem cartItem) {
        // 1. Kiểm tra người dùng
        User user = userService.getUserById(userId);
        if (user == null) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "User not found", null);
        }

        // 2. Kiểm tra sản phẩm
        Product product = productService.getProductById(cartItem.getProductId());
        if (product == null) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "Product not found", null);
        }
        if (product.getQuantity() < cartItem.getQuantity()) {
            return new ApiResponse<>(ApiStatus.INVALID_TOKEN.getCode(), "Not enough quantity", null);
        }

        // 3. Thêm sản phẩm vào giỏ hàng
        Cart cart = cartService.addItemToCart(userId, cartItem);

        // 4. Giảm số lượng sản phẩm trong kho
        productService.decreaseQuantity(cartItem.getProductId(), cartItem.getQuantity());

        return new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Item added to cart successfully!", cart);
    }

    @Transactional
    public ApiResponse<?> removeItemFromCart(String userId, String productId) {
        // 1. Kiểm tra người dùng
        User user = userService.getUserById(userId);
        if (user == null) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "User not found", null);
        }

        // 2. Kiểm tra sản phẩm trong giỏ hàng
        Cart cart = cartService.getCartByUserId(userId);
        List<CartItem> cartItemList = cart.getItems();
        boolean productExistsInCart = false;
        CartItem existingItem = null;

        for (CartItem cI : cartItemList) {
            if (cI.getProductId().equals(productId)) {
                productExistsInCart = true;
                existingItem = cI;
                break;
            }
        }

        if (!productExistsInCart) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "Product not found in cart", null);
        }

        // 3. Xóa sản phẩm khỏi giỏ hàng
        cartService.removeItemFromCart(userId, productId);

        // 4. Tăng số lượng sản phẩm trong kho
        productService.increaseQuantity(productId, existingItem.getQuantity());

        return new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Item removed from cart successfully!", cart);
    }

    public ApiResponse<?> getCartByUserId(String userId) {
        // 1. Kiểm tra người dùng
        User user = userService.getUserById(userId);
        if (user == null) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "User not found", null);
        }

        // 2. Lấy giỏ hàng
        Cart cart = cartService.getCartByUserId(userId);
        return new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Cart Items List", cart);
    }

    public ApiResponse<?> clearCartItemsList(String userId) {
        // 1. Kiểm tra người dùng
        User user = userService.getUserById(userId);
        if (user == null) {
            return new ApiResponse<>(ApiStatus.NOT_FOUND.getCode(), "User not found", null);
        }

        // 2. Dọn sạch các sản phẩm trong giỏ hàng
        cartService.clearCartItemsList(userId);
        return new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Item list removed from cart", null);
    }
}
