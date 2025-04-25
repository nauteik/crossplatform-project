package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class GamingPCBuilder implements PCBuilder {
    private final StandardPCBuilder standardPCBuilder;
    private final ProductRepository productRepository;
    
    @Autowired
    public GamingPCBuilder(StandardPCBuilder standardPCBuilder, ProductRepository productRepository) {
        this.standardPCBuilder = standardPCBuilder;
        this.productRepository = productRepository;
    }
    
    @Override
    public PCBuilder reset() {
        return standardPCBuilder.reset();
    }
    
    @Override
    public PCBuilder setName(String name) {
        if (name == null || name.isEmpty()) {
            name = "Gaming PC Build";
        }
        return standardPCBuilder.setName(name);
    }
    
    @Override
    public PCBuilder setUserId(String userId) {
        return standardPCBuilder.setUserId(userId);
    }
    
    @Override
    public PCBuilder setCpu(Product cpu) {
        return standardPCBuilder.setCpu(cpu);
    }
    
    @Override
    public PCBuilder setMotherboard(Product motherboard) {
        return standardPCBuilder.setMotherboard(motherboard);
    }
    
    @Override
    public PCBuilder setGpu(Product gpu) {
        return standardPCBuilder.setGpu(gpu);
    }
    
    @Override
    public PCBuilder setRam(Product ram) {
        return standardPCBuilder.setRam(ram);
    }
    
    @Override
    public PCBuilder setStorage(Product storage) {
        return standardPCBuilder.setStorage(storage);
    }
    
    @Override
    public PCBuilder setPowerSupply(Product powerSupply) {
        return standardPCBuilder.setPowerSupply(powerSupply);
    }
    
    @Override
    public PCBuilder setPcCase(Product pcCase) {
        return standardPCBuilder.setPcCase(pcCase);
    }
    
    @Override
    public PCBuilder setCooling(Product cooling) {
        return standardPCBuilder.setCooling(cooling);
    }
    
    @Override
    public PCBuilder validateCompatibility() {
        return standardPCBuilder.validateCompatibility();
    }
    
    @Override
    public PC build() {
        return standardPCBuilder.build();
    }
    
    // Special method to suggest gaming optimized components
    @Override
    public PCBuilder suggestGamingComponents() {
        // Find high-end GPU (assuming higher price = better performance for gaming)
        List<Product> gpus = productRepository.findByProductType_Name("GPU");
        gpus.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice())); // Sort by price descending
        if (!gpus.isEmpty()) {
            standardPCBuilder.setGpu(gpus.get(0)); // Choose the most expensive GPU
        }
        
        // Find high-end CPU
        List<Product> cpus = productRepository.findByProductType_Name("CPU");
        cpus.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice())); // Sort by price descending
        if (!cpus.isEmpty()) {
            standardPCBuilder.setCpu(cpus.get(0)); // Choose the most expensive CPU
        }
        
        // Find high capacity RAM
        List<Product> rams = productRepository.findByProductType_Name("RAM");
        rams.sort((p1, p2) -> {
            // Look for mentions of 32GB in the name or description (simplified)
            boolean p1Has32GB = p1.getName().contains("32GB") || p1.getDescription().contains("32GB");
            boolean p2Has32GB = p2.getName().contains("32GB") || p2.getDescription().contains("32GB");
            
            if (p1Has32GB && !p2Has32GB) return -1;
            if (!p1Has32GB && p2Has32GB) return 1;
            
            // If both or neither have 32GB, sort by price
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!rams.isEmpty()) {
            standardPCBuilder.setRam(rams.get(0));
        }
        
        // Suggest SSD storage for faster game loading
        List<Product> storages = productRepository.findByProductType_Name("SSD");
        if (!storages.isEmpty()) {
            // Find a balance between price and capacity (simplified)
            storages.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice()));
            
            if (storages.size() > 2) {
                // Choose a mid-range option if available
                standardPCBuilder.setStorage(storages.get(1));
            } else {
                standardPCBuilder.setStorage(storages.get(0));
            }
        }
        
        // High wattage power supply for gaming components
        List<Product> psus = productRepository.findByProductType_Name("PSU");
        psus.sort((p1, p2) -> {
            // Look for mentions of high wattage (850W or higher) in the name or description
            boolean p1HighWatt = p1.getName().contains("850W") || p1.getName().contains("1000W") || 
                              p1.getDescription().contains("850W") || p1.getDescription().contains("1000W");
            boolean p2HighWatt = p2.getName().contains("850W") || p2.getName().contains("1000W") || 
                              p2.getDescription().contains("850W") || p2.getDescription().contains("1000W");
            
            if (p1HighWatt && !p2HighWatt) return -1;
            if (!p1HighWatt && p2HighWatt) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!psus.isEmpty()) {
            standardPCBuilder.setPowerSupply(psus.get(0));
        }
        
        return this;
    }
    
    @Override
    public PCBuilder suggestWorkstationComponents() {
        // For gaming builder, we'll provide a basic implementation for workstation components
        // In a real system, this might delegate to a WorkstationPCBuilder
        return this;
    }
}