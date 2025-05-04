package com.example.ecommerceproject.config;

import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class AdminInitializer {

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Value("${admin.default.username:admin}")
    private String defaultAdminUsername;
    
    @Value("${admin.default.password:admin123}")
    private String defaultAdminPassword;
    
    @Value("${admin.default.email:admin@example.com}")
    private String defaultAdminEmail;

    @Bean
    public CommandLineRunner initializeAdmin() {
        return args -> {
            // Kiểm tra xem đã có admin nào trong hệ thống chưa
            long adminCount = userRepository.findAll().stream()
                    .filter(user -> user.getRole() == 1)
                    .count();
                    
            if (adminCount == 0) {
                System.out.println("Không tìm thấy tài khoản admin. Tạo tài khoản mặc định...");
                
                // Tạo tài khoản admin mặc định
                User admin = new User();
                admin.setUsername(defaultAdminUsername);
                admin.setPassword(passwordEncoder.encode(defaultAdminPassword));
                admin.setEmail(defaultAdminEmail);
                admin.setName("System Administrator");
                admin.setRole(1);
                admin.setPhone("Chưa cập nhật");
                admin.setAddress("Chưa cập nhật");
                admin.setGender("Chưa cập nhật");
                admin.setAvatar("default.jpg");
                admin.setRank("Thành viên kim cương");
                admin.setTotalSpend(0);
                
                userRepository.save(admin);
                
                System.out.println("Đã tạo tài khoản admin mặc định:");
                System.out.println("Username: " + defaultAdminUsername);
                System.out.println("Password: " + defaultAdminPassword);
            } else {
                System.out.println("Đã tìm thấy " + adminCount + " tài khoản admin trong hệ thống.");
            }
        };
    }
}