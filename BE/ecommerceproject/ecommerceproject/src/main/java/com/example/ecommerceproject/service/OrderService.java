package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.OrderRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service for managing orders
 */
@Service
public class OrderService {

    private static final Logger logger = LoggerFactory.getLogger(OrderService.class);
    
    @Autowired
    private OrderRepository orderRepository;
    
    @Autowired
    private CartService cartService;
    
    @Autowired
    private ProductService productService;
    
    @Autowired
    private PaymentService paymentService;
    
    /**
     * Create a new order with PENDING status
     * 
     * @param userId User ID
     * @param shippingAddress Shipping address
     * @param paymentMethod Payment method (must be supported by PaymentService)
     * @param selectedItemIds Optional list of specific cart item IDs to include in the order
     * @return The created order
     * @throws IllegalArgumentException if cart is empty or products are unavailable
     */
    @Transactional
    public Order createOrder(String userId, String shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        // Validate payment method is supported
        if (!paymentService.getSupportedPaymentMethods().contains(paymentMethod)) {
            throw new IllegalArgumentException("Unsupported payment method: " + paymentMethod);
        }
        
        // Get user's cart
        Cart cart = cartService.getCartByUserId(userId);
        if (cart.getItems().isEmpty()) {
            throw new IllegalArgumentException("Cannot create order with empty cart");
        }
        
        // Filter items if selectedItemIds is provided
        List<CartItem> itemsToOrder = cart.getItems();
        if (selectedItemIds != null && !selectedItemIds.isEmpty()) {
            logger.info("Creating order with selected items only. User: {}, Selected item count: {}", 
                      userId, selectedItemIds.size());
            
            itemsToOrder = cart.getItems().stream()
                .filter(item -> selectedItemIds.contains(item.getProductId()))
                .collect(Collectors.toList());
                
            if (itemsToOrder.isEmpty()) {
                throw new IllegalArgumentException("None of the selected items were found in the cart");
            }
        }
        
        // Convert CartItems to OrderItems and check product availability
        List<OrderItem> orderItems = new ArrayList<>();
        double totalAmount = 0.0;
        
        for (CartItem cartItem : itemsToOrder) {
            // Check product availability/quantity
            Product product = productService.getProductById(cartItem.getProductId());
            
            if (product == null) {
                throw new IllegalArgumentException("Product not found: " + cartItem.getProductId());
            }
            
            if (product.getQuantity() < cartItem.getQuantity()) {
                throw new IllegalArgumentException("Not enough stock for product: " + product.getName());
            }
            
            // Decrease product quantity
            productService.decreaseQuantity(cartItem.getProductId(), cartItem.getQuantity());
            
            // Add to order items
            OrderItem orderItem = new OrderItem(
                cartItem.getProductId(),
                cartItem.getProductName(),
                cartItem.getQuantity(),
                cartItem.getPrice(),
                cartItem.getImageUrl()
            );
            orderItems.add(orderItem);
            
            // Calculate total amount
            totalAmount += cartItem.getPrice() * cartItem.getQuantity();
        }
        
        // Create order with PENDING status
        Order order = new Order();
        order.setUserId(userId);
        order.setItems(orderItems);
        order.setTotalAmount(totalAmount);
        order.setStatus(OrderStatus.PENDING);
        order.setPaymentMethod(paymentMethod);
        order.setShippingAddress(shippingAddress);
        order.setCreatedAt(LocalDateTime.now());
        order.setUpdatedAt(LocalDateTime.now());
        
        // Save the order
        Order savedOrder = orderRepository.save(order);
        logger.info("Created order: {} with status: {} for user: {}", 
                  savedOrder.getId(), savedOrder.getStatus(), savedOrder.getUserId());
                  
        return savedOrder;
    }
    
    /**
     * Process payment for an existing order
     * 
     * @param orderId Order ID
     * @param paymentDetails Payment details (depends on payment method)
     * @return The updated order
     * @throws IllegalArgumentException if order not found or not in PENDING status
     */
    @Transactional
    public Order processOrderPayment(String orderId, Map<String, Object> paymentDetails) {
        // Get the order
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
        
        // Check order status
        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Cannot process payment for order with status: " + order.getStatus());
        }
        
        // Process the payment through PaymentService
        boolean paymentSuccess = paymentService.processPayment(order, paymentDetails);
        
        // Update order status based on payment result
        if (paymentSuccess) {
            order.updateStatus(OrderStatus.PAID);
            logger.info("Payment successful for order: {}, updating status to: {}", 
                      order.getId(), order.getStatus());
                      
            // Remove only the ordered items from cart instead of clearing the entire cart
            List<String> productIds = order.getItems().stream()
                .map(OrderItem::getProductId)
                .collect(Collectors.toList());
            
            cartService.removeItemsFromCart(order.getUserId(), productIds);
            logger.info("Removed {} items from cart for user: {} after successful payment", 
                      productIds.size(), order.getUserId());
        } else {
            order.updateStatus(OrderStatus.FAILED);
            logger.warn("Payment failed for order: {}, updating status to: {}", 
                      order.getId(), order.getStatus());
                      
            // Restore product quantities if payment fails
            restoreProductQuantities(order);
        }
        
        // Save the updated order
        Order updatedOrder = orderRepository.save(order);
        return updatedOrder;
    }
    
    /**
     * Restore product quantities for failed orders
     */
    private void restoreProductQuantities(Order order) {
        for (OrderItem item : order.getItems()) {
            productService.increaseQuantity(item.getProductId(), item.getQuantity());
            logger.info("Restored {} units of product: {} after failed payment", 
                      item.getQuantity(), item.getProductId());
        }
    }
    
    /**
     * Update the status of an order
     * 
     * @param orderId Order ID
     * @param newStatus New order status
     * @return The updated order
     * @throws IllegalArgumentException if order not found
     */
    @Transactional
    public Order updateOrderStatus(String orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
        
        order.updateStatus(newStatus);
        logger.info("Updated order: {} status from: {} to: {}", 
                  order.getId(), order.getStatus(), newStatus);
                  
        return orderRepository.save(order);
    }
    
    /**
     * Get an order by ID
     * 
     * @param orderId Order ID
     * @return The order
     * @throws IllegalArgumentException if order not found
     */
    public Order getOrderById(String orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
    }
    
    /**
     * Get all orders for a user
     * 
     * @param userId User ID
     * @return List of orders
     */
    public List<Order> getOrdersByUserId(String userId) {
        return orderRepository.findByUserId(userId);
    }
}