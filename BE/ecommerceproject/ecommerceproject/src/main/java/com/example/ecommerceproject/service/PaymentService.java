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

@Service
public class PaymentService {
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);
    private final Map<String, PaymentStrategy> paymentStrategies = new HashMap<>();
    @Autowired
    public PaymentService(List<PaymentStrategy> strategyList) {
        // Initialize the strategy map
        strategyList.forEach(strategy -> 
            paymentStrategies.put(strategy.getPaymentMethodName(), strategy));
        
        logger.info("Initialized payment strategies: {}", 
            paymentStrategies.keySet());
    }
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
    public List<String> getSupportedPaymentMethods() {
        return List.copyOf(paymentStrategies.keySet());
    }
}