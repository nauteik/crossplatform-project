package com.example.ecommerceproject.strategy;
import com.example.ecommerceproject.model.Order;
import java.util.Map;
public interface PaymentStrategy {
    boolean pay(Order order, Map<String, Object> paymentDetails);
    String getPaymentMethodName();
}