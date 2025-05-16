package com.example.ecommerceproject.mediator;

import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderItem;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.service.CartService;
import com.example.ecommerceproject.singleton.AppLogger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Component
public class OrderPaymentMediatorImpl implements OrderPaymentMediator {

    private static final AppLogger logger = AppLogger.getInstance();

    private final OrderRepository orderRepository;
    private final CartService cartService;

    @Autowired
    public OrderPaymentMediatorImpl(OrderRepository orderRepository, CartService cartService) {
        this.orderRepository = orderRepository;
        this.cartService = cartService;
    }

    @Override
    @Transactional
    public Order handlePaymentResult(Order order, boolean paymentSuccess) {
        logger.info("Mediator handling payment result for order: {} - Success: {}", order.getId(), paymentSuccess);

        if (paymentSuccess) {
            handleSuccessfulPayment(order);
        } else {
            handleFailedPayment(order);
        }

        Order updatedOrder = orderRepository.save(order);
        logger.info("Order {} status updated to {}", order.getId(), updatedOrder.getStatus());

        return updatedOrder;
    }

    private void handleSuccessfulPayment(Order order) {
        order.updateStatus(OrderStatus.PAID);
        logger.info("Payment successful for order: {}, updating status to: {}",
                order.getId(), order.getStatus());

        List<String> productIds = order.getItems().stream()
                .map(OrderItem::getProductId)
                .collect(Collectors.toList());

        cartService.removeItemsFromCart(order.getUserId(), productIds);
        logger.info("Removed {} items from cart for user: {} after successful payment",
                productIds.size(), order.getUserId());
    }

    private void handleFailedPayment(Order order) {
        order.updateStatus(OrderStatus.FAILED);
        logger.warn("Payment failed for order: {}, updating status to: {}",
                order.getId(), order.getStatus());
    }
}




