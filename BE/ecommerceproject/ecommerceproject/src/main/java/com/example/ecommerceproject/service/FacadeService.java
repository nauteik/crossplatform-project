package com.example.ecommerceproject.service;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.response.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FacadeService {
    private final BrandService brandService;
    private final CartService cartService;
    private final ProductService productService;
    private final ProductTypeService productTypeService;
    private final UserService userService;

    @Autowired
    public FacadeService(BrandService brandService, CartService cartService, ProductService productService, ProductTypeService productTypeService, UserService userService) {
        this.brandService = brandService;
        this.cartService = cartService;
        this.productService = productService;
        this.productTypeService = productTypeService;
        this.userService = userService;
    }

    // Quy trình thêm sản phẩn vào giỏ hàng
    @Transactional
    public ApiResponse<?> addToCart(String userId, CartItem cartItem) {
        // 1. Xác thực người dùng
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
        productService.decreaseQuantity(cartItem.getProductId(), cartItem.getQuantity());

        return new ApiResponse<>(ApiStatus.SUCCESS.getCode(), "Item added to cart successfully!", cart);
    }
}
