package com.example.ecommerceproject.auth;

import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class GoogleAuthClient {

    private static final String GOOGLE_TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo?id_token=";
    
    @Autowired
    private RestTemplate restTemplate;
    
    @Autowired
    private ObjectMapper objectMapper;

    public GoogleAuthClient(RestTemplate restTemplate, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.objectMapper = objectMapper;
    }

    public GoogleUserInfo verifyGoogleToken(String idToken) {
        if (idToken == null || idToken.isEmpty()) {
            throw new IllegalArgumentException("Invalid Google token");
        }

        try {
            // Call the Google token info endpoint
            HttpHeaders headers = new HttpHeaders();
            HttpEntity<String> entity = new HttpEntity<>(headers);
            
            ResponseEntity<String> response = restTemplate.exchange(
                GOOGLE_TOKEN_INFO_URL + idToken,
                HttpMethod.GET,
                entity,
                String.class
            );

            if (response.getStatusCode().is2xxSuccessful()) {
                // Parse the response
                JsonNode root = objectMapper.readTree(response.getBody());
                
                // Verify token validity
                if (!root.has("email")) {
                    throw new IllegalArgumentException("Invalid Google token or token expired");
                }
                
                // Create and populate user info
                GoogleUserInfo userInfo = new GoogleUserInfo();
                userInfo.setEmail(root.get("email").asText());
                userInfo.setName(root.has("name") ? root.get("name").asText() : 
                                 root.get("email").asText().split("@")[0]);
                userInfo.setPictureUrl(root.has("picture") ? root.get("picture").asText() : 
                                      "https://example.com/default-avatar.png");
                
                return userInfo;
            } else {
                throw new IllegalArgumentException("Failed to verify Google token");
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Error verifying Google token: " + e.getMessage(), e);
        }
    }
    
    @Data
    public static class GoogleUserInfo {
        private String email;
        private String name;
        private String pictureUrl;
    }
}