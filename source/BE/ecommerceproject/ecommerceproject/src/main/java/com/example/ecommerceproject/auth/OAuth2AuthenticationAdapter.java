package com.example.ecommerceproject.auth;

import com.example.ecommerceproject.exception.ApiStatus;
import com.example.ecommerceproject.model.LoginResponse;
import com.example.ecommerceproject.model.User;
import com.example.ecommerceproject.repository.UserRepository;
import com.example.ecommerceproject.response.ApiResponse;
import com.example.ecommerceproject.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
// import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@Service
public class OAuth2AuthenticationAdapter implements AuthenticationService {
    
    private static final String GOOGLE_TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo?id_token=";
    
    // @Autowired
    // private OAuth2AuthorizedClientService clientService;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Override
    public ResponseEntity<ApiResponse<?>> authenticate(AuthenticationRequest request) {
        try {
            // Validate request
            if (request.getToken() == null) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(), 
                                     "OAuth2 token is required", null));
            }
            
            // Verify token and get user info
            Map<String, Object> userAttributes = verifyToken(request.getToken());
            
            if (userAttributes == null || !userAttributes.containsKey("email")) {
                return ResponseEntity.badRequest().body(
                    new ApiResponse<>(ApiStatus.INVALID_CREDENTIALS.getCode(), 
                                     "Invalid OAuth2 token", null));
            }
            
            // Find or create user
            User user = findOrCreateOAuth2User(userAttributes);
            
            // Generate JWT token
            UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
            );
            String token = jwtUtil.generateToken(userDetails);
            
            // Create response
            LoginResponse loginResponse = new LoginResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getRole()
            );
            
            return ResponseEntity.ok(new ApiResponse<>(
                ApiStatus.SUCCESS.getCode(),
                "OAuth2 authentication successful",
                loginResponse
            ));
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(new ApiResponse<>(ApiStatus.SERVER_ERROR.getCode(),
                    "OAuth2 authentication failed: " + e.getMessage(), null));
        }
    }
    
    @Override
    public boolean supports(AuthenticationType type) {
        return AuthenticationType.OAUTH2.equals(type);
    }
    
    private Map<String, Object> verifyToken(String token) {
        try {
            HttpHeaders headers = new HttpHeaders();
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            ResponseEntity<Map> response = restTemplate.exchange(
                GOOGLE_TOKEN_INFO_URL + token,
                HttpMethod.GET,
                entity,
                Map.class
            );
            
            if (response.getStatusCode().is2xxSuccessful()) {
                return response.getBody();
            }
            
            return null;
        } catch (Exception e) {
            return null;
        }
    }
    
    private User findOrCreateOAuth2User(Map<String, Object> attributes) {
        String email = (String) attributes.get("email");
        Optional<User> existingUser = userRepository.findByEmail(email);
        
        if (existingUser.isPresent()) {
            return existingUser.get();
        }
        
        // Create new user
        User newUser = new User();
        newUser.setEmail(email);
        newUser.setUsername(email.split("@")[0]); // Use part before @ as username
        newUser.setName((String) attributes.getOrDefault("name", email.split("@")[0]));
        newUser.setAvatar((String) attributes.getOrDefault("picture", "https://ui-avatars.com/api/?name=" + email.charAt(0)));
        newUser.setPhone("Chưa cập nhật");
        newUser.setGender("Chưa cập nhật");
        newUser.setRank("Thành viên đồng");
        
        // Generate random password
        String randomPassword = UUID.randomUUID().toString();
        newUser.setPassword(passwordEncoder.encode(randomPassword));
        newUser.setRole(0); // Regular user role
        
        return userRepository.save(newUser);
    }
}