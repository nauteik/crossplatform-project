package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * DeliveredState - Concrete State (Component of State Pattern)
 * Represents an order that has been delivered to the customer
 */
public class DeliveredState implements OrderState {
    private static final Logger logger = LoggerFactory.getLogger(DeliveredState.class);
    
    @Override
    public boolean process(Order order) {
        // Cannot process further than delivered
        logger.warn("Cannot process order {} from DELIVERED state - already in final state", order.getId());
        return false;
    }
    
    @Override
    public boolean cancel(Order order) {
        // Cannot cancel after delivery except through a return process (not implemented here)
        logger.warn("Cannot cancel order {} from DELIVERED state - need to initiate a return process", order.getId());
        return false;
    }
    
    @Override
    public String getStateName() {
        return OrderStatus.DELIVERED.name();
    }
}