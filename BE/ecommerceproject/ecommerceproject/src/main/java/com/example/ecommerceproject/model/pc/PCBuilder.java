package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;

public interface PCBuilder {
    PCBuilder reset();
    PCBuilder setName(String name);
    PCBuilder setUserId(String userId);
    PCBuilder setCpu(Product cpu);
    PCBuilder setMotherboard(Product motherboard);
    PCBuilder setGpu(Product gpu);
    PCBuilder setRam(Product ram);
    PCBuilder setStorage(Product storage);
    PCBuilder setPowerSupply(Product powerSupply);
    PCBuilder setPcCase(Product pcCase);
    PCBuilder setCooling(Product cooling);
    PCBuilder validateCompatibility();
    PCBuilder suggestGamingComponents();
    PCBuilder suggestWorkstationComponents();
    PC build();
}