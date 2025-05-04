package com.example.ecommerceproject.model.pc;
import com.example.ecommerceproject.model.Product;

public interface PCBuilder {
    void reset();
    void setName(String name);
    void setUserId(String userId);
    void setCpu(Product cpu);
    void setMotherboard(Product motherboard);
    void setGpu(Product gpu);
    void setRam(Product ram);
    void setStorage(Product storage);
    void setPowerSupply(Product powerSupply);
    void setPcCase(Product pcCase);
    void setCooling(Product cooling);
    void validateCompatibility();
    PC build();
    void suggestWorkstationComponents();
    void suggestGamingComponents();
}