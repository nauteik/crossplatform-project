package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Address;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.UserRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.security.Key;
import java.security.SecureRandom;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final Key secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS512);
    private final AddressService addressService;

    @Autowired
    private EmailService emailService;
    
    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, AddressService addressService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.addressService = addressService;
    }

    public User registerUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        user.setName("Chưa cập nhật");
        user.setAvatar("Chưa cập nhật");
        user.setPhone("Chưa cập nhật");
        user.setGender("Chưa cập nhật");
        user.setRank("Thành viên đồng");
        user.setLoyaltyPoints(0); // Khởi tạo điểm loyalty
        // Mã hóa mật khẩu trước khi lưu
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Lưu vào database
        return userRepository.save(user);
    }

    public boolean isUsernameExists(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean isEmailExists(String email) {
        return userRepository.existsByEmail(email);
    }
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new UsernameNotFoundException("User not found with username: " + username));
            
        return new org.springframework.security.core.userdetails.User(user.getUsername(), user.getPassword(), new ArrayList<>());
    }
    
    public User authenticateUser(String username, String password) {
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new BadCredentialsException("Invalid username or password"));
            
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new BadCredentialsException("Invalid username or password");
        }
        
        return user;
    }

    public User updateUser(String userId, User updatedUser) {
        User existingUser = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        if (updatedUser.getEmail() != null) {
            // Kiểm tra nếu email mới khác email cũ và đã tồn tại
            if (!existingUser.getEmail().equals(updatedUser.getEmail()) && 
                userRepository.existsByEmail(updatedUser.getEmail())) {
                throw new RuntimeException("Email already in use");
            }
            existingUser.setEmail(updatedUser.getEmail());
        }
        
        if (updatedUser.getUsername() != null) {
            // Kiểm tra nếu username mới khác username cũ và đã tồn tại
            if (!existingUser.getUsername().equals(updatedUser.getUsername()) && 
                userRepository.existsByUsername(updatedUser.getUsername())) {
                throw new RuntimeException("Username already in use");
            }
            existingUser.setUsername(updatedUser.getUsername());
        }

        // Cập nhật mật khẩu nếu được cung cấp
        if (updatedUser.getPassword() != null && !updatedUser.getPassword().isEmpty()) {
            existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
        }
        
        if (updatedUser.getName() != null) {
            existingUser.setName(updatedUser.getName());
        }
        
        if (updatedUser.getAvatar() != null) {
            existingUser.setAvatar(updatedUser.getAvatar());
        }
        
        if (updatedUser.getPhone() != null) {
            existingUser.setPhone(updatedUser.getPhone());
        }
      
        if (updatedUser.getGender() != null) {
            existingUser.setGender(updatedUser.getGender());
        }
        
        if (updatedUser.getBirthday() != null) {
            existingUser.setBirthday(updatedUser.getBirthday());
        }
        
        if (updatedUser.getRank() != null) {
            existingUser.setRank(updatedUser.getRank());
        }
        
        // totalSpend is a primitive int, so check if the updatedUser has a non-default value
        if (updatedUser.getTotalSpend() != 0) {
            existingUser.setTotalSpend(updatedUser.getTotalSpend());
        }
        
        // role is a primitive int, but we still want to be able to update it to 0 (user role)
        // Here we're assuming the role is explicitly set in the updatedUser object
        existingUser.setRole(updatedUser.getRole());
        
        // Cập nhật loyalty points nếu được chỉ định
        if (updatedUser.getLoyaltyPoints() > 0) {
            existingUser.setLoyaltyPoints(updatedUser.getLoyaltyPoints());
        }
        
        // Lưu người dùng đã cập nhật
        return userRepository.save(existingUser);
    }

    public User getUserById(String userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
    }

    public User getUserByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found with username: " + username));
    }

    public int getUserCount() {
        return (int) userRepository.count();
    }

    // Lấy admin mặc định (đầu tiên có role = 1)
    public User getDefaultAdmin() {
        return userRepository.findAll().stream()
                .filter(user -> user.getRole() == 1)
                .findFirst()
                .orElse(null);
    }

    public List<User> getUsersCreatedOnDate(LocalDate date) {
        // Get start and end of the specified date
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(23, 59, 59);

        // Filter users from the repository by creation date
        return userRepository.findByCreatedAtBetween(startOfDay, endOfDay);
    }

    /**
     * Thay đổi mật khẩu người dùng
     * @param userId ID của người dùng
     * @param oldPassword Mật khẩu cũ
     * @param newPassword Mật khẩu mới
     * @return User đã cập nhật
     * @throws RuntimeException nếu mật khẩu cũ không đúng hoặc người dùng không tồn tại
     */
    public User changePassword(String userId, String oldPassword, String newPassword) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        // Kiểm tra mật khẩu cũ
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }
        
        // Cập nhật mật khẩu mới
        user.setPassword(passwordEncoder.encode(newPassword));
        
        return userRepository.save(user);
    }
    
    /**
     * Lấy danh sách địa chỉ của người dùng
     */
    public List<Address> getUserAddresses(String userId) {
        // Kiểm tra người dùng tồn tại
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        // Sử dụng AddressService để lấy danh sách địa chỉ
        return addressService.getUserAddresses(userId);
    }
    
    /**
     * Lấy địa chỉ theo ID
     */
    public Address getAddressById(String userId, String addressId) {
        // Kiểm tra người dùng tồn tại
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));
        
        // Sử dụng AddressService để lấy địa chỉ
        return addressService.getAddressByIdAndUserId(addressId, userId);
    }

    // Tìm người dùng theo email
    public User findByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
    }
    
    // Tìm người dùng theo username
    public User findByUsername(String username) {
        return userRepository.findByUsername(username).orElse(null);
    }
    
    // Tạo người dùng mới
    public User createUser(String email, String password, String fullName) {
        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setName(fullName);
        user.setUsername(email); // Sử dụng email làm username mặc định
        user.setCreatedAt(LocalDateTime.now());
        user.setRole(0); // Role mặc định là 0 (user thường)
        user.setRank("Bronze"); // Rank mặc định là Bronze
        user.setTotalSpend(0);
        user.setLoyaltyPoints(0); // Khởi tạo điểm loyalty
        
        return userRepository.save(user);
    }
    
    // Tạo người dùng mới với username tùy chỉnh
    public User createUser(String email, String username, String password, String fullName) {
        User user = new User();
        user.setEmail(email);
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode(password));
        user.setName(fullName);
        user.setCreatedAt(LocalDateTime.now());
        user.setRole(0); // Role mặc định là 0 (user thường)
        user.setRank("Bronze"); // Rank mặc định là Bronze
        user.setTotalSpend(0);
        user.setLoyaltyPoints(0); // Khởi tạo điểm loyalty
        
        return userRepository.save(user);
    }
    
    /**
     * Thêm địa chỉ mới cho người dùng
     */
    public Address addAddress(String userId, Address address) {
        return addressService.addAddress(userId, address);
    }
    
    // Tạo JWT token xác thực
    public String generateAuthToken(String userId) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + 86400000); // 24 giờ

        return Jwts.builder()
                .setSubject(userId)
                .setIssuedAt(now)
                .setExpiration(expiryDate)
                .signWith(secretKey)
                .compact();
    }

    /**
     * Tạo mật khẩu ngẫu nhiên với độ dài xác định
     * @param length Độ dài của mật khẩu
     * @return Mật khẩu ngẫu nhiên
     */
    private String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        
        for (int i = 0; i < length; i++) {
            int randomIndex = random.nextInt(chars.length());
            sb.append(chars.charAt(randomIndex));
        }
        
        return sb.toString();
    }

    /**
     * Đặt lại mật khẩu cho người dùng
     * @param email Email của người dùng
     * @return true nếu đặt lại mật khẩu thành công, false nếu không tìm thấy email
     */
    public boolean resetPassword(String email) {
        Optional<User> userOptional = userRepository.findByEmail(email);
        
        if (userOptional.isEmpty()) {
            return false;
        }
        
        User user = userOptional.get();
        
        // Tạo mật khẩu ngẫu nhiên 8 ký tự
        String newPassword = generateRandomPassword(8);
        
        // Cập nhật mật khẩu đã mã hóa vào cơ sở dữ liệu
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        
        // Gửi email chứa mật khẩu mới
        Map<String, Object> emailData = new HashMap<>();
        emailData.put("to", user.getEmail());
        emailData.put("username", user.getUsername());
        emailData.put("email", user.getEmail());
        emailData.put("newPassword", newPassword);
        
        emailService.sendPasswordResetEmail(emailData);
        
        return true;
    }
    
    /**
     * Thêm điểm loyalty cho người dùng sau khi hoàn thành đơn hàng
     * @param userId ID của người dùng
     * @param totalAmount Tổng giá trị đơn hàng
     * @return User đã cập nhật
     */
    public User addLoyaltyPoints(String userId, double totalAmount) {
        User user = getUserById(userId);
        
        // Tính số điểm loyalty (10% giá trị đơn hàng / 1000)
        // Mỗi 1000 VND = 1 điểm
        int pointsToAdd = (int)(totalAmount * 0.1 / 1000);
        
        // Cập nhật tổng chi tiêu của người dùng
        user.setTotalSpend(user.getTotalSpend() + (int)totalAmount);
        
        // Cập nhật điểm loyalty
        user.setLoyaltyPoints(user.getLoyaltyPoints() + pointsToAdd);
        
        // Cập nhật rank dựa trên tổng chi tiêu
        updateUserRank(user);
        
        return userRepository.save(user);
    }
    
    /**
     * Sử dụng điểm loyalty cho một đơn hàng
     * @param userId ID người dùng
     * @param pointsToUse Số điểm muốn sử dụng
     * @return Số tiền giảm giá (1 điểm = 1000 VND)
     * @throws RuntimeException nếu không đủ điểm
     */
    public double useLoyaltyPoints(String userId, int pointsToUse) {
        User user = getUserById(userId);
        
        if (user.getLoyaltyPoints() < pointsToUse) {
            throw new RuntimeException("Không đủ điểm loyalty");
        }
        
        // Trừ điểm đã sử dụng
        user.setLoyaltyPoints(user.getLoyaltyPoints() - pointsToUse);
        userRepository.save(user);
        
        // Quy đổi điểm thành tiền (1 điểm = 1000 VND)
        return pointsToUse * 1000;
    }
    
    /**
     * Lấy số điểm loyalty của người dùng
     * @param userId ID người dùng
     * @return Số điểm loyalty hiện có
     */
    public int getLoyaltyPoints(String userId) {
        User user = getUserById(userId);
        return user.getLoyaltyPoints();
    }
    
    /**
     * Cập nhật hạng thành viên của người dùng dựa trên tổng chi tiêu
     * @param user User cần cập nhật
     */
    private void updateUserRank(User user) {
        int totalSpend = user.getTotalSpend();
        
        if (totalSpend >= 10000000) { // 10 triệu VND
            user.setRank("Thành viên bạch kim");
        } else if (totalSpend >= 5000000) { // 5 triệu VND
            user.setRank("Thành viên vàng");
        } else if (totalSpend >= 2000000) { // 2 triệu VND
            user.setRank("Thành viên bạc");
        } else {
            user.setRank("Thành viên đồng");
        }
    }
}

