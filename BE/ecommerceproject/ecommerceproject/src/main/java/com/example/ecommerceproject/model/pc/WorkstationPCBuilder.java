package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class WorkstationPCBuilder implements PCBuilder {
    private final StandardPCBuilder standardPCBuilder;
    private final ProductRepository productRepository;
    
    @Autowired
    public WorkstationPCBuilder(StandardPCBuilder standardPCBuilder, ProductRepository productRepository) {
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
            name = "Workstation PC Build";
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
    
    // Special method to suggest workstation optimized components
    @Override
    public PCBuilder suggestWorkstationComponents() {
        // Find high-core-count CPU (prioritize AMD Ryzen 9 or Intel Core i9)
        List<Product> cpus = productRepository.findByProductType_Name("CPU");
        cpus.sort((p1, p2) -> {
            // Prioritize CPUs with "Ryzen 9" or "Core i9" in the name
            boolean p1IsHighCore = p1.getName().contains("Ryzen 9") || p1.getName().contains("Core i9");
            boolean p2IsHighCore = p2.getName().contains("Ryzen 9") || p2.getName().contains("Core i9");
            
            if (p1IsHighCore && !p2IsHighCore) return -1;
            if (!p1IsHighCore && p2IsHighCore) return 1;
            
            // If both or neither are high-core, sort by price
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!cpus.isEmpty()) {
            standardPCBuilder.setCpu(cpus.get(0)); // Select the highest core count CPU
        }
        
        // Find large amount of RAM for workstation tasks
        List<Product> rams = productRepository.findByProductType_Name("RAM");
        rams.sort((p1, p2) -> {
            // Look for mentions of 64GB in the name or description
            boolean p1Has64GB = p1.getName().contains("64GB") || p1.getDescription().contains("64GB");
            boolean p2Has64GB = p2.getName().contains("64GB") || p2.getDescription().contains("64GB");
            
            // 64GB RAM is preferred for workstations
            if (p1Has64GB && !p2Has64GB) return -1;
            if (!p1Has64GB && p2Has64GB) return 1;
            
            // Then check for 32GB
            boolean p1Has32GB = p1.getName().contains("32GB") || p1.getDescription().contains("32GB");
            boolean p2Has32GB = p2.getName().contains("32GB") || p2.getDescription().contains("32GB");
            
            if (p1Has32GB && !p2Has32GB) return -1;
            if (!p1Has32GB && p2Has32GB) return 1;
            
            // If both or neither have 32GB or 64GB, sort by price
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!rams.isEmpty()) {
            standardPCBuilder.setRam(rams.get(0));
        }
        
        // For workstations, prioritize storage capacity
        List<Product> ssds = productRepository.findByProductType_Name("SSD");
        ssds.sort((p1, p2) -> {
            // Look for mentions of 2TB in the name or description
            boolean p1Has2TB = p1.getName().contains("2TB") || p1.getDescription().contains("2TB");
            boolean p2Has2TB = p2.getName().contains("2TB") || p2.getDescription().contains("2TB");
            
            if (p1Has2TB && !p2Has2TB) return -1;
            if (!p1Has2TB && p2Has2TB) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!ssds.isEmpty()) {
            standardPCBuilder.setStorage(ssds.get(0));
        }
        
        // For workstations, we prefer reliable GPUs
        List<Product> gpus = productRepository.findByProductType_Name("GPU");
        gpus.sort((p1, p2) -> {
            String p1Name = p1.getName().toLowerCase();
            String p2Name = p2.getName().toLowerCase();
            
            // Prioritize workstation GPUs (like Quadro or Radeon Pro)
            boolean p1IsWorkstation = p1Name.contains("quadro") || p1Name.contains("radeon pro");
            boolean p2IsWorkstation = p2Name.contains("quadro") || p2Name.contains("radeon pro");
            
            if (p1IsWorkstation && !p2IsWorkstation) return -1;
            if (!p1IsWorkstation && p2IsWorkstation) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!gpus.isEmpty()) {
            // For demo purposes, choose from available GPUs
            standardPCBuilder.setGpu(gpus.get(0));
        }
        
        // Reliable power supply for 24/7 operation
        List<Product> psus = productRepository.findByProductType_Name("PSU");
        psus.sort((p1, p2) -> {
            // Look for mentions of platinum or gold certification in the name or description
            boolean p1IsHighCert = p1.getName().toLowerCase().contains("platinum") || 
                                p1.getDescription().toLowerCase().contains("platinum");
            boolean p2IsHighCert = p2.getName().toLowerCase().contains("platinum") || 
                                p2.getDescription().toLowerCase().contains("platinum");
            
            if (p1IsHighCert && !p2IsHighCert) return -1;
            if (!p1IsHighCert && p2IsHighCert) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!psus.isEmpty()) {
            standardPCBuilder.setPowerSupply(psus.get(0));
        }
        
        return this;
    }
    
    @Override
    public PCBuilder suggestGamingComponents() {
        // For workstation builder, we'll provide a basic implementation for gaming components
        // In a real system, this might delegate to a GamingPCBuilder
        return this;
    }
}