package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.singleton.AppLogger;
import com.example.ecommerceproject.strategy.PaymentStrategy;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PaymentService {

    private static final AppLogger logger = AppLogger.getInstance();
    private final Map<String, PaymentStrategy> paymentStrategies = new HashMap<>();

    @Autowired
    public PaymentService(List<PaymentStrategy> strategyList) {
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
            logger.info("Attempting to process payment for order: {}, method: {}",
                    order.getId(), paymentMethod);

            boolean success = strategy.pay(order, paymentDetails);

            if (success) {
                logger.info("Payment strategy reported success for order: {}", order.getId());
            } else {
                logger.warn("Payment strategy reported failure for order: {}", order.getId());
            }

            return success;
        } catch (Exception e) {
            logger.error("Error during payment strategy execution for order {}: {}", order.getId(), e.getMessage(), e);
            return false;
        }
    }

    public List<String> getSupportedPaymentMethods() {
        return List.copyOf(paymentStrategies.keySet());
    }
}