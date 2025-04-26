package com.example.ecommerceproject.mediator;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderItem;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.service.CartService;
import com.example.ecommerceproject.service.ProductService;
import com.example.ecommerceproject.service.PaymentService; // Needed for payment method validation
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class OrderCreationMediatorImpl implements OrderCreationMediator {

    private static final Logger logger = LoggerFactory.getLogger(OrderCreationMediatorImpl.class);

    private final CartService cartService;
    private final PaymentService paymentService;
    private final ProductService productService;
    private final OrderRepository orderRepository;

    @Autowired
    public OrderCreationMediatorImpl(CartService cartService, PaymentService paymentService, ProductService productService, OrderRepository orderRepository) {
        this.cartService = cartService;
        this.paymentService = paymentService;
        this.productService = productService;
        this.orderRepository = orderRepository;
    }

    @Override
    @Transactional
    public Order createOrder(String userId, String shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        logger.info("Mediator coordinating order creation for user: {}", userId);

        // Step 1: Validate payment method (Interacts with PaymentService 'colleague')
        if (!paymentService.getSupportedPaymentMethods().contains(paymentMethod)) {
            throw new IllegalArgumentException("Unsupported payment method: " + paymentMethod);
        }

        // Step 2: Get user's cart (Interacts with CartService 'colleague')
        Cart cart = cartService.getCartByUserId(userId);
        if (cart.getItems().isEmpty()) {
            throw new IllegalArgumentException("Cannot create order with empty cart");
        }

        // Step 3: Filter items if selectedItemIds is provided
        List<CartItem> itemsToOrder = cart.getItems();
        if (selectedItemIds != null && !selectedItemIds.isEmpty()) {
            logger.debug("Filtering cart items based on selectedItemIds for user: {}", userId);
            itemsToOrder = cart.getItems().stream()
                    .filter(item -> selectedItemIds.contains(item.getProductId()))
                    .collect(Collectors.toList());

            if (itemsToOrder.isEmpty()) {
                throw new IllegalArgumentException("None of the selected items were found in the cart");
            }
        }

        // Step 4: Convert CartItems to OrderItems and check product availability
        List<OrderItem> orderItems = new ArrayList<>();
        double totalAmount = 0.0;

        for (CartItem cartItem : itemsToOrder) {
            Product product = productService.getProductById(cartItem.getProductId());

            if (product == null) {
                throw new IllegalArgumentException("Product not found in catalog: " + cartItem.getProductId());
            }

            if (product.getQuantity() < cartItem.getQuantity()) {
                logger.warn("Not enough stock for product: {} (Requested: {}, Available: {})",
                        product.getName(), cartItem.getQuantity(), product.getQuantity());
                throw new IllegalArgumentException("Not enough stock for product: " + product.getName());
            }

            productService.decreaseQuantity(cartItem.getProductId(), cartItem.getQuantity());
            logger.debug("Decreased stock for product {}: by {}", cartItem.getProductId(), cartItem.getQuantity());

            OrderItem orderItem = new OrderItem(
                    cartItem.getProductId(),
                    cartItem.getProductName(),
                    cartItem.getQuantity(),
                    cartItem.getPrice(),
                    cartItem.getImageUrl()
            );
            orderItems.add(orderItem);

            totalAmount += cartItem.getPrice() * cartItem.getQuantity();
        }

        // Step 5: Create and Save the order (Interacts with OrderRepository 'colleague')
        Order order = new Order();
        order.setUserId(userId);
        order.setItems(orderItems);
        order.setTotalAmount(totalAmount);
        order.setStatus(OrderStatus.PENDING);
        order.setPaymentMethod(paymentMethod);
        order.setShippingAddress(shippingAddress);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());

        Order savedOrder = orderRepository.save(order);
        logger.info("Mediator successfully created order: {} with status: {} for user: {}",
                savedOrder.getId(), savedOrder.getStatus(), savedOrder.getUserId());

        return savedOrder;
    }
}