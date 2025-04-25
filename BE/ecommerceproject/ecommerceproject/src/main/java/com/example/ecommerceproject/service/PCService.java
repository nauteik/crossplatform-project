package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.CartItem;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.pc.PC;
import com.example.ecommerceproject.model.pc.PCDirector;
import com.example.ecommerceproject.repository.PCRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class PCService {
    
    private final PCRepository pcRepository;
    private final ProductRepository productRepository;
    private final PCDirector pcDirector;
    private final CartService cartService;
    
    @Autowired
    public PCService(PCRepository pcRepository, ProductRepository productRepository, PCDirector pcDirector, CartService cartService) {
        this.pcRepository = pcRepository;
        this.productRepository = productRepository;
        this.pcDirector = pcDirector;
        this.cartService = cartService;
    }
    
    public List<PC> getAllPCs() {
        return pcRepository.findAll();
    }
    
    public PC getPCById(String id) {
        return pcRepository.findById(id).orElse(null);
    }
    
    public List<PC> getPCsByUserId(String userId) {
        return pcRepository.findByUserId(userId);
    }
    
    public PC savePC(PC pc) {
        return pcRepository.save(pc);
    }
    
    public void deletePC(String id) {
        pcRepository.deleteById(id);
    }
    
    public PC buildCustomPC(String name, String userId, Map<String, String> componentIds) {
        // Convert component IDs to actual Product objects
        Map<String, Product> components = new HashMap<>();
        
        for (Map.Entry<String, String> entry : componentIds.entrySet()) {
            Optional<Product> product = productRepository.findById(entry.getValue());
            product.ifPresent(p -> components.put(entry.getKey(), p));
        }
        
        // Use the PCDirector to build the custom PC
        PC pc = pcDirector.buildCustomPC(name, userId, components);
        
        // Save and return the PC
        return pcRepository.save(pc);
    }
    
    public PC buildGamingPC(String name, String userId, Map<String, String> customComponentIds) {
        // Convert any custom component IDs to actual Product objects
        Map<String, Product> customComponents = new HashMap<>();
        
        if (customComponentIds != null) {
            for (Map.Entry<String, String> entry : customComponentIds.entrySet()) {
                Optional<Product> product = productRepository.findById(entry.getValue());
                product.ifPresent(p -> customComponents.put(entry.getKey(), p));
            }
        }
        
        // Use the PCDirector to build a gaming PC
        PC pc = pcDirector.buildGamingPC(name, userId, customComponents);
        
        // Save and return the PC
        return pcRepository.save(pc);
    }
    
    public PC buildWorkstationPC(String name, String userId, Map<String, String> customComponentIds) {
        // Convert any custom component IDs to actual Product objects
        Map<String, Product> customComponents = new HashMap<>();
        
        if (customComponentIds != null) {
            for (Map.Entry<String, String> entry : customComponentIds.entrySet()) {
                Optional<Product> product = productRepository.findById(entry.getValue());
                product.ifPresent(p -> customComponents.put(entry.getKey(), p));
            }
        }
        
        // Use the PCDirector to build a workstation PC
        PC pc = pcDirector.buildWorkstationPC(name, userId, customComponents);
        
        // Save and return the PC
        return pcRepository.save(pc);
    }
    
    public PC buildBudgetPC(String name, String userId) {
        // Use the PCDirector to build a budget PC
        PC pc = pcDirector.buildBudgetPC(name, userId);
        
        // Save and return the PC
        return pcRepository.save(pc);
    }
    
    public PC updatePC(String id, Map<String, String> componentUpdates) {
        Optional<PC> optionalPC = pcRepository.findById(id);
        
        if (optionalPC.isEmpty()) {
            return null;
        }
        
        PC pc = optionalPC.get();
        boolean changed = false;
        
        // Update components based on provided componentUpdates
        if (componentUpdates.containsKey("cpu")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("cpu"));
            if (product.isPresent()) {
                pc.setCpu(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("motherboard")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("motherboard"));
            if (product.isPresent()) {
                pc.setMotherboard(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("gpu")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("gpu"));
            if (product.isPresent()) {
                pc.setGpu(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("ram")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("ram"));
            if (product.isPresent()) {
                pc.setRam(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("storage")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("storage"));
            if (product.isPresent()) {
                pc.setStorage(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("powerSupply")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("powerSupply"));
            if (product.isPresent()) {
                pc.setPowerSupply(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("pcCase")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("pcCase"));
            if (product.isPresent()) {
                pc.setPcCase(product.get());
                changed = true;
            }
        }
        
        if (componentUpdates.containsKey("cooling")) {
            Optional<Product> product = productRepository.findById(componentUpdates.get("cooling"));
            if (product.isPresent()) {
                pc.setCooling(product.get());
                changed = true;
            }
        }
        
        if (changed) {
            // Recalculate total price and compatibility
            double totalPrice = 0;
            if (pc.getCpu() != null) totalPrice += pc.getCpu().getPrice();
            if (pc.getMotherboard() != null) totalPrice += pc.getMotherboard().getPrice();
            if (pc.getGpu() != null) totalPrice += pc.getGpu().getPrice();
            if (pc.getRam() != null) totalPrice += pc.getRam().getPrice();
            if (pc.getStorage() != null) totalPrice += pc.getStorage().getPrice();
            if (pc.getPowerSupply() != null) totalPrice += pc.getPowerSupply().getPrice();
            if (pc.getPcCase() != null) totalPrice += pc.getPcCase().getPrice();
            if (pc.getCooling() != null) totalPrice += pc.getCooling().getPrice();
            
            pc.setTotalPrice(totalPrice);
            
            // For simplicity, we're not redoing the full compatibility check here.
            // In a real application, you would use the builder to revalidate compatibility.
            pc.getCompatibilityNotes().clear();
            pc.setBuildStatus("updated_pending_validation");
            
            return pcRepository.save(pc);
        }
        
        return pc;
    }
    
    /**
     * Add all components of a PC build to the user's cart
     * 
     * @param pc The PC build containing components to add to the cart
     * @param userId The ID of the user who owns the cart
     */
    public void addPCComponentsToCart(PC pc, String userId) {
        // Add each component to the cart with quantity 1
        addComponentToCart(pc.getCpu(), userId);
        addComponentToCart(pc.getMotherboard(), userId);
        addComponentToCart(pc.getRam(), userId);
        addComponentToCart(pc.getStorage(), userId);
        addComponentToCart(pc.getPowerSupply(), userId);
        
        // Optional components
        addComponentToCart(pc.getGpu(), userId);
        addComponentToCart(pc.getPcCase(), userId);
        addComponentToCart(pc.getCooling(), userId);
    }
    
    /**
     * Helper method to add a single component to the cart
     * 
     * @param product The product to add to the cart
     * @param userId The ID of the user who owns the cart
     */
    private void addComponentToCart(Product product, String userId) {
        if (product == null) return;
        
        CartItem cartItem = new CartItem();
        cartItem.setProductId(product.getId());
        cartItem.setProductName(product.getName());
        cartItem.setQuantity(1);
        cartItem.setPrice(product.getPrice());
        cartItem.setImageUrl(product.getPrimaryImageUrl());
        
        cartService.addItemToCart(userId, cartItem);
    }
}