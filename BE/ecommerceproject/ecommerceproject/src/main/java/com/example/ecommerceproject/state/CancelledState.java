package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * CancelledState - Concrete State (Component of State Pattern)
 * Represents an order that has been cancelled
 */
public class CancelledState implements OrderState {
    private static final Logger logger = LoggerFactory.getLogger(CancelledState.class);
    
    @Override
    public boolean process(Order order) {
        // Cannot process a cancelled order
        logger.warn("Cannot process order {} from CANCELLED state - order is cancelled", order.getId());
        return false;
    }
    
    @Override
    public boolean cancel(Order order) {
        // Cannot cancel an already cancelled order
        logger.warn("Cannot cancel order {} from CANCELLED state - order is already cancelled", order.getId());
        return false;
    }
    
    @Override
    public String getStateName() {
        return OrderStatus.CANCELLED.name();
    }
}