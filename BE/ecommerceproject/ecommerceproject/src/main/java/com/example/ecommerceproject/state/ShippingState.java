package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * ShippedState - Concrete State (Component of State Pattern)
 * Represents an order that has been shipped and is in transit
 */
public class ShippingState implements OrderState {
    private static final Logger logger = LoggerFactory.getLogger(ShippingState.class);
    
    @Override
    public boolean process(Order order) {
        // Process to DELIVERED state
        logger.info("Processing order {} from SHIPPED state to DELIVERED state", order.getId());
        order.setStatus(OrderStatus.DELIVERED);
        return true;
    }
    
    @Override
    public boolean cancel(Order order) {
        // More difficult to cancel once shipped, but still possible in some cases
        logger.info("Attempting to cancel order {} from SHIPPED state (return processing required)", order.getId());
        // In a real system this might need approval or additional steps
        order.setStatus(OrderStatus.CANCELLED);
        return true;
    }
    
    @Override
    public String getStateName() {
        return OrderStatus.SHIPPING.name();
    }
}