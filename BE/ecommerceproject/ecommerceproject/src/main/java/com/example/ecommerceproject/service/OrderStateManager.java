package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.state.*;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * OrderStateManager - Context (Component of State Pattern)
 * Manages the state transitions for orders using the State Pattern
 */
@Service
public class OrderStateManager {
    private static final Logger logger = LoggerFactory.getLogger(OrderStateManager.class);
    
    @Autowired
    private OrderRepository orderRepository;

    private OrderState getStateForStatus(OrderStatus status) {
        switch (status) {
            case PENDING:
                return new PendingState();
            case PAID:
                return new PaidState();
            case SHIPPING:
                return new ShippingState();
            case DELIVERED:
                return new DeliveredState();
            case CANCELLED:
                return new CancelledState();
            default:
                throw new IllegalArgumentException("Unknown order status: " + status);
        }
    }
    @Transactional
    public boolean processOrder(String orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with ID: " + orderId));
                
        OrderState currentState = getStateForStatus(order.getStatus());
        logger.info("Processing order {} in state {}", orderId, currentState.getStateName());
        
        boolean result = currentState.process(order);
        if (result) {
            orderRepository.save(order);
            logger.info("Order {} successfully processed to state {}", orderId, order.getStatus());
        }
        
        return result;
    }

    @Transactional
    public boolean cancelOrder(String orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found with ID: " + orderId));
                
        OrderState currentState = getStateForStatus(order.getStatus());
        logger.info("Attempting to cancel order {} in state {}", orderId, currentState.getStateName());
        
        boolean result = currentState.cancel(order);
        if (result) {
            orderRepository.save(order);
            logger.info("Order {} successfully cancelled from state {}", orderId, currentState.getStateName());
        }
        
        return result;
    }
}