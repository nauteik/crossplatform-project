package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class WorkstationPCBuilder implements PCBuilder {
    private final ProductRepository productRepository;
    private PC pc;
    
    @Autowired
    public WorkstationPCBuilder(ProductRepository productRepository) {
        this.productRepository = productRepository;
        this.reset();
    }
    
    @Override
    public void reset() {
        this.pc = new PC();
    }
    
    @Override
    public void setName(String name) {
        if (name == null || name.isEmpty()) {
            name = "Workstation PC Build";
        }
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
        boolean isComplete = true;
        
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
        
        // Kiểm tra các thành phần bắt buộc
        pc.getCompatibilityNotes().clear();
        
        if (pc.getCpu() == null) {
            pc.getCompatibilityNotes().put("cpu", "CPU is required");
            isComplete = false;
        } else {
            // Kiểm tra CPU đặc thù cho máy trạm
            String cpuName = pc.getCpu().getName().toLowerCase();
            String cpuDesc = pc.getCpu().getDescription().toLowerCase();
            
            boolean isHighCore = cpuName.contains("ryzen 9") || 
                                 cpuName.contains("core i9") ||
                                 cpuName.contains("threadripper") ||
                                 cpuDesc.contains("ryzen 9") ||
                                 cpuDesc.contains("core i9") ||
                                 cpuDesc.contains("threadripper");
            
            if (!isHighCore) {
                pc.getCompatibilityNotes().put("cpu_performance", 
                    "Selected CPU may not provide optimal workstation performance. Consider a high-core CPU like Ryzen 9 or Core i9.");
            }
        }
        
        if (pc.getMotherboard() == null) {
            pc.getCompatibilityNotes().put("motherboard", "Motherboard is required");
            isComplete = false;
        }
        
        if (pc.getRam() == null) {
            pc.getCompatibilityNotes().put("ram", "RAM is required");
            isComplete = false;
        } else {
            // Kiểm tra RAM đủ lớn cho máy trạm
            String ramName = pc.getRam().getName().toLowerCase();
            String ramDesc = pc.getRam().getDescription().toLowerCase();
            
            boolean hasEnoughRAM = ramName.contains("32gb") || 
                                   ramName.contains("64gb") || 
                                   ramDesc.contains("32gb") ||
                                   ramDesc.contains("64gb");
            
            if (!hasEnoughRAM) {
                pc.getCompatibilityNotes().put("ram_capacity", 
                    "Selected RAM may have insufficient capacity for intensive workstation tasks. Consider 32GB or more.");
            }
        }
        
        if (pc.getStorage() == null) {
            pc.getCompatibilityNotes().put("storage", "Storage is required");
            isComplete = false;
        } else {
            // Kiểm tra dung lượng lưu trữ cho máy trạm
            String storageName = pc.getStorage().getName().toLowerCase();
            String storageDesc = pc.getStorage().getDescription().toLowerCase();
            
            boolean hasEnoughStorage = storageName.contains("2tb") || 
                                      storageName.contains("4tb") || 
                                      storageDesc.contains("2tb") ||
                                      storageDesc.contains("4tb");
            
            if (!hasEnoughStorage) {
                pc.getCompatibilityNotes().put("storage_capacity", 
                    "Selected storage may have insufficient capacity for workstation tasks. Consider 2TB or more.");
            }
        }
        
        if (pc.getPowerSupply() == null) {
            pc.getCompatibilityNotes().put("powerSupply", "Power Supply is required");
            isComplete = false;
        }
        
        // Kiểm tra tương thích CPU và Motherboard
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
                pc.getCompatibilityNotes().put("cpu_motherboard_warning", 
                    "Unable to verify CPU and motherboard socket compatibility. Please verify manually.");
            }
            
            // Kiểm tra chipset cho máy trạm
            String cpuBrand = pc.getCpu().getBrand() != null ? pc.getCpu().getBrand().getName() : null;
            String chipset = pc.getMotherboard().getChipset();
            
            if (cpuBrand != null && chipset != null) {
                boolean compatibleChipset = false;
                
                // Cho workstation, ưu tiên chipset cao cấp hơn
                if (cpuBrand.equalsIgnoreCase("Intel") && (
                    chipset.startsWith("X") || chipset.startsWith("Z"))) {
                    compatibleChipset = true;
                } else if (cpuBrand.equalsIgnoreCase("AMD") && (
                    chipset.startsWith("X") || chipset.contains("TRX"))) {
                    compatibleChipset = true;
                }
                
                if (!compatibleChipset) {
                    pc.getCompatibilityNotes().put("cpu_chipset", 
                        "CPU brand (" + cpuBrand + ") may not be optimal with motherboard chipset (" + chipset + ") for workstation use");
                }
            }
        }
        
        // Kiểm tra tương thích RAM và Motherboard
        if (pc.getRam() != null && pc.getMotherboard() != null) {
            String ramType = pc.getRam().getRamType();
            String motherboardRamType = pc.getMotherboard().getRamType();
            
            if (ramType != null && motherboardRamType != null && !ramType.equals(motherboardRamType)) {
                pc.getCompatibilityNotes().put("ram_motherboard", 
                    "RAM type (" + ramType + ") is not compatible with motherboard supported memory type (" + motherboardRamType + ")");
                isCompatible = false;
            }
            
            // Kiểm tra ECC RAM cho máy trạm (giả sử tên/mô tả có chứa "ECC")
            String ramName = pc.getRam().getName().toLowerCase();
            String ramDesc = pc.getRam().getDescription().toLowerCase();
            String motherboardDesc = pc.getMotherboard().getDescription().toLowerCase();
            
            boolean isEccRam = ramName.contains("ecc") || ramDesc.contains("ecc");
            boolean supportEcc = motherboardDesc.contains("ecc");
            
            if (isEccRam && !supportEcc) {
                pc.getCompatibilityNotes().put("ecc_support", 
                    "ECC RAM selected but motherboard may not support ECC memory");
            }
        }
        
        pc.setComplete(isComplete);
        
        // Thiết lập trạng thái build dựa trên tính đầy đủ và tương thích
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
        // Tìm CPU nhiều nhân (ưu tiên AMD Ryzen 9 hoặc Intel Core i9)
        List<Product> cpus = productRepository.findByProductType_Name("CPU");
        cpus.sort((p1, p2) -> {
            // Ưu tiên CPU có "Ryzen 9", "Threadripper" hoặc "Core i9" trong tên
            boolean p1IsHighCore = p1.getName().contains("Ryzen 9") || p1.getName().contains("Threadripper") || p1.getName().contains("Core i9");
            boolean p2IsHighCore = p2.getName().contains("Ryzen 9") || p2.getName().contains("Threadripper") || p2.getName().contains("Core i9");
            
            if (p1IsHighCore && !p2IsHighCore) return -1;
            if (!p1IsHighCore && p2IsHighCore) return 1;
            
            // Nếu cả hai hoặc không có core cao, sắp xếp theo giá
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!cpus.isEmpty()) {
            setCpu(cpus.get(0)); // Chọn CPU nhiều nhân nhất
        }
        
        // Tìm RAM dung lượng lớn cho công việc máy trạm
        List<Product> rams = productRepository.findByProductType_Name("RAM");
        rams.sort((p1, p2) -> {
            // Tìm RAM 64GB
            boolean p1Has64GB = p1.getName().contains("64GB") || p1.getDescription().contains("64GB");
            boolean p2Has64GB = p2.getName().contains("64GB") || p2.getDescription().contains("64GB");
            
            // RAM 64GB được ưu tiên cho máy trạm
            if (p1Has64GB && !p2Has64GB) return -1;
            if (!p1Has64GB && p2Has64GB) return 1;
            
            // Sau đó kiểm tra 32GB
            boolean p1Has32GB = p1.getName().contains("32GB") || p1.getDescription().contains("32GB");
            boolean p2Has32GB = p2.getName().contains("32GB") || p2.getDescription().contains("32GB");
            
            if (p1Has32GB && !p2Has32GB) return -1;
            if (!p1Has32GB && p2Has32GB) return 1;
            
            // Nếu cả hai hoặc không có RAM 32GB/64GB, sắp xếp theo giá
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!rams.isEmpty()) {
            setRam(rams.get(0));
        }
        
        // Đối với máy trạm, ưu tiên dung lượng lưu trữ
        List<Product> ssds = productRepository.findByProductType_Name("SSD");
        ssds.sort((p1, p2) -> {
            // Tìm SSD 2TB trong tên hoặc mô tả
            boolean p1Has2TB = p1.getName().contains("2TB") || p1.getDescription().contains("2TB");
            boolean p2Has2TB = p2.getName().contains("2TB") || p2.getDescription().contains("2TB");
            
            if (p1Has2TB && !p2Has2TB) return -1;
            if (!p1Has2TB && p2Has2TB) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!ssds.isEmpty()) {
            setStorage(ssds.get(0));
        }
        
        // Đối với máy trạm, ưu tiên GPU chuyên dụng
        List<Product> gpus = productRepository.findByProductType_Name("GPU");
        gpus.sort((p1, p2) -> {
            String p1Name = p1.getName().toLowerCase();
            String p2Name = p2.getName().toLowerCase();
            
            // Ưu tiên GPU cho máy trạm (như Quadro, RTX A-series hoặc Radeon Pro)
            boolean p1IsWorkstation = p1Name.contains("quadro") || p1Name.contains("rtx a") || p1Name.contains("radeon pro");
            boolean p2IsWorkstation = p2Name.contains("quadro") || p2Name.contains("rtx a") || p2Name.contains("radeon pro");
            
            if (p1IsWorkstation && !p2IsWorkstation) return -1;
            if (!p1IsWorkstation && p2IsWorkstation) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!gpus.isEmpty()) {
            setGpu(gpus.get(0));
        }
        
        // Nguồn điện đáng tin cậy cho hoạt động 24/7
        List<Product> psus = productRepository.findByProductType_Name("PSU");
        psus.sort((p1, p2) -> {
            // Tìm nguồn có chứng nhận platinum hoặc gold trong tên hoặc mô tả
            boolean p1IsHighCert = p1.getName().toLowerCase().contains("platinum") || 
                                p1.getDescription().toLowerCase().contains("platinum") ||
                                p1.getName().toLowerCase().contains("titanium") || 
                                p1.getDescription().toLowerCase().contains("titanium");
            boolean p2IsHighCert = p2.getName().toLowerCase().contains("platinum") || 
                                p2.getDescription().toLowerCase().contains("platinum") ||
                                p2.getName().toLowerCase().contains("titanium") || 
                                p2.getDescription().toLowerCase().contains("titanium");
            
            if (p1IsHighCert && !p2IsHighCert) return -1;
            if (!p1IsHighCert && p2IsHighCert) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!psus.isEmpty()) {
            setPowerSupply(psus.get(0));
        }
        
        // Tìm mainboard phù hợp cho workstation
        List<Product> motherboards = productRepository.findByProductType_Name("Motherboard");
        motherboards.sort((p1, p2) -> {
            String p1Desc = p1.getDescription().toLowerCase();
            String p2Desc = p2.getDescription().toLowerCase();
            
            // Ưu tiên mainboard hỗ trợ ECC và nhiều khe RAM
            boolean p1SupportsEcc = p1Desc.contains("ecc");
            boolean p2SupportsEcc = p2Desc.contains("ecc");
            
            if (p1SupportsEcc && !p2SupportsEcc) return -1;
            if (!p1SupportsEcc && p2SupportsEcc) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!motherboards.isEmpty()) {
            setMotherboard(motherboards.get(0));
        }
    }
    
    @Override
    public void suggestGamingComponents() {
        // Với WorkstationPCBuilder, vẫn ưu tiên theo tiêu chí workstation
        suggestWorkstationComponents();
    }
}