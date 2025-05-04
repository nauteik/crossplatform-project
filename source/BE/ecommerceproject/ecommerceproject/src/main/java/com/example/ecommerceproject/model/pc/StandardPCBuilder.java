package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import org.springframework.stereotype.Component;

@Component
public class StandardPCBuilder implements PCBuilder {
    private PC pc;
    public StandardPCBuilder() {
        this.reset();
    }
    @Override
    public void reset() {
        this.pc = new PC();
    }
    @Override
    public void setName(String name) {
        this.pc.setName(name);
    }
    @Override
    public void setUserId(String userId) {
        this.pc.setUserId(userId);
    }
    @Override
    public void setCpu(Product cpu) {
        this.pc.setCpu(cpu);
    }
    @Override
    public void setMotherboard(Product motherboard) {
        this.pc.setMotherboard(motherboard);
    }
    @Override
    public void setGpu(Product gpu) {
        this.pc.setGpu(gpu);
    }
    @Override
    public void setRam(Product ram) {
        this.pc.setRam(ram);
    }
    @Override
    public void setStorage(Product storage) {
        this.pc.setStorage(storage);
    }
    @Override
    public void setPowerSupply(Product powerSupply) {
        this.pc.setPowerSupply(powerSupply);
    }
    @Override
    public void setPcCase(Product pcCase) {
        this.pc.setPcCase(pcCase);
    }
    @Override
    public void setCooling(Product cooling) {
        this.pc.setCooling(cooling);
    }
    @Override
    public void validateCompatibility() {
        boolean isCompatible = true;
        // Calculate total price
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
        if (pc.getCpu() == null) {
            pc.getCompatibilityNotes().put("cpu", "CPU is required");
            isCompatible = false;
        }
        if (pc.getMotherboard() == null) {
            pc.getCompatibilityNotes().put("motherboard", "Motherboard is required");
            isCompatible = false;
        }
        if (pc.getRam() == null) {
            pc.getCompatibilityNotes().put("ram", "RAM is required");
            isCompatible = false;
        }
        if (pc.getStorage() == null) {
            pc.getCompatibilityNotes().put("storage", "Storage is required");
            isCompatible = false;
        }
        if (pc.getPowerSupply() == null) {
            pc.getCompatibilityNotes().put("powerSupply", "Power Supply is required");
            isCompatible = false;
        }
        // IMPROVED CPU and Motherboard socket compatibility check
        if (pc.getCpu() != null && pc.getMotherboard() != null) {
            String cpuSocketType = pc.getCpu().getSocketType();
            String motherboardSocketType = pc.getMotherboard().getSocketType();
            
            if (cpuSocketType != null && motherboardSocketType != null) {
                if (!cpuSocketType.equals(motherboardSocketType)) {
                    pc.getCompatibilityNotes().put("cpu_motherboard", 
                        "CPU socket (" + cpuSocketType + ") is not compatible with motherboard socket (" + motherboardSocketType + ")");
                    isCompatible = false;
                }
            } else {
                // If we couldn't determine socket types, add a warning
                pc.getCompatibilityNotes().put("cpu_motherboard_warning", 
                    "Unable to verify CPU and motherboard socket compatibility. Please verify manually.");
            }
            
            // Check if the CPU brand matches with motherboard chipset (simplified)
            String cpuBrand = pc.getCpu().getBrand() != null ? pc.getCpu().getBrand().getName() : null;
            String chipset = pc.getMotherboard().getChipset();
            
            if (cpuBrand != null && chipset != null) {
                boolean compatibleChipset = false;
                
                if (cpuBrand.equalsIgnoreCase("Intel") && (
                    chipset.startsWith("Z") || chipset.startsWith("B") || chipset.startsWith("H"))) {
                    compatibleChipset = true;
                } else if (cpuBrand.equalsIgnoreCase("AMD") && (
                    chipset.startsWith("X") || chipset.startsWith("B"))) {
                    compatibleChipset = true;
                }
                
                if (!compatibleChipset) {
                    pc.getCompatibilityNotes().put("cpu_chipset", 
                        "CPU brand (" + cpuBrand + ") may not be compatible with motherboard chipset (" + chipset + ")");
                    isCompatible = false;
                }
            }
        }
        
        // Check RAM and Motherboard compatibility
        if (pc.getRam() != null && pc.getMotherboard() != null) {
            String ramType = pc.getRam().getRamType();
            String motherboardRamType = pc.getMotherboard().getRamType();
            
            if (ramType != null && motherboardRamType != null && !ramType.equals(motherboardRamType)) {
                pc.getCompatibilityNotes().put("ram_motherboard", 
                    "RAM type (" + ramType + ") is not compatible with motherboard supported memory type (" + motherboardRamType + ")");
                isCompatible = false;
            }
        }
        
        // Check case and motherboard form factor compatibility (simplified)
        if (pc.getPcCase() != null && pc.getMotherboard() != null) {
            String caseSpec = pc.getPcCase().getDescription().toLowerCase();
            String motherboardSpec = pc.getMotherboard().getDescription().toLowerCase();
            
            // Common form factors
            boolean atxSupported = caseSpec.contains("atx");
            boolean microAtxSupported = caseSpec.contains("micro-atx") || caseSpec.contains("matx");
            boolean miniItxSupported = caseSpec.contains("mini-itx") || caseSpec.contains("itx");
            
            boolean isAtxMotherboard = motherboardSpec.contains("atx") && !motherboardSpec.contains("micro") && !motherboardSpec.contains("mini");
            boolean isMicroAtxMotherboard = motherboardSpec.contains("micro-atx") || motherboardSpec.contains("matx");
            boolean isMiniItxMotherboard = motherboardSpec.contains("mini-itx") || motherboardSpec.contains("itx");
            
            boolean formFactorCompatible = 
                (isAtxMotherboard && atxSupported) ||
                (isMicroAtxMotherboard && (microAtxSupported || atxSupported)) ||  // ATX cases support micro-ATX
                (isMiniItxMotherboard && (miniItxSupported || microAtxSupported || atxSupported));  // Larger cases support smaller mobos
                
            if (!formFactorCompatible) {
                pc.getCompatibilityNotes().put("case_motherboard", 
                    "Motherboard form factor may not be compatible with the selected case");
                isCompatible = false;
            }
        }
        
        // Determine if the build is complete
        boolean isComplete = pc.getCpu() != null && pc.getMotherboard() != null && 
                            pc.getRam() != null && pc.getStorage() != null && 
                            pc.getPowerSupply() != null;
        
        pc.setComplete(isComplete);
        
        if (!isComplete) {
            pc.setBuildStatus("incomplete");
        } else if (isCompatible) {
            pc.setBuildStatus("compatible");
        } else {
            pc.setBuildStatus("incompatible");
        }
    }
    
    @Override
    public PC build() {
        PC result = this.pc;
        this.reset();
        return result;
    }

    @Override
    public void suggestWorkstationComponents() {
      
    }

    @Override
    public void suggestGamingComponents() {
        
    }
}