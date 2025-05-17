package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * PendingState - Concrete State (Component of State Pattern)
 * Represents an order that is pending payment
 */
public class PendingState implements OrderState {
    private static final Logger logger = LoggerFactory.getLogger(PendingState.class);
    
    @Override
    public boolean process(Order order) {
        // Process payment and move to PAID state
        logger.info("Processing order {} from PENDING state to PAID state", order.getId());
        order.updateStatus(OrderStatus.PAID);
        return true;
    }
    
    @Override
    public boolean cancel(Order order) {
        logger.info("Cancelling order {} from PENDING state", order.getId());
        order.updateStatus(OrderStatus.CANCELLED);
        return true;
    }
    
    @Override
    public String getStateName() {
        return OrderStatus.PENDING.name();
    }
}