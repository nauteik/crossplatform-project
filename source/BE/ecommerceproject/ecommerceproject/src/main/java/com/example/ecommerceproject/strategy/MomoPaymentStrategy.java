package com.example.ecommerceproject.strategy;

import com.example.ecommerceproject.model.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Concrete strategy for processing MoMo e-wallet payments
 */
@Component
public class MomoPaymentStrategy implements PaymentStrategy {
    
    private static final Logger logger = LoggerFactory.getLogger(MomoPaymentStrategy.class);
    private static final String PAYMENT_METHOD = "MOMO";
    
    @Override
    public boolean pay(Order order, Map<String, Object> paymentDetails) {
        // Extract MoMo payment details
        String phoneNumber = (String) paymentDetails.getOrDefault("phoneNumber", "");
        String transactionId = (String) paymentDetails.getOrDefault("transactionId", "");
        
        // Log payment attempt
        logger.info("Processing MOMO payment for Order ID: {}", order.getId());
        logger.info("Payment Amount: {}", order.getTotalAmount());
        logger.info("MoMo Account: {}", 
                phoneNumber.length() > 3 ? phoneNumber.substring(0, 3) + "****" + 
                phoneNumber.substring(phoneNumber.length() - 3) : "****");
        
        if (transactionId != null && !transactionId.isEmpty()) {
            logger.info("MoMo Transaction ID: {}", transactionId);
        }
        
        // Validate MoMo details
        boolean isValid = isValidMomoPayment(phoneNumber, transactionId);
        
        if (isValid) {
            logger.info("MoMo payment successful for Order ID: {}", order.getId());
            return true;
        } else {
            logger.warn("MoMo payment failed for Order ID: {}", order.getId());
            return false;
        }
    }
    
    @Override
    public String getPaymentMethodName() {
        return PAYMENT_METHOD;
    }
    
    /**
     * Simple validation for MoMo payment details
     */
    private boolean isValidMomoPayment(String phoneNumber, String transactionId) {
        boolean hasPhoneNumber = phoneNumber != null && !phoneNumber.trim().isEmpty();
        
        // Basic validation - for actual integration, would verify with MoMo API
        boolean isValidPhoneNumber = hasPhoneNumber && phoneNumber.length() >= 10;
        
        // For demo purposes: 98% success rate for MoMo payments
        double randomValue = Math.random();
        return isValidPhoneNumber && (randomValue < 0.98);
    }
}