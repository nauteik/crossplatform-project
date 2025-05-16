package com.example.ecommerceproject.strategy;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.singleton.AppLogger;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class CodPaymentStrategy implements PaymentStrategy {

    private static final AppLogger logger = AppLogger.getInstance();
    private static final String PAYMENT_METHOD = "COD";
    
    @Override
    public boolean pay(Order order, Map<String, Object> paymentDetails) {
        // For COD, payment is always considered "successful" at order time
        // Actual payment happens at delivery time
        logger.info("Processing COD payment for Order ID: {}", order.getId());
        logger.info("Payment Amount: ${} will be collected upon delivery", order.getTotalAmount());
        // Extract additional details if provided
        String deliveryNotes = (String) paymentDetails.getOrDefault("deliveryNotes", "");
        if (!deliveryNotes.isEmpty()) {
            logger.info("Delivery Notes: {}", deliveryNotes);
        }
        // COD orders are always successful during order placement
        // (payment will happen at delivery time)
        logger.info("COD payment recorded successfully for Order ID: {}", order.getId());
        return true;
    }
    @Override
    public String getPaymentMethodName() {
        return PAYMENT_METHOD;
    }
}