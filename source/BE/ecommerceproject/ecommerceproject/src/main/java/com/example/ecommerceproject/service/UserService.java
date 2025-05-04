package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Optional;

@Service
public class UserService implements UserDetailsService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

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
        user.setAddress("Chưa cập nhật");
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

    /**
     * Cập nhật thông tin người dùng
     * @param userId ID của người dùng cần cập nhật
     * @param updatedUser Thông tin người dùng mới
     * @return User đã cập nhật
     */
    public User updateUser(String userId, User updatedUser) {
        User existingUser = getUserById(userId);
        if (existingUser == null) {
            throw new RuntimeException("User not found with id: " + userId);
        }

        // Kiểm tra email mới (nếu có) xem đã được sử dụng bởi người dùng khác chưa
        if (updatedUser.getEmail() != null && !updatedUser.getEmail().isEmpty()
                && !updatedUser.getEmail().equals(existingUser.getEmail())) {
            Optional<User> userWithSameEmail = userRepository.findByEmail(updatedUser.getEmail());
            if (userWithSameEmail != null && !userWithSameEmail.get().getId().equals(userId)) {
                throw new RuntimeException("Email already in use by another user");
            }
        }

        // Cập nhật thông tin cơ bản
        if (updatedUser.getName() != null) existingUser.setName(updatedUser.getName());
        if (updatedUser.getEmail() != null) existingUser.setEmail(updatedUser.getEmail());
        if (updatedUser.getPhone() != null) existingUser.setPhone(updatedUser.getPhone());
        if (updatedUser.getAddress() != null) existingUser.setAddress(updatedUser.getAddress());
        if (updatedUser.getGender() != null) existingUser.setGender(updatedUser.getGender());
        if (updatedUser.getBirthday() != null) existingUser.setBirthday(updatedUser.getBirthday());
        if (updatedUser.getAvatar() != null) existingUser.setAvatar(updatedUser.getAvatar());
        
<<<<<<< HEAD:BE/ecommerceproject/ecommerceproject/src/main/java/com/example/ecommerceproject/service/UserService.java
        // Cập nhật username nếu được phép
        if (updatedUser.getUsername() != null) {
            // Kiểm tra xem username đã tồn tại chưa
            if (!updatedUser.getUsername().equals(existingUser.getUsername())) {
                Optional<User> userWithSameUsername = userRepository.findByUsername(updatedUser.getUsername());
                if (userWithSameUsername != null) {
                    throw new RuntimeException("Username already taken");
                }
                existingUser.setUsername(updatedUser.getUsername());
            }
        }
        
        // Cập nhật mật khẩu nếu được cung cấp
        if (updatedUser.getPassword() != null && !updatedUser.getPassword().isEmpty()) {
            // Mã hóa mật khẩu trước khi lưu
            existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));
        }
        
//        // Cập nhật role - chỉ được gọi sau khi đã kiểm tra quyền
//        if (updatedUser.getRole() != null) {
//            existingUser.setRole(updatedUser.getRole());
//        }
        
        // Lưu các thay đổi vào database
=======
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
        
        if (updatedUser.getAddress() != null) {
            existingUser.setAddress(updatedUser.getAddress());
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
>>>>>>> Kiet:source/BE/ecommerceproject/ecommerceproject/src/main/java/com/example/ecommerceproject/service/UserService.java
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

}

