package com.example.ecommerceproject.state;

import com.example.ecommerceproject.model.Order;

public interface OrderState {
    boolean process(Order order);

    boolean cancel(Order order);

    String getStateName();
}