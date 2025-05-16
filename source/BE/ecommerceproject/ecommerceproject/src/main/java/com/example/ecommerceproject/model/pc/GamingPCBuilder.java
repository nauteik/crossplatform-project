package com.example.ecommerceproject.model.pc;

import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class GamingPCBuilder implements PCBuilder {
    private final ProductRepository productRepository;
    private PC pc;
    
    @Autowired
    public GamingPCBuilder(ProductRepository productRepository) {
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
            name = "Gaming PC Build";
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
        }
        
        if (pc.getMotherboard() == null) {
            pc.getCompatibilityNotes().put("motherboard", "Motherboard is required");
            isComplete = false;
        }
        
        if (pc.getRam() == null) {
            pc.getCompatibilityNotes().put("ram", "RAM is required");
            isComplete = false;
        }
        
        if (pc.getStorage() == null) {
            pc.getCompatibilityNotes().put("storage", "Storage is required");
            isComplete = false;
        }
        
        if (pc.getPowerSupply() == null) {
            pc.getCompatibilityNotes().put("powerSupply", "Power Supply is required");
            isComplete = false;
        }
        
        // Kiểm tra đặc biệt cho Gaming PC: bắt buộc phải có GPU
        if (pc.getGpu() == null) {
            pc.getCompatibilityNotes().put("gpu", "GPU is required for a Gaming PC");
            isComplete = false;
        } else {
            // Kiểm tra xem GPU có đủ mạnh cho gaming không
            double gpuPrice = pc.getGpu().getPrice();
            if (gpuPrice < 200) {
                pc.getCompatibilityNotes().put("gpu_performance", 
                    "Selected GPU may not provide optimal gaming performance");
            }
        }
        
        // KIỂM TRA TƯƠNG THÍCH CPU và Motherboard
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
                // Nếu không thể xác định loại socket, thêm cảnh báo
                pc.getCompatibilityNotes().put("cpu_motherboard_warning", 
                    "Unable to verify CPU and motherboard socket compatibility. Please verify manually.");
            }
            
            // Kiểm tra tương thích chipset cho gaming
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
        
        // Kiểm tra tương thích RAM và Motherboard
        if (pc.getRam() != null && pc.getMotherboard() != null) {
            String ramType = pc.getRam().getRamType();
            String motherboardRamType = pc.getMotherboard().getRamType();
            
            if (ramType != null && motherboardRamType != null && !ramType.equals(motherboardRamType)) {
                pc.getCompatibilityNotes().put("ram_motherboard", 
                    "RAM type (" + ramType + ") is not compatible with motherboard supported memory type (" + motherboardRamType + ")");
                isCompatible = false;
            }
        }
        
        // Kiểm tra tương thích case và motherboard form factor
        if (pc.getPcCase() != null && pc.getMotherboard() != null) {
            String caseSpec = pc.getPcCase().getDescription().toLowerCase();
            String motherboardSpec = pc.getMotherboard().getDescription().toLowerCase();
            
            boolean atxSupported = caseSpec.contains("atx");
            boolean microAtxSupported = caseSpec.contains("micro-atx") || caseSpec.contains("matx");
            boolean miniItxSupported = caseSpec.contains("mini-itx") || caseSpec.contains("itx");
            
            boolean isAtxMotherboard = motherboardSpec.contains("atx") && !motherboardSpec.contains("micro") && !motherboardSpec.contains("mini");
            boolean isMicroAtxMotherboard = motherboardSpec.contains("micro-atx") || motherboardSpec.contains("matx");
            boolean isMiniItxMotherboard = motherboardSpec.contains("mini-itx") || motherboardSpec.contains("itx");
            
            boolean formFactorCompatible = 
                (isAtxMotherboard && atxSupported) ||
                (isMicroAtxMotherboard && (microAtxSupported || atxSupported)) ||
                (isMiniItxMotherboard && (miniItxSupported || microAtxSupported || atxSupported));
                
            if (!formFactorCompatible) {
                pc.getCompatibilityNotes().put("case_motherboard", 
                    "Motherboard form factor may not be compatible with the selected case");
                isCompatible = false;
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
    public void suggestGamingComponents() {
        // Tìm GPU cao cấp (giả định giá cao = hiệu suất tốt hơn cho gaming)
        List<Product> gpus = productRepository.findByProductType_Name("GPU");
        gpus.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice())); // Sắp xếp theo giá giảm dần
        if (!gpus.isEmpty()) {
            setGpu(gpus.get(0)); // Chọn GPU đắt nhất
        }
        
        // Tìm CPU cao cấp
        List<Product> cpus = productRepository.findByProductType_Name("CPU");
        cpus.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice())); // Sắp xếp theo giá giảm dần
        if (!cpus.isEmpty()) {
            setCpu(cpus.get(0)); // Chọn CPU đắt nhất
        }
        
        // Tìm RAM dung lượng cao
        List<Product> rams = productRepository.findByProductType_Name("RAM");
        rams.sort((p1, p2) -> {
            // Tìm RAM có đề cập đến 32GB trong tên hoặc mô tả
            boolean p1Has32GB = p1.getName().contains("32GB") || p1.getDescription().contains("32GB");
            boolean p2Has32GB = p2.getName().contains("32GB") || p2.getDescription().contains("32GB");
            
            if (p1Has32GB && !p2Has32GB) return -1;
            if (!p1Has32GB && p2Has32GB) return 1;
            
            // Nếu cả hai hoặc không có RAM 32GB, sắp xếp theo giá
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!rams.isEmpty()) {
            setRam(rams.get(0));
        }
        
        // Đề xuất SSD để tải game nhanh hơn
        List<Product> storages = productRepository.findByProductType_Name("SSD");
        if (!storages.isEmpty()) {
            // Tìm cân bằng giữa giá và dung lượng
            storages.sort((p1, p2) -> Double.compare(p2.getPrice(), p1.getPrice()));
            
            if (storages.size() > 2) {
                // Chọn một tùy chọn tầm trung nếu có
                setStorage(storages.get(1));
            } else {
                setStorage(storages.get(0));
            }
        }
        
        // Nguồn công suất cao cho linh kiện gaming
        List<Product> psus = productRepository.findByProductType_Name("PSU");
        psus.sort((p1, p2) -> {
            // Tìm nguồn có công suất cao (850W trở lên) trong tên hoặc mô tả
            boolean p1HighWatt = p1.getName().contains("850W") || p1.getName().contains("1000W") || 
                              p1.getDescription().contains("850W") || p1.getDescription().contains("1000W");
            boolean p2HighWatt = p2.getName().contains("850W") || p2.getName().contains("1000W") || 
                              p2.getDescription().contains("850W") || p2.getDescription().contains("1000W");
            
            if (p1HighWatt && !p2HighWatt) return -1;
            if (!p1HighWatt && p2HighWatt) return 1;
            
            return Double.compare(p2.getPrice(), p1.getPrice());
        });
        
        if (!psus.isEmpty()) {
            setPowerSupply(psus.get(0));
        }
    }
    
    @Override
    public void suggestWorkstationComponents() {
        // Với GamingPCBuilder, vẫn ưu tiên theo tiêu chí gaming
        suggestGamingComponents();
    }
}