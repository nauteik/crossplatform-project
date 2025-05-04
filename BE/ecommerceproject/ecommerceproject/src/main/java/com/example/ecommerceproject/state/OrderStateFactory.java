package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.OrderStatus;
import org.springframework.stereotype.Component;

/**
 * OrderStateFactory - Factory class for creating state objects
 * This is not strictly part of the State Pattern but helps with state management
 */
@Component
public class OrderStateFactory {

    /**
     * Get the appropriate state object based on the order status
     * @param status current order status
     * @return the corresponding OrderState object
     */
    public OrderState getState(OrderStatus status) {
        switch (status) {
            case PENDING:
                return new PendingState();
            case PAID:
                return new PaidState();
            case SHIPPED:
                return new ShippingState();
            case DELIVERED:
                return new DeliveredState();
            case CANCELLED:
                return new CancelledState();
            case FAILED:
                return new FailedState();
            default:
                throw new IllegalArgumentException("Unknown order status: " + status);
        }
    }
}