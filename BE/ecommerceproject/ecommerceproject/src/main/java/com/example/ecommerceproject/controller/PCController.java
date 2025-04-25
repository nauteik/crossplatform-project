package com.example.ecommerceproject.controller;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.pc.PC;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.service.PCService;
import com.example.ecommerceproject.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/pc")
@CrossOrigin("*")
public class PCController {
    
    private final PCService pcService;
    private final CartService cartService;
    
    @Autowired
    public PCController(PCService pcService, CartService cartService) {
        this.pcService = pcService;
        this.cartService = cartService;
    }
    
    @GetMapping("/all")
    public ResponseEntity<ApiResponse<List<PC>>> getAllPCs() {
        List<PC> pcs = pcService.getAllPCs();
        ApiResponse<List<PC>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                pcs
        );
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<PC>> getPCById(@PathVariable String id) {
        PC pc = pcService.getPCById(id);
        if (pc != null) {
            ApiResponse<PC> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    ApiStatus.SUCCESS.getMessage(),
                    pc
            );
            return ResponseEntity.ok(response);
        }
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<List<PC>>> getPCsByUserId(@PathVariable String userId) {
        List<PC> pcs = pcService.getPCsByUserId(userId);
        ApiResponse<List<PC>> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                ApiStatus.SUCCESS.getMessage(),
                pcs
        );
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/custom")
    public ResponseEntity<ApiResponse<PC>> buildCustomPC(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        String userId = (String) request.get("userId");
        @SuppressWarnings("unchecked")
        Map<String, String> componentIds = (Map<String, String>) request.get("components");
        
        PC pc = pcService.buildCustomPC(name, userId, componentIds);
        
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Custom PC build created successfully",
                pc
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PostMapping("/gaming")
    public ResponseEntity<ApiResponse<PC>> buildGamingPC(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        String userId = (String) request.get("userId");
        @SuppressWarnings("unchecked")
        Map<String, String> customComponentIds = (Map<String, String>) request.get("customComponents");
        
        PC pc = pcService.buildGamingPC(name, userId, customComponentIds);
        
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Gaming PC build created successfully",
                pc
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PostMapping("/workstation")
    public ResponseEntity<ApiResponse<PC>> buildWorkstationPC(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        String userId = (String) request.get("userId");
        @SuppressWarnings("unchecked")
        Map<String, String> customComponentIds = (Map<String, String>) request.get("customComponents");
        
        PC pc = pcService.buildWorkstationPC(name, userId, customComponentIds);
        
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Workstation PC build created successfully",
                pc
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PostMapping("/budget")
    public ResponseEntity<ApiResponse<PC>> buildBudgetPC(@RequestBody Map<String, Object> request) {
        String name = (String) request.get("name");
        String userId = (String) request.get("userId");
        
        PC pc = pcService.buildBudgetPC(name, userId);
        
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "Budget PC build created successfully",
                pc
        );
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<PC>> updatePC(@PathVariable String id, @RequestBody Map<String, String> componentUpdates) {
        PC updatedPC = pcService.updatePC(id, componentUpdates);
        
        if (updatedPC != null) {
            ApiResponse<PC> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "PC build updated successfully",
                    updatedPC
            );
            return ResponseEntity.ok(response);
        }
        
        ApiResponse<PC> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deletePC(@PathVariable String id) {
        PC pc = pcService.getPCById(id);
        
        if (pc != null) {
            pcService.deletePC(id);
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "PC build deleted successfully"
            );
            return ResponseEntity.ok(response);
        }
        
        ApiResponse<Void> response = new ApiResponse<>(
                ApiStatus.NOT_FOUND.getCode(),
                ApiStatus.NOT_FOUND.getMessage()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    
    @PostMapping("/{id}/add-to-cart")
    public ResponseEntity<ApiResponse<Void>> addPCComponentsToCart(
            @PathVariable String id, 
            @RequestBody Map<String, String> request) {
        String userId = request.get("userId");
        
        if (userId == null || userId.isEmpty()) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.BAD_REQUEST.getCode(),
                    "User ID is required"
            );
            return ResponseEntity.badRequest().body(response);
        }
        
        try {
            // Get the PC build by ID
            PC pc = pcService.getPCById(id);
            
            if (pc == null) {
                ApiResponse<Void> response = new ApiResponse<>(
                        ApiStatus.NOT_FOUND.getCode(),
                        "PC build not found"
                );
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }
            
            // Add all components to the cart
            pcService.addPCComponentsToCart(pc, userId);
            
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SUCCESS.getCode(),
                    "PC components added to cart successfully"
            );
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>(
                    ApiStatus.SERVER_ERROR.getCode(),
                    "Error adding PC components to cart: " + e.getMessage()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}