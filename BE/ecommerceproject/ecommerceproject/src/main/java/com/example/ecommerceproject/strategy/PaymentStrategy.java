package com.example.ecommerceproject.strategy;

import com.example.ecommerceproject.model.Order;

import java.util.Map;

/**
 * Strategy interface for payment processing
 * This defines the contract for all payment method implementations
 */
public interface PaymentStrategy {
    /**
     * Processes the payment for the given order
     * @param order The order to process payment for
     * @param paymentDetails Additional details required for payment (e.g., dummy card info)
     * @return true if payment is successful (simulated), false otherwise
     */
    boolean pay(Order order, Map<String, Object> paymentDetails);
    
    /**
     * Get the payment method name
     * @return The name of this payment method (e.g., "CREDIT_CARD", "COD")
     */
    String getPaymentMethodName();
}