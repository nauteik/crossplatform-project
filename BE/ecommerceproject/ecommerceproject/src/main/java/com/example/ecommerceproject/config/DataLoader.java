package com.example.ecommerceproject.config;

import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.repository.BrandRepository;
import com.example.ecommerceproject.repository.CartRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.ProductTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Component
public class DataLoader implements CommandLineRunner {

    private final BrandRepository brandRepository;
    private final ProductTypeRepository productTypeRepository;
    private final ProductRepository productRepository;

    @Autowired
    public DataLoader(BrandRepository brandRepository, ProductTypeRepository productTypeRepository, ProductRepository productRepository) {
        this.brandRepository = brandRepository;
        this.productTypeRepository = productTypeRepository;
        this.productRepository = productRepository;
    }

    @Override
    public void run(String... args) throws Exception {
        // Kiểm tra nếu đã có dữ liệu
        if (productRepository.count() > 0) {
            System.out.println("Dữ liệu đã được khởi tạo trước đó, bỏ qua quá trình khởi tạo dữ liệu");
            return;
        }

        // Tạo Brands (Thương hiệu)
        List<Brand> brands = createBrands();
        
        // Tạo Product Types (Loại sản phẩm)
        List<ProductType> productTypes = createProductTypes();
        
        // Tạo Products (Sản phẩm)
        createProducts(brands, productTypes);
        
        System.out.println("Đã khởi tạo dữ liệu thành công!");
    }

    private List<Brand> createBrands() {
        List<String> brandNames = Arrays.asList(
            "ASUS", "MSI", "Gigabyte", "Intel", "AMD", "NVIDIA", 
            "Corsair", "Kingston", "Western Digital", "Seagate", 
            "Samsung", "G.Skill", "EVGA", "Cooler Master", "Thermaltake"
        );
        
        List<Brand> brands = new ArrayList<>();
        
        for (String name : brandNames) {
            Brand brand = new Brand();
            brand.setName(name);
            brands.add(brandRepository.save(brand));
        }
        
        return brands;
    }

    private List<ProductType> createProductTypes() {
        List<String> typeNames = Arrays.asList(
            "CPU", "GPU", "Mainboard", "RAM", "SSD", "HDD", 
            "PSU", "Case", "Cooling", "Monitor", "Peripherals"
        );
        
        List<ProductType> productTypes = new ArrayList<>();
        
        for (String name : typeNames) {
            ProductType type = new ProductType();
            type.setName(name);
            productTypes.add(productTypeRepository.save(type));
        }
        
        return productTypes;
    }

