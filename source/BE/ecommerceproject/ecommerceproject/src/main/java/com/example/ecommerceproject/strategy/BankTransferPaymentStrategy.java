package com.example.ecommerceproject.strategy;

import com.example.ecommerceproject.model.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Concrete strategy for processing Bank Transfer payments
 */
@Component
public class BankTransferPaymentStrategy implements PaymentStrategy {
    
    private static final Logger logger = LoggerFactory.getLogger(BankTransferPaymentStrategy.class);
    private static final String PAYMENT_METHOD = "BANK_TRANSFER";
    
    @Override
    public boolean pay(Order order, Map<String, Object> paymentDetails) {
        // Extract bank transfer details
        String accountNumber = (String) paymentDetails.getOrDefault("accountNumber", "");
        String bankName = (String) paymentDetails.getOrDefault("bankName", "");
        String transferCode = (String) paymentDetails.getOrDefault("transferCode", "");
        
        // Log payment attempt
        logger.info("Processing BANK TRANSFER payment for Order ID: {}", order.getId());
        logger.info("Payment Amount: {}", order.getTotalAmount());
        logger.info("Bank Details: {} - Account: {}", bankName, 
                accountNumber.length() > 4 ? "****" + accountNumber.substring(accountNumber.length() - 4) : "****");
        
        if (transferCode != null && !transferCode.isEmpty()) {
            logger.info("Transfer Code provided: {}", transferCode);
        }
        
        // Validate transfer details
        boolean isValid = isValidTransfer(accountNumber, bankName, transferCode);
        
        if (isValid) {
            logger.info("Bank Transfer payment successful for Order ID: {}", order.getId());
            return true;
        } else {
            logger.warn("Bank Transfer payment failed for Order ID: {}", order.getId());
            return false;
        }
    }
    
    @Override
    public String getPaymentMethodName() {
        return PAYMENT_METHOD;
    }
    
    /**
     * Simple validation for bank transfer details
     */
    private boolean isValidTransfer(String accountNumber, String bankName, String transferCode) {
        boolean hasAccountNumber = accountNumber != null && !accountNumber.trim().isEmpty();
        boolean hasBankName = bankName != null && !bankName.trim().isEmpty();
        
        // For demo purposes: 95% success rate
        double randomValue = Math.random();
        return hasAccountNumber && hasBankName && (randomValue < 0.95);
    }
}