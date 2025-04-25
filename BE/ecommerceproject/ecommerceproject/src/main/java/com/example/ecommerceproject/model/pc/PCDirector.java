package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class PCDirector {
    private final StandardPCBuilder standardPCBuilder;
    private final GamingPCBuilder gamingPCBuilder;
    private final WorkstationPCBuilder workstationPCBuilder;
    
    @Autowired
    public PCDirector(StandardPCBuilder standardPCBuilder, 
                     GamingPCBuilder gamingPCBuilder,
                     WorkstationPCBuilder workstationPCBuilder) {
        this.standardPCBuilder = standardPCBuilder;
        this.gamingPCBuilder = gamingPCBuilder;
        this.workstationPCBuilder = workstationPCBuilder;
    }
    
    /**
     * Build a PC from the components specified in the request
     */
    public PC buildCustomPC(String name, String userId, Map<String, Product> components) {
        PCBuilder builder = standardPCBuilder.reset()
            .setName(name)
            .setUserId(userId);
        
        if (components.containsKey("cpu")) {
            builder.setCpu(components.get("cpu"));
        }
        
        if (components.containsKey("motherboard")) {
            builder.setMotherboard(components.get("motherboard"));
        }
        
        if (components.containsKey("gpu")) {
            builder.setGpu(components.get("gpu"));
        }
        
        if (components.containsKey("ram")) {
            builder.setRam(components.get("ram"));
        }
        
        if (components.containsKey("storage")) {
            builder.setStorage(components.get("storage"));
        }
        
        if (components.containsKey("powerSupply")) {
            builder.setPowerSupply(components.get("powerSupply"));
        }
        
        if (components.containsKey("pcCase")) {
            builder.setPcCase(components.get("pcCase"));
        }
        
        if (components.containsKey("cooling")) {
            builder.setCooling(components.get("cooling"));
        }
        
        return builder.validateCompatibility().build();
    }
    
    /**
     * Build a PC with gaming-optimized components
     */
    public PC buildGamingPC(String name, String userId, Map<String, Product> customComponents) {
        // Start with suggested gaming components
        gamingPCBuilder.reset()
            .setName(name)
            .setUserId(userId)
            .suggestGamingComponents();
        
        // Override with any custom components the user specified
        if (customComponents != null) {
            if (customComponents.containsKey("cpu")) {
                gamingPCBuilder.setCpu(customComponents.get("cpu"));
            }
            
            if (customComponents.containsKey("motherboard")) {
                gamingPCBuilder.setMotherboard(customComponents.get("motherboard"));
            }
            
            if (customComponents.containsKey("gpu")) {
                gamingPCBuilder.setGpu(customComponents.get("gpu"));
            }
            
            if (customComponents.containsKey("ram")) {
                gamingPCBuilder.setRam(customComponents.get("ram"));
            }
            
            if (customComponents.containsKey("storage")) {
                gamingPCBuilder.setStorage(customComponents.get("storage"));
            }
            
            if (customComponents.containsKey("powerSupply")) {
                gamingPCBuilder.setPowerSupply(customComponents.get("powerSupply"));
            }
            
            if (customComponents.containsKey("pcCase")) {
                gamingPCBuilder.setPcCase(customComponents.get("pcCase"));
            }
            
            if (customComponents.containsKey("cooling")) {
                gamingPCBuilder.setCooling(customComponents.get("cooling"));
            }
        }
        
        return gamingPCBuilder.validateCompatibility().build();
    }
    
    /**
     * Build a PC with workstation-optimized components
     */
    public PC buildWorkstationPC(String name, String userId, Map<String, Product> customComponents) {
        // Start with suggested workstation components
        workstationPCBuilder.reset()
            .setName(name)
            .setUserId(userId)
            .suggestWorkstationComponents();
        
        // Override with any custom components the user specified
        if (customComponents != null) {
            if (customComponents.containsKey("cpu")) {
                workstationPCBuilder.setCpu(customComponents.get("cpu"));
            }
            
            if (customComponents.containsKey("motherboard")) {
                workstationPCBuilder.setMotherboard(customComponents.get("motherboard"));
            }
            
            if (customComponents.containsKey("gpu")) {
                workstationPCBuilder.setGpu(customComponents.get("gpu"));
            }
            
            if (customComponents.containsKey("ram")) {
                workstationPCBuilder.setRam(customComponents.get("ram"));
            }
            
            if (customComponents.containsKey("storage")) {
                workstationPCBuilder.setStorage(customComponents.get("storage"));
            }
            
            if (customComponents.containsKey("powerSupply")) {
                workstationPCBuilder.setPowerSupply(customComponents.get("powerSupply"));
            }
            
            if (customComponents.containsKey("pcCase")) {
                workstationPCBuilder.setPcCase(customComponents.get("pcCase"));
            }
            
            if (customComponents.containsKey("cooling")) {
                workstationPCBuilder.setCooling(customComponents.get("cooling"));
            }
        }
        
        return workstationPCBuilder.validateCompatibility().build();
    }
    
    /**
     * Build a budget PC with cost-effective components
     */
    public PC buildBudgetPC(String name, String userId) {
        // Budget PC prioritizes essential components at lower price points
        StandardPCBuilder builder = (StandardPCBuilder) standardPCBuilder.reset()
            .setName(name != null ? name : "Budget PC Build")
            .setUserId(userId);
        
        // Logic for selecting budget components would go here
        // This would typically involve querying for the lowest priced but functional components
        
        return builder.validateCompatibility().build();
    }
}