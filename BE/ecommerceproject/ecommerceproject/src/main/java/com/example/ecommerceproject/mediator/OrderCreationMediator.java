package com.example.ecommerceproject.mediator;

import com.example.ecommerceproject.model.Order;

import java.util.List;

public interface OrderCreationMediator {
    Order createOrder(String userId, String shippingAddress, String paymentMethod, List<String> selectedItemIds);
}