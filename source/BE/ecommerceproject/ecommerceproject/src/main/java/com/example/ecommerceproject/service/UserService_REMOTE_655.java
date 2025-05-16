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
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;
import java.security.Key;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final Key secretKey = Keys.secretKeyFor(SignatureAlgorithm.HS512);

    @Autowired
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public User registerUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists");
        }
        user.setName("Chưa cập nhật");
        user.setAvatar("Chưa cập nhật");
        user.setAddresses(new ArrayList<>());
        user.setPhone("Chưa cập nhật");
        user.setGender("Chưa cập nhật");
        user.setRank("Thành viên đồng");
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
    
    // Phương thức quản lý địa chỉ
    
    /**
     * Thêm địa chỉ mới cho người dùng
     * @param userId ID của người dùng
     * @param address Địa chỉ mới
     * @return User đã cập nhật
     */
    public User addAddress(String userId, Address address) {
        Optional<User> userOptional = userRepository.findById(userId);
        
        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }
        
        User user = userOptional.get();
        
        // Nếu là địa chỉ mặc định, cập nhật các địa chỉ khác không còn là mặc định
        if (address.isDefault()) {
            user.getAddresses().forEach(a -> a.setDefault(false));
        }
        
        // Nếu đây là địa chỉ đầu tiên, đặt nó làm mặc định
        if (user.getAddresses().isEmpty()) {
            address.setDefault(true);
        }
        
        user.getAddresses().add(address);
        return userRepository.save(user);
    }
    
    /**
     * Cập nhật địa chỉ của người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @param updatedAddress Địa chỉ đã cập nhật
     * @return User đã cập nhật
     */
    public User updateAddress(String userId, String addressId, Address updatedAddress) {
        User user = getUserById(userId);
        
        if (user.getAddresses() == null || user.getAddresses().isEmpty()) {
            throw new RuntimeException("Người dùng không có địa chỉ nào");
        }
        
        // Tìm địa chỉ cần cập nhật
        boolean addressFound = false;
        for (int i = 0; i < user.getAddresses().size(); i++) {
            Address address = user.getAddresses().get(i);
            if (address.getId().equals(addressId)) {
                // Giữ nguyên ID
                updatedAddress.setId(addressId);
                
                // Nếu cập nhật thành địa chỉ mặc định
                if (updatedAddress.isDefault() && !address.isDefault()) {
                    // Đặt tất cả địa chỉ khác thành không mặc định
                    user.getAddresses().forEach(a -> a.setDefault(false));
                
                }
                
                // Nếu địa chỉ này đang là mặc định, giữ nguyên trạng thái mặc định
                if (address.isDefault() && !updatedAddress.isDefault()) {
                    updatedAddress.setDefault(true);
                }
                
                user.getAddresses().set(i, updatedAddress);
                addressFound = true;
                break;
            }
        }
        
        if (!addressFound) {
            throw new RuntimeException("Không tìm thấy địa chỉ với ID: " + addressId);
        }
        
        return userRepository.save(user);
    }
    
    /**
     * Xóa địa chỉ của người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @return User đã cập nhật
     */
    public User deleteAddress(String userId, String addressId) {
        User user = getUserById(userId);
        
        if (user.getAddresses() == null || user.getAddresses().isEmpty()) {
            throw new RuntimeException("Người dùng không có địa chỉ nào");
        }
        
        // Tìm địa chỉ cần xóa
        Address addressToDelete = null;
        for (Address address : user.getAddresses()) {
            if (address.getId().equals(addressId)) {
                addressToDelete = address;
                break;
            }
        }
        
        if (addressToDelete == null) {
            throw new RuntimeException("Không tìm thấy địa chỉ với ID: " + addressId);
        }
        
        // Nếu xóa địa chỉ mặc định và còn địa chỉ khác
        if (addressToDelete.isDefault() && user.getAddresses().size() > 1) {
            // Đặt địa chỉ còn lại thành mặc định
            Address otherAddress = user.getAddresses().stream()
                    .filter(a -> !a.getId().equals(addressId))
                    .findFirst()
                    .orElse(null);
            
            if (otherAddress != null) {
                otherAddress.setDefault(true);
            }
        }
        
        // Xóa địa chỉ
        user.setAddresses(user.getAddresses().stream()
                .filter(a -> !a.getId().equals(addressId))
                .collect(Collectors.toList()));

        
        return userRepository.save(user);
    }
    
    /**
     * Đặt địa chỉ mặc định cho người dùng
     * @param userId ID của người dùng
     * @param addressId ID của địa chỉ
     * @return User đã cập nhật
     */
    public User setDefaultAddress(String userId, String addressId) {
        User user = getUserById(userId);
        
        if (user.getAddresses() == null || user.getAddresses().isEmpty()) {
            throw new RuntimeException("Người dùng không có địa chỉ nào");
        }
        
        // Tìm địa chỉ cần đặt mặc định
        Address addressToSetDefault = null;
        for (Address address : user.getAddresses()) {
            if (address.getId().equals(addressId)) {
                addressToSetDefault = address;
            }
            // Đặt tất cả địa chỉ thành không mặc định
            address.setDefault(false);
        }
        
        if (addressToSetDefault == null) {
            throw new RuntimeException("Không tìm thấy địa chỉ với ID: " + addressId);
        }
        
        // Đặt địa chỉ đã chọn thành mặc định
        addressToSetDefault.setDefault(true);
        
        return userRepository.save(user);
    }
    
    /**
     * Lấy danh sách địa chỉ của người dùng
     * @param userId ID của người dùng
     * @return Danh sách địa chỉ
     */
    public List<Address> getUserAddresses(String userId) {
        User user = getUserById(userId);
        return user.getAddresses() != null ? user.getAddresses() : new ArrayList<>();
    }

    // Tìm người dùng theo email
    public User findByEmail(String email) {
        return userRepository.findByEmail(email).orElse(null);
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
        
        return userRepository.save(user);
    }
    
    // Lấy địa chỉ theo ID
    public Address getAddressById(String userId, String addressId) {
        Optional<User> userOptional = userRepository.findById(userId);
        
        if (userOptional.isEmpty()) {
            throw new IllegalArgumentException("User not found with id: " + userId);
        }
        
        User user = userOptional.get();
        
        return user.getAddresses().stream()
                .filter(address -> address.getId().equals(addressId))
                .findFirst()
                .orElse(null);
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
}

