package com.example.ecommerceproject.config;

import com.example.ecommerceproject.model.*;
import com.example.ecommerceproject.repository.*;
import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.model.Cart;
import com.example.ecommerceproject.model.Order;
import com.example.ecommerceproject.model.OrderStatus;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.model.Tag;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.BrandRepository;
import com.example.ecommerceproject.repository.CartRepository;
import com.example.ecommerceproject.repository.OrderRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.ProductTypeRepository;
import com.example.ecommerceproject.repository.UserRepository;
import com.example.ecommerceproject.repository.TagRepository;
import com.example.ecommerceproject.service.AddressService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.example.ecommerceproject.model.StatusHistoryEntry;

@Component
public class DataLoader implements CommandLineRunner {

    private final BrandRepository brandRepository;
    private final ProductTypeRepository productTypeRepository;
    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final TagRepository tagRepository;
    private final PasswordEncoder passwordEncoder;
    private final CouponRepository couponRepository;
    private final AddressService addressService;
    private final OrderRepository orderRepository;

    @Autowired
    public DataLoader(BrandRepository brandRepository, ProductTypeRepository productTypeRepository, 
                      ProductRepository productRepository, UserRepository userRepository, 
                      CartRepository cartRepository, TagRepository tagRepository, 
                      PasswordEncoder passwordEncoder, CouponRepository couponRepository,
                      AddressService addressService, OrderRepository orderRepository) {
        this.brandRepository = brandRepository;
        this.productTypeRepository = productTypeRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.cartRepository = cartRepository;
        this.tagRepository = tagRepository;
        this.passwordEncoder = passwordEncoder;
        this.couponRepository = couponRepository;
        this.addressService = addressService;
        this.orderRepository = orderRepository;
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
        
        // Tạo Tags
        List<Tag> tags = createTags();
        
        // Tạo Products (Sản phẩm)
        List<Product> products = createProducts(brands, productTypes);

        // Gắn tags cho sản phẩm
        assignTagsToProducts(products, tags);
        
        // Tạo Users và Carts
        createUsersAndCarts();

        // Tạo Coupons
        createCoupons();
        
        // Tạo Orders
        createOrders(products);

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
            type.setImage(name.toLowerCase() + ".png");
            productTypes.add(productTypeRepository.save(type));
        }
        
