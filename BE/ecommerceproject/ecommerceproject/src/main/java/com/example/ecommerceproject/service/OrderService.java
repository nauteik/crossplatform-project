package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.singleton.AppLogger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.example.ecommerceproject.mediator.OrderCreationMediator; // Import Order Creation Mediator
import com.example.ecommerceproject.mediator.OrderPaymentMediator; // Import Order Payment Mediator
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * Service for managing orders.
 * This service acts as a client to the Mediators.
 * It delegates the complex processes of Order Creation and Payment Handling
 * to the respective Mediator objects, reducing its own complexity and coupling
 * to the details of these processes and the services involved.
 */
@Service
public class OrderService {

    private static final AppLogger logger = AppLogger.getInstance();

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private OrderCreationMediator orderCreationMediator;

    @Autowired
    private OrderPaymentMediator orderPaymentMediator;

    @Transactional
    public Order createOrder(String userId, String shippingAddress, String paymentMethod, List<String> selectedItemIds) {
        logger.info("OrderService initiating order creation process for user: {}", userId);
        return orderCreationMediator.createOrder(userId, shippingAddress, paymentMethod, selectedItemIds);
    }

    @Transactional
    public Order processOrderPayment(String orderId, Map<String, Object> paymentDetails) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        if (order.getStatus() != OrderStatus.PENDING) {
            throw new IllegalArgumentException("Cannot process payment for order with status: " + order.getStatus());
        }

        logger.info("OrderService initiating payment process via PaymentService for order: {}", order.getId());
        boolean paymentSuccess = paymentService.processPayment(order, paymentDetails);

        logger.info("Payment process completed. OrderService delegating result handling to OrderPaymentMediator for order: {}", order.getId());
        return orderPaymentMediator.handlePaymentResult(order, paymentSuccess);
    }

    @Transactional
    public Order updateOrderStatus(String orderId, OrderStatus newStatus) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));

        order.updateStatus(newStatus);
        logger.info("OrderService updated order: {} status from: {} to: {}",
                order.getId(), order.getStatus(), newStatus);

        return orderRepository.save(order);
    }

    public Order getOrderById(String orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found: " + orderId));
    }

    public List<Order> getOrdersByUserId(String userId) {
        return orderRepository.findByUserId(userId);
    }
}