package com.example.ecommerceproject.mediator;

import com.example.ecommerceproject.model.Order;

public interface OrderPaymentMediator {
    Order handlePaymentResult(Order order, boolean paymentSuccess);
}