package com.example.ecommerceproject.strategy;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.singleton.AppLogger;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Concrete strategy for processing Credit Card payments
 */
@Component
public class CreditCardPaymentStrategy implements PaymentStrategy {

    private static final AppLogger logger = AppLogger.getInstance();
    private static final String PAYMENT_METHOD = "CREDIT_CARD";
    
    @Override
    public boolean pay(Order order, Map<String, Object> paymentDetails) {
        // Extract card details (in a real system, this would validate and process through a payment gateway)
        String cardNumber = (String) paymentDetails.getOrDefault("cardNumber", "");
        String cardName = (String) paymentDetails.getOrDefault("cardName", "");
        String expiryDate = (String) paymentDetails.getOrDefault("expiryDate", "");
        String cvv = (String) paymentDetails.getOrDefault("cvv", "");
        
        // Log payment attempt (for demonstration purposes)
        logger.info("Processing CREDIT CARD payment for Order ID: {}", order.getId());
        logger.info("Payment Amount: ${}", order.getTotalAmount());
        logger.info("Card Details: {} (ending with {})", cardName, 
                cardNumber.length() > 4 ? cardNumber.substring(cardNumber.length() - 4) : "****");
        
        // Simulate payment processing
        boolean isValid = isValidCardDetails(cardNumber, expiryDate, cvv);
        
        if (isValid) {
            logger.info("Credit Card payment successful for Order ID: {}", order.getId());
            return true;
        } else {
            logger.warn("Credit Card payment failed for Order ID: {}", order.getId());
            return false;
        }
    }
    
    @Override
    public String getPaymentMethodName() {
        return PAYMENT_METHOD;
    }
    
    /**
     * Simple validation for card details (in a real system, this would be much more comprehensive)
     */
    private boolean isValidCardDetails(String cardNumber, String expiryDate, String cvv) {
        // This is a very basic simulation - in reality, would validate format, check Luhn algorithm, etc.
        boolean hasCardNumber = cardNumber != null && !cardNumber.trim().isEmpty();
        boolean hasExpiryDate = expiryDate != null && !expiryDate.trim().isEmpty();
        boolean hasCvv = cvv != null && !cvv.trim().isEmpty();
        
        // For demo purposes: 90% success rate, 10% simulated failure
        double randomValue = Math.random();
        
        return hasCardNumber && hasExpiryDate && hasCvv && (randomValue < 0.9);
    }
}