package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * PaidState - Concrete State (Component of State Pattern)
 * Represents an order that has been paid and is ready to be shipped
 */
public class PaidState implements OrderState {
    private static final Logger logger = LoggerFactory.getLogger(PaidState.class);
    
    @Override
    public boolean process(Order order) {
        // Process to SHIPPED state
        logger.info("Processing order {} from PAID state to SHIPPED state", order.getId());
        order.updateStatus(OrderStatus.SHIPPING);
        return true;
    }
    
    @Override
    public boolean cancel(Order order) {
        // Can still cancel after payment, will need refund process in real-world
        logger.info("Cancelling order {} from PAID state (refund required)", order.getId());
        order.updateStatus(OrderStatus.CANCELLED);
        return true;
    }
    
    @Override
    public String getStateName() {
        return OrderStatus.PAID.name();
    }
}