        return productTypes;
    }

    private List<Tag> createTags() {
        List<String[]> tagData = Arrays.asList(
            new String[]{"Khuyến mãi", "#FF0000", "Sản phẩm đang trong chương trình khuyến mãi"}, 
            new String[]{"Mới", "#00FF00", "Sản phẩm mới ra mắt"},
            new String[]{"Bán chạy", "#0000FF", "Sản phẩm bán chạy nhất"}
        );
        
        List<Tag> tags = new ArrayList<>();
        
        for (String[] data : tagData) {
            Tag tag = new Tag();
            tag.setName(data[0]);
            tag.setColor(data[1]);
            tag.setDescription(data[2]);
            tag.setActive(true);
            tag.setCreatedAt(LocalDateTime.now());
            tags.add(tagRepository.save(tag));
        }
        
        return tags;
    }

    private List<Product> createProducts(List<Brand> brands, List<ProductType> productTypes) {
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
                145, 5.0, intel, cpuType),
            
            createProduct("AMD Ryzen 9 7950X", 14990000, 45, 
                "CPU AMD Ryzen 9 7950X (4.5GHz up to 5.7GHz, 64MB Cache, 16 Cores, 32 Threads)", 
                123, 10.0, amd, cpuType),
                
            createProduct("Intel Core i7-14700K", 10990000, 70, 
                "CPU Intel Core i7-14700K (3.40GHz up to 5.60GHz, 33MB Cache, 20 Cores, 28 Threads)", 
                167, 7.0, intel, cpuType),
                
            createProduct("AMD Ryzen 7 7800X3D", 9990000, 55, 
                "CPU AMD Ryzen 7 7800X3D (4.2GHz up to 5.0GHz, 96MB Cache, 8 Cores, 16 Threads)", 
                201, 8.0, amd, cpuType),
                
            createProduct("Intel Core i5-14600K", 8990000, 65, 
                "CPU Intel Core i5-14600K (3.50GHz up to 5.30GHz, 24MB Cache, 14 Cores, 20 Threads)", 
                183, 6.0, intel, cpuType),
                
            createProduct("AMD Ryzen 5 7600X", 6990000, 75, 
                "CPU AMD Ryzen 5 7600X (4.7GHz up to 5.3GHz, 32MB Cache, 6 Cores, 12 Threads)", 
                210, 12.0, amd, cpuType),
                
            createProduct("Intel Core i3-14100", 3990000, 80, 
                "CPU Intel Core i3-14100 (3.50GHz up to 4.70GHz, 12MB Cache, 4 Cores, 8 Threads)", 
                155, 15.0, intel, cpuType)
        );
        
        // Danh sách sản phẩm GPU
        List<Product> gpuProducts = Arrays.asList(
            createProduct("ASUS ROG Strix GeForce RTX 4090 OC", 45990000, 20, 
                "Card màn hình ASUS ROG Strix GeForce RTX 4090 OC Edition 24GB GDDR6X", 
                89, 5.0, asus, gpuType),
                
            createProduct("MSI GeForce RTX 4080 SUPER GAMING X TRIO", 31990000, 25, 
                "Card màn hình MSI GeForce RTX 4080 SUPER GAMING X TRIO 16GB GDDR6X", 
                112, 8.0, msi, gpuType),
                
            createProduct("GIGABYTE Radeon RX 7900 XTX GAMING OC", 26990000, 30, 
                "Card màn hình GIGABYTE Radeon RX 7900 XTX GAMING OC 24G", 
                98, 10.0, gigabyte, gpuType),
                
            createProduct("ASUS TUF Gaming Radeon RX 7800 XT OC", 16990000, 40, 
                "Card màn hình ASUS TUF Gaming Radeon RX 7800 XT OC Edition 16GB GDDR6", 
                145, 12.0, asus, gpuType),
                
            createProduct("NVIDIA GeForce RTX 4070 Founders Edition", 18990000, 35, 
                "Card màn hình NVIDIA GeForce RTX 4070 Founders Edition 12GB GDDR6X", 
                105, 6.0, nvidia, gpuType),
                
            createProduct("NVIDIA GeForce RTX 4060 Ti Founders Edition", 12990000, 45, 
                "Card màn hình NVIDIA GeForce RTX 4060 Ti Founders Edition 8GB GDDR6", 
                133, 8.0, nvidia, gpuType),
                
            createProduct("EVGA GeForce RTX 3080 FTW3 ULTRA", 22990000, 22, 
                "Card màn hình EVGA GeForce RTX 3080 FTW3 ULTRA GAMING 10GB GDDR6X", 
                95, 15.0, evga, gpuType),
                
            createProduct("MSI Radeon RX 6700 XT GAMING X", 11990000, 38, 
                "Card màn hình MSI Radeon RX 6700 XT GAMING X 12GB GDDR6", 
                128, 10.0, msi, gpuType)
        );
        
        // Danh sách sản phẩm Mainboard
        List<Product> mainboardProducts = Arrays.asList(
            createProduct("ASUS ROG MAXIMUS Z790 HERO", 14990000, 30, 
                "Bo mạch chủ ASUS ROG MAXIMUS Z790 HERO (LGA1700)", 
                67, 6.0, asus, mainboardType),
                
            createProduct("MSI MPG X670E CARBON WIFI", 10990000, 35, 
                "Bo mạch chủ MSI MPG X670E CARBON WIFI (AM5)", 
                82, 8.0, msi, mainboardType),
                
            createProduct("GIGABYTE B760 AORUS ELITE AX", 5990000, 50, 
                "Bo mạch chủ GIGABYTE B760 AORUS ELITE AX (LGA1700)", 
                125, 15.0, gigabyte, mainboardType),
                
            createProduct("ASUS ROG STRIX B650E-F GAMING WIFI", 7990000, 40, 
                "Bo mạch chủ ASUS ROG STRIX B650E-F GAMING WIFI (AM5)", 
                91, 7.0, asus, mainboardType),
                
            createProduct("MSI MAG B650 TOMAHAWK WIFI", 6490000, 45, 
                "Bo mạch chủ MSI MAG B650 TOMAHAWK WIFI (AM5)", 
                110, 12.0, msi, mainboardType),
                
            createProduct("GIGABYTE Z790 AORUS MASTER", 12990000, 25, 
                "Bo mạch chủ GIGABYTE Z790 AORUS MASTER (LGA1700)", 
                55, 10.0, gigabyte, mainboardType)
        );
        
        // Danh sách sản phẩm RAM
        List<Product> ramProducts = Arrays.asList(
            createProduct("G.Skill Trident Z5 RGB 32GB (2x16GB) DDR5 6000MHz", 4990000, 60, 
                "Bộ nhớ RAM G.Skill Trident Z5 RGB 32GB (2x16GB) DDR5 6000MHz CL30", 
                178, 10.0, gskill, ramType),
                
            createProduct("Corsair Vengeance RGB 32GB (2x16GB) DDR5 5600MHz", 3990000, 70, 
                "Bộ nhớ RAM Corsair Vengeance RGB 32GB (2x16GB) DDR5 5600MHz", 
                201, 12.0, corsair, ramType),
                
            createProduct("Kingston FURY Beast 16GB (2x8GB) DDR4 3200MHz", 1690000, 80, 
                "Bộ nhớ RAM Kingston FURY Beast 16GB (2x8GB) DDR4 3200MHz", 
                245, 15.0, kingston, ramType),
                
            createProduct("G.Skill Ripjaws S5 64GB (2x32GB) DDR5 5200MHz", 7990000, 35, 
                "Bộ nhớ RAM G.Skill Ripjaws S5 64GB (2x32GB) DDR5 5200MHz", 
                85, 7.0, gskill, ramType),
                
            createProduct("Corsair Dominator Platinum RGB 32GB (2x16GB) DDR5 6200MHz", 5690000, 40, 
                "Bộ nhớ RAM Corsair Dominator Platinum RGB 32GB (2x16GB) DDR5 6200MHz", 
                115, 8.0, corsair, ramType),
                
            createProduct("Kingston FURY Renegade RGB 32GB (2x16GB) DDR4 3600MHz", 3290000, 65, 
                "Bộ nhớ RAM Kingston FURY Renegade RGB 32GB (2x16GB) DDR4 3600MHz", 
                135, 12.0, kingston, ramType)
        );
        
        // Danh sách sản phẩm SSD
        List<Product> ssdProducts = Arrays.asList(
            createProduct("Samsung 990 PRO NVMe SSD 2TB", 5990000, 50, 
                "Ổ cứng SSD Samsung 990 PRO 2TB NVMe M.2 PCIe Gen 4", 
                156, 8.0, samsung, ssdType),
                
            createProduct("WD Black SN850X NVMe SSD 1TB", 3490000, 60, 
                "Ổ cứng SSD WD Black SN850X 1TB NVMe M.2 PCIe Gen 4", 
                189, 10.0, wDigital, ssdType),
                
            createProduct("Kingston KC3000 NVMe SSD 2TB", 4990000, 40, 
                "Ổ cứng SSD Kingston KC3000 2TB NVMe M.2 PCIe Gen 4", 
                134, 12.0, kingston, ssdType),
                
            createProduct("Samsung 870 EVO SATA SSD 1TB", 2490000, 65, 
                "Ổ cứng SSD Samsung 870 EVO SATA 1TB", 
                175, 10.0, samsung, ssdType),
                
            createProduct("WD Blue SN580 NVMe SSD 1TB", 2190000, 70, 
                "Ổ cứng SSD WD Blue SN580 1TB NVMe M.2 PCIe Gen 4", 
                165, 15.0, wDigital, ssdType),
                
            createProduct("Kingston NV2 NVMe SSD 2TB", 3590000, 55, 
                "Ổ cứng SSD Kingston NV2 2TB NVMe M.2 PCIe Gen 4", 
                128, 12.0, kingston, ssdType)
        );
        
        // Danh sách sản phẩm HDD
        List<Product> hddProducts = Arrays.asList(
            createProduct("Seagate Barracuda 4TB", 2790000, 80, 
                "Ổ cứng HDD Seagate Barracuda 4TB 5400rpm, SATA 6Gb/s, 256MB Cache", 
                210, 7.0, seagate, hddType),
                
            createProduct("Western Digital Blue 2TB", 1590000, 90, 
                "Ổ cứng HDD Western Digital Blue 2TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                256, 10.0, wDigital, hddType),
                
            createProduct("Seagate IronWolf Pro 8TB", 6490000, 45, 
                "Ổ cứng HDD Seagate IronWolf Pro 8TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                78, 5.0, seagate, hddType),
                
            createProduct("Western Digital Black 4TB", 3990000, 55, 
                "Ổ cứng HDD Western Digital Black 4TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                95, 8.0, wDigital, hddType),
                
            createProduct("Seagate Exos 16TB", 9990000, 20, 
                "Ổ cứng HDD Seagate Exos X16 16TB 7200rpm, SATA 6Gb/s, 256MB Cache", 
                45, 3.0, seagate, hddType)
        );
        
        // Danh sách sản phẩm PSU
        List<Product> psuProducts = Arrays.asList(
            createProduct("Corsair RM1000x 1000W 80 Plus Gold", 4990000, 40, 
                "Nguồn máy tính Corsair RM1000x 1000W 80 Plus Gold - Full Modular", 
                98, 5.0, corsair, psuType),
                
            createProduct("ASUS ROG Thor 850W 80 Plus Platinum", 5990000, 30, 
                "Nguồn máy tính ASUS ROG Thor 850W 80 Plus Platinum - Full Modular", 
                76, 8.0, asus, psuType),
                
            createProduct("Corsair HX1200 1200W 80 Plus Platinum", 6990000, 25, 
                "Nguồn máy tính Corsair HX1200 1200W 80 Plus Platinum - Full Modular", 
                45, 7.0, corsair, psuType),
                
            createProduct("EVGA SuperNOVA 850 G6 850W 80 Plus Gold", 3990000, 35, 
                "Nguồn máy tính EVGA SuperNOVA 850 G6 850W 80 Plus Gold - Full Modular", 
                87, 10.0, evga, psuType),
                
            createProduct("Thermaltake Toughpower GF3 1000W 80 Plus Gold", 4690000, 30, 
                "Nguồn máy tính Thermaltake Toughpower GF3 1000W 80 Plus Gold - Full Modular", 
                65, 12.0, thermaltake, psuType),
                
            createProduct("MSI MPG A1000G PCIE5 1000W 80 Plus Gold", 5290000, 28, 
                "Nguồn máy tính MSI MPG A1000G PCIE5 1000W 80 Plus Gold - Full Modular", 
                54, 6.0, msi, psuType)
        );
        
        // Danh sách sản phẩm Case
        List<Product> caseProducts = Arrays.asList(
            createProduct("Corsair 7000D AIRFLOW", 6990000, 25, 
                "Vỏ case Corsair 7000D AIRFLOW Full Tower", 
                45, 10.0, corsair, caseType),
                
            createProduct("NZXT H7 Flow", 3990000, 35, 
                "Vỏ case NZXT H7 Flow Mid Tower", 
                87, 8.0, thermaltake, caseType),
                
            createProduct("Cooler Master MasterBox TD500 Mesh", 2490000, 50, 
                "Vỏ case Cooler Master MasterBox TD500 Mesh Mid Tower", 
                124, 12.0, coolerMaster, caseType),
                
            createProduct("Lian Li PC-O11 Dynamic EVO", 4990000, 30, 
                "Vỏ case Lian Li PC-O11 Dynamic EVO Mid Tower", 
                95, 5.0, msi, caseType),
                
            createProduct("Corsair iCUE 5000X RGB", 5490000, 28, 
                "Vỏ case Corsair iCUE 5000X RGB Mid Tower", 
                78, 7.0, corsair, caseType),
                
            createProduct("Thermaltake View 51 TG ARGB", 4290000, 32, 
                "Vỏ case Thermaltake View 51 TG ARGB Full Tower", 
                63, 10.0, thermaltake, caseType),
                
            createProduct("ASUS ROG Strix Helios", 7990000, 20, 
                "Vỏ case ASUS ROG Strix Helios Full Tower", 
                42, 15.0, asus, caseType)
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
        
        return allProducts;
    }
    
    private void assignTagsToProducts(List<Product> products, List<Tag> tags) {
        // Lấy các tags theo tên
        Tag promotional = tagRepository.findByName("Khuyến mãi");
        Tag newTag = tagRepository.findByName("Mới");
        Tag bestSeller = tagRepository.findByName("Bán chạy");
     
        for (Product product : products) {
            List<Tag> productTags = new ArrayList<>();
            
            // Sản phẩm có giảm giá sẽ được gắn tag Khuyến mãi
            if (product.getDiscountPercent() > 0) {
                productTags.add(promotional);
            }
            
            // Sản phẩm có soldCount cao (> 150) sẽ được gắn tag Bán chạy
            if (product.getSoldCount() > 150) {
                productTags.add(bestSeller);
            }
            
            // Một số sản phẩm ngẫu nhiên sẽ được gắn tag Mới
            if (product.getCreatedAt().isAfter(LocalDateTime.now().minusDays(30))) {
                productTags.add(newTag);
            }
            
            // Cập nhật danh sách tags cho sản phẩm
            if (!productTags.isEmpty()) {
                product.setTags(productTags);
                productRepository.save(product);
            }
        }
    }
    
    private Product createProduct(String name, double price, int quantity, String description, 
                                int soldCount, double discountPercent, 
                                Brand brand, ProductType productType) {
        Product product = new Product();
        product.setName(name);
        product.setPrice(price);
        product.setQuantity(quantity);
        product.setDescription(description);
        product.setPrimaryImageUrl("razormouse1.png");
        product.setImageUrls(List.of("razormouse2.png", "razormouse3.png", "razormouse4.png", "razormouse5.png"));
        product.setSoldCount(soldCount);
        product.setDiscountPercent(discountPercent);
        product.setBrand(brand);
        product.setProductType(productType);
        product.setTags(new ArrayList<>());
        return product;
    }

    private void createUsersAndCarts() {
        // Tạo admin user
        User admin = new User();
        admin.setEmail("admin@example.com");
        admin.setPassword(passwordEncoder.encode("admin123"));
        admin.setName("Admin");
        admin.setUsername("admin");
        admin.setRole(1); // 1 là admin
        admin.setAvatar("Chưa cập nhật");
        admin.setPhone("Chưa cập nhật");
        admin.setGender("Chưa cập nhật");
        admin.setLoyaltyPoints(0);
        admin = userRepository.save(admin);

        // Tạo user thường
        User user = new User();
        user.setEmail("user@example.com");
        user.setPassword(passwordEncoder.encode("user123"));
        user.setName("User");
        user.setUsername("user");
        user.setRole(0); // 0 là user thường
        user.setAvatar("Chưa cập nhật");
        user.setPhone("Chưa cập nhật");
        user.setGender("Chưa cập nhật");
        user.setLoyaltyPoints(0);
        user = userRepository.save(user);

        // Tạo địa chỉ cho admin
        Address adminAddress = new Address();
        adminAddress.setFullName("Admin User");
        adminAddress.setPhoneNumber("0987654321");
        adminAddress.setAddressLine("123 Đường Nguyễn Văn Linh");
        adminAddress.setCity("TP. Hồ Chí Minh");
        adminAddress.setDistrict("Quận 7");
        adminAddress.setWard("Phường Tân Phong");
        adminAddress.setDefault(true);
        addressService.addAddress(admin.getId(), adminAddress);

        // Tạo địa chỉ 1 cho user thường
        Address userAddress1 = new Address();
        userAddress1.setFullName("Nguyễn Văn A");
        userAddress1.setPhoneNumber("0123456789");
        userAddress1.setAddressLine("456 Đường Lê Văn Việt");
        userAddress1.setCity("TP. Hồ Chí Minh");
        userAddress1.setDistrict("Quận 9");
        userAddress1.setWard("Phường Hiệp Phú");
        userAddress1.setDefault(true);
        addressService.addAddress(user.getId(), userAddress1);

        // Tạo địa chỉ 2 cho user thường
        Address userAddress2 = new Address();
        userAddress2.setFullName("Nguyễn Văn A");
        userAddress2.setPhoneNumber("0123456789");
        userAddress2.setAddressLine("789 Đường Quang Trung");
        userAddress2.setCity("TP. Hồ Chí Minh");
        userAddress2.setDistrict("Quận Gò Vấp");
        userAddress2.setWard("Phường 11");
        userAddress2.setDefault(false);
        addressService.addAddress(user.getId(), userAddress2);

        // Tạo cart cho user
        Cart userCart = new Cart();
        userCart.setUserId(user.getId());
        userCart.setItems(new ArrayList<>());
        userCart.setTotalPrice(0);
        cartRepository.save(userCart);
    }

    private void createCoupons() {
        // Kiểm tra xem đã có coupon nào chưa
        if (couponRepository.count() == 0) {
            List<Coupon> coupons = new ArrayList<>();

            Coupon welcome = new Coupon();
            welcome.setCode("VIP50");
            welcome.setValue(50000);
            welcome.setMaxUses(100);
            welcome.setUsedCount(0);
            welcome.setCreationTime(LocalDateTime.now());
            welcome.setOrdersApplied(new ArrayList<>());
            coupons.add(welcome);

            Coupon summer = new Coupon();
            summer.setCode("VP100");
            summer.setValue(100000);
            summer.setMaxUses(50);
            summer.setUsedCount(0);
            summer.setCreationTime(LocalDateTime.now());
            summer.setOrdersApplied(new ArrayList<>());
            coupons.add(summer);

            Coupon holiday = new Coupon();
            holiday.setCode("HOL20");
            holiday.setValue(20000);
            holiday.setMaxUses(75);
            holiday.setUsedCount(0);
            holiday.setCreationTime(LocalDateTime.now());
            holiday.setOrdersApplied(new ArrayList<>());
            coupons.add(holiday);

            Coupon blackFriday = new Coupon();
            blackFriday.setCode("BF100");
            blackFriday.setValue(100000);
            blackFriday.setMaxUses(30);
            blackFriday.setUsedCount(0);
            blackFriday.setCreationTime(LocalDateTime.now());
            blackFriday.setOrdersApplied(new ArrayList<>());
            coupons.add(blackFriday);

            Coupon firstOrder = new Coupon();
            firstOrder.setCode("FIRST");
            firstOrder.setValue(10000);
            firstOrder.setMaxUses(10);
            firstOrder.setUsedCount(0);
            firstOrder.setCreationTime(LocalDateTime.now());
            firstOrder.setOrdersApplied(new ArrayList<>());
            coupons.add(firstOrder);

            couponRepository.saveAll(coupons);

            System.out.println("Created " + coupons.size() + " coupons successfully!");
        }
    }

    private void createOrders(List<Product> products) {
        // Lấy các user đã tạo
        User admin = userRepository.findByUsername("admin").orElseThrow(() -> new RuntimeException("Admin user not found"));
        User normalUser = userRepository.findByUsername("user").orElseThrow(() -> new RuntimeException("Normal user not found"));
        
        // Lấy địa chỉ của user
        List<Address> adminAddresses = addressService.getUserAddresses(admin.getId());
        List<Address> userAddresses = addressService.getUserAddresses(normalUser.getId());
        
        // Lấy các coupon đã tạo
        List<Coupon> coupons = couponRepository.findAll();
        
        // Tạo danh sách đơn hàng với thời gian theo thứ tự
        List<Order> orders = new ArrayList<>();
        
        // Tạo đơn hàng cho admin (3 tháng trước đến nay)
        LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
        
        // Đơn hàng 1: Admin - Đã giao hàng - 3 tháng trước
        orders.add(createOrder(
            admin.getId(),
            getRandomOrderItems(products, 2),
            adminAddresses.get(0),
            OrderStatus.DELIVERED,
            "COD",
            threeMonthsAgo,
            null,
            0,
            0
        ));
        
        // Đơn hàng 2: User - Đã giao hàng - 2 tháng trước
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 3),
            userAddresses.get(0),
            OrderStatus.DELIVERED,
            "CREDIT_CARD",
            threeMonthsAgo.plusMonths(1),
            coupons.get(0).getCode(),
            coupons.get(0).getValue(),
            0
        ));
        
        // Đơn hàng 3: User - Đang giao hàng - 2 tuần trước
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 2),
            userAddresses.get(1),
            OrderStatus.SHIPPING,
            "COD",
            LocalDateTime.now().minusWeeks(2),
            null,
            0,
            0
        ));
        
        // Đơn hàng 4: Admin - Đã thanh toán, chưa giao - 1 tuần trước
        orders.add(createOrder(
            admin.getId(),
            getRandomOrderItems(products, 4),
            adminAddresses.get(0),
            OrderStatus.PAID,
            "CREDIT_CARD",
            LocalDateTime.now().minusWeeks(1),
            coupons.get(1).getCode(),
            coupons.get(1).getValue(),
            0
        ));
        
        // Đơn hàng 5: User - Đã hủy - 5 ngày trước
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 1),
            userAddresses.get(0),
            OrderStatus.CANCELLED,
            "COD",
            LocalDateTime.now().minusDays(5),
            null,
            0,
            0
        ));
        
        // Đơn hàng 6: User - Chờ thanh toán - 3 ngày trước
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 3),
            userAddresses.get(0),
            OrderStatus.PENDING,
            "CREDIT_CARD",
            LocalDateTime.now().minusDays(3),
            coupons.get(2).getCode(),
            coupons.get(2).getValue(),
            1000
        ));
        
        // Đơn hàng 7: Admin - Đã giao hàng - 2 ngày trước
        orders.add(createOrder(
            admin.getId(),
            getRandomOrderItems(products, 2),
            adminAddresses.get(0),
            OrderStatus.DELIVERED,
            "CREDIT_CARD",
            LocalDateTime.now().minusDays(2),
            null,
            0,
            2000
        ));
        
        // Đơn hàng 8: User - Đã giao hàng - 1 ngày trước
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 5),
            userAddresses.get(1),
            OrderStatus.DELIVERED,
            "COD",
            LocalDateTime.now().minusDays(1),
            coupons.get(3).getCode(),
            coupons.get(3).getValue(),
            0
        ));
        
        // Đơn hàng 9: Admin - Chờ thanh toán - hôm nay
        orders.add(createOrder(
            admin.getId(),
            getRandomOrderItems(products, 1),
            adminAddresses.get(0),
            OrderStatus.PENDING,
            "COD",
            LocalDateTime.now(),
            null,
            0,
            0
        ));
        
        // Đơn hàng 10: User - Đã thanh toán, chưa giao - hôm nay
        orders.add(createOrder(
            normalUser.getId(),
            getRandomOrderItems(products, 4),
            userAddresses.get(0),
            OrderStatus.PAID,
            "CREDIT_CARD",
            LocalDateTime.now(),
            coupons.get(4).getCode(),
            coupons.get(4).getValue(),
            5000
        ));
        
        // Lưu tất cả đơn hàng vào database
        orderRepository.saveAll(orders);
        
        System.out.println("Đã tạo " + orders.size() + " đơn hàng mẫu");
    }

    private Order createOrder(String userId, List<OrderItem> items, Address shippingAddress, 
                            OrderStatus status, String paymentMethod, LocalDateTime createdAt,
                            String couponCode, double couponDiscount, int loyaltyPointsUsed) {
        // Tính tổng tiền
        double totalAmount = items.stream()
                .mapToDouble(item -> item.getPrice() * item.getQuantity())
                .sum();
        
        // Tạo đơn hàng
        Order order = new Order();
        order.setUserId(userId);
        order.setItems(items);
        order.setTotalAmount(totalAmount);
        order.setStatus(status);
        order.setPaymentMethod(paymentMethod);
        order.setShippingAddress(shippingAddress);
        order.setCreatedAt(createdAt);
        order.setUpdatedAt(createdAt);
        
        // Áp dụng mã giảm giá nếu có
        if (couponCode != null) {
            order.applyCoupon(couponCode, couponDiscount);
        }
        
        // Áp dụng điểm loyalty nếu có
        if (loyaltyPointsUsed > 0) {
            // 1 điểm = 1,000 VND
            double loyaltyDiscount = loyaltyPointsUsed * 1000;
            order.applyLoyaltyPoints(loyaltyPointsUsed, loyaltyDiscount);
        }
        
        // Thêm thông tin bổ sung
        Map<String, Object> additionalInfo = new HashMap<>();
        User user = userRepository.findById(userId).orElse(null);
        if (user != null) {
            additionalInfo.put("username", user.getUsername());
            additionalInfo.put("email", user.getEmail());
        }
        order.setAdditionalInfo(additionalInfo);
        
        // Tạo lịch sử trạng thái dựa trên trạng thái hiện tại
        List<StatusHistoryEntry> statusHistory = new ArrayList<>();
        
        // Luôn thêm trạng thái PENDING đầu tiên
        statusHistory.add(new StatusHistoryEntry(
            OrderStatus.PENDING, 
            createdAt, 
            "Đơn hàng được tạo"
        ));
        
        // Thêm các trạng thái trung gian tùy theo trạng thái hiện tại
        LocalDateTime timeStamp = createdAt.plusHours(1); // Mỗi trạng thái cách nhau 1 giờ
        
        if (status == OrderStatus.PAID || status == OrderStatus.SHIPPING || status == OrderStatus.DELIVERED) {
            statusHistory.add(new StatusHistoryEntry(
                OrderStatus.PAID, 
                timeStamp, 
                "Đơn hàng đã được thanh toán"
            ));
            timeStamp = timeStamp.plusHours(1);
        }
        
        if (status == OrderStatus.SHIPPING || status == OrderStatus.DELIVERED) {
            statusHistory.add(new StatusHistoryEntry(
                OrderStatus.SHIPPING, 
                timeStamp, 
                "Đơn hàng đang được vận chuyển"
            ));
            timeStamp = timeStamp.plusHours(1);
        }
        
        if (status == OrderStatus.DELIVERED) {
            statusHistory.add(new StatusHistoryEntry(
                OrderStatus.DELIVERED, 
                timeStamp, 
                "Đơn hàng đã được giao thành công"
            ));
        } else if (status == OrderStatus.CANCELLED) {
            statusHistory.add(new StatusHistoryEntry(
                OrderStatus.CANCELLED, 
                timeStamp, 
                "Đơn hàng đã bị hủy"
            ));
        }
        
        order.setStatusHistory(statusHistory);
        
        return order;
    }

    private List<OrderItem> getRandomOrderItems(List<Product> products, int count) {
        List<OrderItem> items = new ArrayList<>();
        
        // Tạo một bản sao của danh sách sản phẩm để không ảnh hưởng đến danh sách gốc
        List<Product> productsCopy = new ArrayList<>(products);
        
        // Đảm bảo không lấy quá số lượng sản phẩm có sẵn
        count = Math.min(count, productsCopy.size());
        
        // Lấy ngẫu nhiên 'count' sản phẩm
        for (int i = 0; i < count; i++) {
            // Chọn ngẫu nhiên một sản phẩm từ danh sách
            int randomIndex = (int) (Math.random() * productsCopy.size());
            Product product = productsCopy.get(randomIndex);
            
            // Tạo OrderItem từ sản phẩm
            OrderItem item = new OrderItem();
            item.setProductId(product.getId());
            item.setProductName(product.getName());
            item.setQuantity((int) (Math.random() * 3) + 1); // Số lượng từ 1-3
            
            // Tính giá sau khi giảm giá (nếu có)
            double discountPercent = product.getDiscountPercent();
            double originalPrice = product.getPrice();
            double finalPrice = originalPrice - (originalPrice * discountPercent / 100);
            
            item.setPrice(finalPrice);
            item.setImageUrl(product.getPrimaryImageUrl());
            
            items.add(item);
            
            // Loại bỏ sản phẩm đã chọn để tránh trùng lặp
            productsCopy.remove(randomIndex);
        }
        
        return items;
    }
} 