    private void createProducts(List<Brand> brands, List<ProductType> productTypes) {
        // Lấy các ProductType theo tên để dễ sử dụng
        ProductType cpuType = productTypeRepository.findByName("CPU");
        ProductType gpuType = productTypeRepository.findByName("GPU");
        ProductType mainboardType = productTypeRepository.findByName("Mainboard");
        ProductType ramType = productTypeRepository.findByName("RAM");
        ProductType ssdType = productTypeRepository.findByName("SSD");
        ProductType hddType = productTypeRepository.findByName("HDD");
        ProductType psuType = productTypeRepository.findByName("PSU");
        ProductType caseType = productTypeRepository.findByName("Case");
        
        // Lấy các Brand theo tên để dễ sử dụng
        Brand intel = brandRepository.findByName("Intel");
        Brand amd = brandRepository.findByName("AMD");
        Brand nvidia = brandRepository.findByName("NVIDIA");
        Brand asus = brandRepository.findByName("ASUS");
        Brand msi = brandRepository.findByName("MSI");
        Brand gigabyte = brandRepository.findByName("Gigabyte");
        Brand corsair = brandRepository.findByName("Corsair");
        Brand kingston = brandRepository.findByName("Kingston");
        Brand samsung = brandRepository.findByName("Samsung");
        Brand seagate = brandRepository.findByName("Seagate");
        Brand wDigital = brandRepository.findByName("Western Digital");
        Brand gskill = brandRepository.findByName("G.Skill");
        Brand thermaltake = brandRepository.findByName("Thermaltake");
        Brand coolerMaster = brandRepository.findByName("Cooler Master");
        Brand evga = brandRepository.findByName("EVGA");
        
        // Danh sách sản phẩm CPU
        List<Product> cpuProducts = Arrays.asList(
            createProduct("Intel Core i9-14900K", 15990000, 50, 
                "CPU Intel Core i9-14900K (3.20GHz up to 6.00GHz, 36MB Cache, 24 Cores, 32 Threads)", 
                "https://product.hstatic.net/1000026716/product/w990pro_1668b557c2b54ed7a27d70a3beabf1ff.png", 145, 5.0, intel, cpuType),
            
            createProduct("AMD Ryzen 9 7950X", 14990000, 45, 
                "CPU AMD Ryzen 9 7950X (4.5GHz up to 5.7GHz, 64MB Cache, 16 Cores, 32 Threads)", 
                "https://product.hstatic.net/1000370129/product/amd_ryzen_9_7950x_b25a4fa3cc064abcabca2f9630f6fc82_master.jpg", 123, 10.0, amd, cpuType),
                
            createProduct("Intel Core i7-14700K", 10990000, 70, 
                "CPU Intel Core i7-14700K (3.40GHz up to 5.60GHz, 33MB Cache, 20 Cores, 28 Threads)", 
                "https://product.hstatic.net/1000026716/product/hhm1_9c0621ac37894f3d8d273d452c0071a4.jpg", 167, 7.0, intel, cpuType),
                
            createProduct("AMD Ryzen 7 7800X3D", 9990000, 55, 
                "CPU AMD Ryzen 7 7800X3D (4.2GHz up to 5.0GHz, 96MB Cache, 8 Cores, 16 Threads)", 
                "https://product.hstatic.net/1000370129/product/amd_ryzen_7_7800x3d_1_f07f0a9d9cc04c54abed9d2ac1b6e3ca_master.jpg", 201, 8.0, amd, cpuType),
                
            createProduct("Intel Core i5-14600K", 8990000, 65, 
                "CPU Intel Core i5-14600K (3.50GHz up to 5.30GHz, 24MB Cache, 14 Cores, 20 Threads)", 
                "https://product.hstatic.net/1000026716/product/intel_core_i5_14600k_0af0d5e87c6c46a5baa8f462c9a57cc7.jpg", 183, 6.0, intel, cpuType),
                
            createProduct("AMD Ryzen 5 7600X", 6990000, 75, 
                "CPU AMD Ryzen 5 7600X (4.7GHz up to 5.3GHz, 32MB Cache, 6 Cores, 12 Threads)", 
                "https://product.hstatic.net/1000370129/product/amd_ryzen_5_7600x_f3edb18c93464cd69a9c4c95bfca54b1_master.jpg", 210, 12.0, amd, cpuType),
                
            createProduct("Intel Core i3-14100", 3990000, 80, 
                "CPU Intel Core i3-14100 (3.50GHz up to 4.70GHz, 12MB Cache, 4 Cores, 8 Threads)", 
                "https://product.hstatic.net/1000026716/product/gearvn-intel-core-i3-14100-1_e8e0ec95bb5a4c54b31f2ebfa2b93a6b.jpg", 155, 15.0, intel, cpuType)
        );
        
        // Danh sách sản phẩm GPU
        List<Product> gpuProducts = Arrays.asList(
            createProduct("ASUS ROG Strix GeForce RTX 4090 OC", 45990000, 20, 
                "Card màn hình ASUS ROG Strix GeForce RTX 4090 OC Edition 24GB GDDR6X", 
                "https://product.hstatic.net/1000026716/product/gearvn-card-man-hinh-asus-rog-strix-rtx-4090-oc-white-edition-24gb-gddr6x-1_0f953c3c6c094ab693a4c435a7e93145.png", 89, 5.0, asus, gpuType),
                
            createProduct("MSI GeForce RTX 4080 SUPER GAMING X TRIO", 31990000, 25, 
                "Card màn hình MSI GeForce RTX 4080 SUPER GAMING X TRIO 16GB GDDR6X", 
                "https://product.hstatic.net/1000026716/product/msi_geforce_rtx_4080_super_gaming_x_trio_16g_gearvn_f173b4b595fb453f8e5c510ebb31ed9a.jpg", 112, 8.0, msi, gpuType),
                
            createProduct("GIGABYTE Radeon RX 7900 XTX GAMING OC", 26990000, 30, 
                "Card màn hình GIGABYTE Radeon RX 7900 XTX GAMING OC 24G", 
                "https://product.hstatic.net/1000026716/product/1-1_539f72e5eed84a6ba1bcec8e440e8d93.jpg", 98, 10.0, gigabyte, gpuType),
                
            createProduct("ASUS TUF Gaming Radeon RX 7800 XT OC", 16990000, 40, 
                "Card màn hình ASUS TUF Gaming Radeon RX 7800 XT OC Edition 16GB GDDR6", 
                "https://product.hstatic.net/1000026716/product/asus_rx7800xt_e56da2f26e0245fab5ada4c0f66adc53.png", 145, 12.0, asus, gpuType),
                
            createProduct("NVIDIA GeForce RTX 4070 Founders Edition", 18990000, 35, 
                "Card màn hình NVIDIA GeForce RTX 4070 Founders Edition 12GB GDDR6X", 
                "https://www.nvidia.com/content/dam/en-zz/Solutions/geforce/ada/rtx-4070/geforce-rtx-4070-product-gallery-full-screen-3840-3.jpg", 105, 6.0, nvidia, gpuType),
                
            createProduct("NVIDIA GeForce RTX 4060 Ti Founders Edition", 12990000, 45, 
                "Card màn hình NVIDIA GeForce RTX 4060 Ti Founders Edition 8GB GDDR6", 
                "https://www.nvidia.com/content/dam/en-zz/Solutions/geforce/ada/rtx-4060-4060ti/geforce-ada-4060-ti-product-gallery-full-screen-3840-2.jpg", 133, 8.0, nvidia, gpuType),
                
            createProduct("EVGA GeForce RTX 3080 FTW3 ULTRA", 22990000, 22, 
                "Card màn hình EVGA GeForce RTX 3080 FTW3 ULTRA GAMING 10GB GDDR6X", 
                "https://m.media-amazon.com/images/I/81-d9eH7nXL.jpg", 95, 15.0, evga, gpuType),
                
            createProduct("MSI Radeon RX 6700 XT GAMING X", 11990000, 38, 
                "Card màn hình MSI Radeon RX 6700 XT GAMING X 12GB GDDR6", 
                "https://storage-asset.msi.com/global/picture/image/feature/vga/AMD/RX6700XT/RX6700XT-GAMING-X-12G-1000.png", 128, 10.0, msi, gpuType)
        );
        
        // Danh sách sản phẩm Mainboard
        List<Product> mainboardProducts = Arrays.asList(
            createProduct("ASUS ROG MAXIMUS Z790 HERO", 14990000, 30, 
                "Bo mạch chủ ASUS ROG MAXIMUS Z790 HERO (LGA1700)", 
                "https://product.hstatic.net/1000026716/product/marus_6a08ef37f9264b4e9b3d8d1451a45d65.png", 67, 6.0, asus, mainboardType),
                
            createProduct("MSI MPG X670E CARBON WIFI", 10990000, 35, 
                "Bo mạch chủ MSI MPG X670E CARBON WIFI (AM5)", 
                "https://product.hstatic.net/1000026716/product/x670e-carbon-wifi003_c94ce659ed68481994ecee5c67b91da2_50d83a8037334c598de78af20cc266d6.png", 82, 8.0, msi, mainboardType),
                
            createProduct("GIGABYTE B760 AORUS ELITE AX", 5990000, 50, 
                "Bo mạch chủ GIGABYTE B760 AORUS ELITE AX (LGA1700)", 
                "https://product.hstatic.net/1000026716/product/gigabyte_b760_aorus_elite_ax_ddr4_01_ff1de7c6eebf41daa09a4d69facf1ae4.jpg", 125, 15.0, gigabyte, mainboardType),
                
            createProduct("ASUS ROG STRIX B650E-F GAMING WIFI", 7990000, 40, 
                "Bo mạch chủ ASUS ROG STRIX B650E-F GAMING WIFI (AM5)", 
                "https://product.hstatic.net/1000026716/product/1_af47f61afd71477fa9f2abe51dedb17e.png", 91, 7.0, asus, mainboardType),
                
            createProduct("MSI MAG B650 TOMAHAWK WIFI", 6490000, 45, 
                "Bo mạch chủ MSI MAG B650 TOMAHAWK WIFI (AM5)", 
                "https://product.hstatic.net/1000026716/product/gearvn-msi-mag-b650-tomahawk-wifi-1_c3b62a7c39314c9393d7caa7adb2b54f.png", 110, 12.0, msi, mainboardType),
                
            createProduct("GIGABYTE Z790 AORUS MASTER", 12990000, 25, 
                "Bo mạch chủ GIGABYTE Z790 AORUS MASTER (LGA1700)", 
                "https://www.gigabyte.com/FileUpload/Global/KeyFeature/2232/innergigabyteimages/mb.png", 55, 10.0, gigabyte, mainboardType)
        );
        
        // Danh sách sản phẩm RAM
        List<Product> ramProducts = Arrays.asList(
            createProduct("G.Skill Trident Z5 RGB 32GB (2x16GB) DDR5 6000MHz", 4990000, 60, 
                "Bộ nhớ RAM G.Skill Trident Z5 RGB 32GB (2x16GB) DDR5 6000MHz CL30", 
                "https://product.hstatic.net/1000026716/product/4_2ee3bc2aaa4041eabb1a740e318a66b2.jpg", 178, 10.0, gskill, ramType),
                
            createProduct("Corsair Vengeance RGB 32GB (2x16GB) DDR5 5600MHz", 3990000, 70, 
                "Bộ nhớ RAM Corsair Vengeance RGB 32GB (2x16GB) DDR5 5600MHz", 
                "https://product.hstatic.net/1000026716/product/corsair_vengeance_rgb_ddr5_3dd51ff5ddf04c0a881e0d81af7c957b.jpg", 201, 12.0, corsair, ramType),
                
            createProduct("Kingston FURY Beast 16GB (2x8GB) DDR4 3200MHz", 1690000, 80, 
                "Bộ nhớ RAM Kingston FURY Beast 16GB (2x8GB) DDR4 3200MHz", 
                "https://product.hstatic.net/1000026716/product/hx-product-memory-beast-ddr4-rgb-blk-1-zm-lg_b9d2efb77e7249ad9d3a0d2aafdc9abb.jpg", 245, 15.0, kingston, ramType),
                
            createProduct("G.Skill Ripjaws S5 64GB (2x32GB) DDR5 5200MHz", 7990000, 35, 
                "Bộ nhớ RAM G.Skill Ripjaws S5 64GB (2x32GB) DDR5 5200MHz", 
                "https://m.media-amazon.com/images/I/614Z+xsGCDL.jpg", 85, 7.0, gskill, ramType),
                
            createProduct("Corsair Dominator Platinum RGB 32GB (2x16GB) DDR5 6200MHz", 5690000, 40, 
                "Bộ nhớ RAM Corsair Dominator Platinum RGB 32GB (2x16GB) DDR5 6200MHz", 
                "https://m.media-amazon.com/images/I/61H2YhQJJ8L.jpg", 115, 8.0, corsair, ramType),
                
            createProduct("Kingston FURY Renegade RGB 32GB (2x16GB) DDR4 3600MHz", 3290000, 65, 
                "Bộ nhớ RAM Kingston FURY Renegade RGB 32GB (2x16GB) DDR4 3600MHz", 
                "https://media.kingston.com/kingston/hero/ktc-hero-memory-fury-renegade-rgb-ddr4-1-lg.jpg", 135, 12.0, kingston, ramType)
        );
        
        // Danh sách sản phẩm SSD
        List<Product> ssdProducts = Arrays.asList(
            createProduct("Samsung 990 PRO NVMe SSD 2TB", 5990000, 50, 
                "Ổ cứng SSD Samsung 990 PRO 2TB NVMe M.2 PCIe Gen 4", 
                "https://product.hstatic.net/1000026716/product/990pro_heatsink_perspective_front_20221019_33423e52e0bc431990c6deb386a008fb.png", 156, 8.0, samsung, ssdType),
                
            createProduct("WD Black SN850X NVMe SSD 1TB", 3490000, 60, 
                "Ổ cứng SSD WD Black SN850X 1TB NVMe M.2 PCIe Gen 4", 
                "https://product.hstatic.net/1000026716/product/wd_black_sn850x_nvme_ssd_1tb_5b1caf10f4cb43bc9dff30c0bd0fcf17.png", 189, 10.0, wDigital, ssdType),
                
            createProduct("Kingston KC3000 NVMe SSD 2TB", 4990000, 40, 
                "Ổ cứng SSD Kingston KC3000 2TB NVMe M.2 PCIe Gen 4", 
                "https://product.hstatic.net/1000026716/product/bn_eac52a31a9de4b9c8d9a8fefd2927d55.png", 134, 12.0, kingston, ssdType),
                
            createProduct("Samsung 870 EVO SATA SSD 1TB", 2490000, 65, 
                "Ổ cứng SSD Samsung 870 EVO SATA 1TB", 
                "https://images.samsung.com/is/image/samsung/p6pim/vn/mz-77e1t0bw/gallery/vn-870-evo-sata-3-2-5-inch-internal-ssd-mz-77e1t0bw-531866598?$650_519_PNG$", 175, 10.0, samsung, ssdType),
                
            createProduct("WD Blue SN580 NVMe SSD 1TB", 2190000, 70, 
                "Ổ cứng SSD WD Blue SN580 1TB NVMe M.2 PCIe Gen 4", 
                "https://m.media-amazon.com/images/I/71JBr1O9vTL.jpg", 165, 15.0, wDigital, ssdType),
                
            createProduct("Kingston NV2 NVMe SSD 2TB", 3590000, 55, 
                "Ổ cứng SSD Kingston NV2 2TB NVMe M.2 PCIe Gen 4", 
                "https://m.media-amazon.com/images/I/61a86o6cUML.jpg", 128, 12.0, kingston, ssdType)
        );
        
        // Danh sách sản phẩm HDD
        List<Product> hddProducts = Arrays.asList(
            createProduct("Seagate Barracuda 4TB", 2790000, 80, 
                "Ổ cứng HDD Seagate Barracuda 4TB 5400rpm, SATA 6Gb/s, 256MB Cache", 
                "https://product.hstatic.net/1000026716/product/0d00befe57a64cf194330647d5d7f34a_e7aaee4c7d2b4a5ea6bf4ea28cb02a15.jpg", 210, 7.0, seagate, hddType),
                
            createProduct("Western Digital Blue 2TB", 1590000, 90, 
                "Ổ cứng HDD Western Digital Blue 2TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                "https://product.hstatic.net/1000026716/product/wdblue_1_a89d3d1b9b8a4e4eba009f0ac7e2f7cf.png", 256, 10.0, wDigital, hddType),
                
            createProduct("Seagate IronWolf Pro 8TB", 6490000, 45, 
                "Ổ cứng HDD Seagate IronWolf Pro 8TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                "https://product.hstatic.net/1000026716/product/10_8ee1e8ee4aff4cf49143e5612f9b4b8a.png", 78, 5.0, seagate, hddType),
                
            createProduct("Western Digital Black 4TB", 3990000, 55, 
                "Ổ cứng HDD Western Digital Black 4TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                "https://m.media-amazon.com/images/I/71nMNj+WGGL.jpg", 95, 8.0, wDigital, hddType),
                
            createProduct("Seagate Exos 16TB", 9990000, 20, 
                "Ổ cứng HDD Seagate Exos X16 16TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                "https://m.media-amazon.com/images/I/71Y88RnMjoL.jpg", 45, 3.0, seagate, hddType)
        );
        
        // Danh sách sản phẩm PSU
        List<Product> psuProducts = Arrays.asList(
            createProduct("Corsair RM1000x 1000W 80 Plus Gold", 4990000, 40, 
                "Nguồn máy tính Corsair RM1000x 1000W 80 Plus Gold - Full Modular", 
                "https://product.hstatic.net/1000026716/product/rm__72c47cb03fb646fdb9d866d7b6f18b4b.png", 98, 5.0, corsair, psuType),
                
            createProduct("ASUS ROG Thor 850W 80 Plus Platinum", 5990000, 30, 
                "Nguồn máy tính ASUS ROG Thor 850W 80 Plus Platinum - Full Modular", 
                "https://product.hstatic.net/1000026716/product/gearvn-asus-rog-thor-850p-3_c2a59c3d7a454d9988a272445db3c85c.jpg", 76, 8.0, asus, psuType),
                
            createProduct("Corsair HX1200 1200W 80 Plus Platinum", 6990000, 25, 
                "Nguồn máy tính Corsair HX1200 1200W 80 Plus Platinum - Full Modular", 
                "https://m.media-amazon.com/images/I/71Lrps+5sML.jpg", 45, 7.0, corsair, psuType),
                
            createProduct("EVGA SuperNOVA 850 G6 850W 80 Plus Gold", 3990000, 35, 
                "Nguồn máy tính EVGA SuperNOVA 850 G6 850W 80 Plus Gold - Full Modular", 
                "https://m.media-amazon.com/images/I/71PFY+7Y+JL.jpg", 87, 10.0, evga, psuType),
                
            createProduct("Thermaltake Toughpower GF3 1000W 80 Plus Gold", 4690000, 30, 
                "Nguồn máy tính Thermaltake Toughpower GF3 1000W 80 Plus Gold - Full Modular", 
                "https://thermaltake.azureedge.net/pub/media/catalog/product/cache/3a440e7c11fac528bb91024e9e5851e4/t/o/toughpower_gf3_argb_gold_psu_01.jpg", 65, 12.0, thermaltake, psuType),
                
            createProduct("MSI MPG A1000G PCIE5 1000W 80 Plus Gold", 5290000, 28, 
                "Nguồn máy tính MSI MPG A1000G PCIE5 1000W 80 Plus Gold - Full Modular", 
                "https://storage-asset.msi.com/global/picture/image/feature/power/MPG-PSU/A1000G-PCIE5/msi-mpg-a1000g-pcie5-psu-1000.png", 54, 6.0, msi, psuType)
        );
        
        // Danh sách sản phẩm Case
        List<Product> caseProducts = Arrays.asList(
            createProduct("Corsair 7000D AIRFLOW", 6990000, 25, 
                "Vỏ case Corsair 7000D AIRFLOW Full Tower", 
                "https://product.hstatic.net/1000026716/product/1-11_6fc204d5d5ce4e5694d6075135f4d0f2.jpg", 45, 10.0, corsair, caseType),
                
            createProduct("NZXT H7 Flow", 3990000, 35, 
                "Vỏ case NZXT H7 Flow Mid Tower", 
                "https://product.hstatic.net/1000026716/product/nzxt_h7_black_1_9d2a0f3eb77c46c490ce96c5e0d35c93.jpg", 87, 8.0, thermaltake, caseType),
                
            createProduct("Cooler Master MasterBox TD500 Mesh", 2490000, 50, 
                "Vỏ case Cooler Master MasterBox TD500 Mesh Mid Tower", 
                "https://product.hstatic.net/1000026716/product/masterbox-td500-mesh-white-1_c7d2b3b2bb484e8db6a17f2fe0b26f64.jpg", 124, 12.0, coolerMaster, caseType),
                
            createProduct("Lian Li PC-O11 Dynamic EVO", 4990000, 30, 
                "Vỏ case Lian Li PC-O11 Dynamic EVO Mid Tower", 
                "https://m.media-amazon.com/images/I/617jOVaCQLL.jpg", 95, 5.0, msi, caseType),
                
            createProduct("Corsair iCUE 5000X RGB", 5490000, 28, 
                "Vỏ case Corsair iCUE 5000X RGB Mid Tower", 
                "https://www.corsair.com/medias/sys_master/images/images/h80/hba/9676388261918/base-5000x-rgb-config/Gallery/5000X_RGB_BLACK_01/-base-5000x-rgb-config-Gallery-5000X-RGB-BLACK-01.png_1200Wx1200H", 78, 7.0, corsair, caseType),
                
            createProduct("Thermaltake View 51 TG ARGB", 4290000, 32, 
                "Vỏ case Thermaltake View 51 TG ARGB Full Tower", 
                "https://thermaltake.azureedge.net/pub/media/catalog/product/cache/25e62158742be0ef47d2055284094406/v/i/view51tgargb_composition.jpg", 63, 10.0, thermaltake, caseType),
                
            createProduct("ASUS ROG Strix Helios", 7990000, 20, 
                "Vỏ case ASUS ROG Strix Helios Full Tower", 
                "https://dlcdnwebimgs.asus.com/gain/53328FFB-95A4-45DE-A0C0-0F71ED252667/w800", 42, 15.0, asus, caseType)
        );
        
        // Gộp tất cả các sản phẩm lại và lưu vào database
        List<Product> allProducts = new ArrayList<>();
        allProducts.addAll(cpuProducts);
        allProducts.addAll(gpuProducts);
        allProducts.addAll(mainboardProducts);
        allProducts.addAll(ramProducts);
        allProducts.addAll(ssdProducts);
        allProducts.addAll(hddProducts);
        allProducts.addAll(psuProducts);
        allProducts.addAll(caseProducts);
        
        productRepository.saveAll(allProducts);
    }
    
    private Product createProduct(String name, double price, int quantity, String description, 
                                String imageUrl, int soldCount, double discountPercent, 
                                Brand brand, ProductType productType) {
        Product product = new Product();
        product.setName(name);
        product.setPrice(price);
        product.setQuantity(quantity);
        product.setDescription(description);
        product.setImageUrl(imageUrl);
        product.setSoldCount(soldCount);
        product.setDiscountPercent(discountPercent);
        product.setBrand(brand);
        product.setProductType(productType);
        return product;
    }
} 