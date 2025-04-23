package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.strategy.PaymentStrategy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Service for processing payments using the Strategy pattern
 */
@Service
public class PaymentService {
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);
    private final Map<String, PaymentStrategy> paymentStrategies = new HashMap<>();
    
    /**
     * Constructor that autowires all payment strategies
     * This approach automatically registers any PaymentStrategy implementation beans
     */
    @Autowired
    public PaymentService(List<PaymentStrategy> strategyList) {
        // Initialize the strategy map
        strategyList.forEach(strategy -> 
            paymentStrategies.put(strategy.getPaymentMethodName(), strategy));
        
        logger.info("Initialized payment strategies: {}", 
            paymentStrategies.keySet());
    }
    
    /**
     * Process a payment for an order using the appropriate strategy
     * 
     * @param order The order to process payment for
     * @param paymentDetails Additional details required for the payment
     * @return true if payment was successful, false otherwise
     */
    public boolean processPayment(Order order, Map<String, Object> paymentDetails) {
        String paymentMethod = order.getPaymentMethod();
        PaymentStrategy strategy = paymentStrategies.get(paymentMethod);
        
        if (strategy == null) {
            logger.error("Unsupported payment method: {}", paymentMethod);
            throw new IllegalArgumentException("Unsupported payment method: " + paymentMethod);
        }
        
        try {
            logger.info("Processing payment for order: {}, method: {}", 
                order.getId(), paymentMethod);
            
            boolean success = strategy.pay(order, paymentDetails);
            
            if (success) {
                logger.info("Payment successful for order: {}", order.getId());
            } else {
                logger.warn("Payment failed for order: {}", order.getId());
            }
            
            return success;
        } catch (Exception e) {
            logger.error("Error processing payment: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Get list of supported payment methods
     * @return List of payment method names
     */
    public List<String> getSupportedPaymentMethods() {
        return List.copyOf(paymentStrategies.keySet());
    }
}