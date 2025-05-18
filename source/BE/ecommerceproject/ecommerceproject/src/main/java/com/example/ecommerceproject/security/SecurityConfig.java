package com.example.ecommerceproject.security;

import com.example.ecommerceproject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final UserService userService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    
    @Autowired
    public SecurityConfig(UserService userService, JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.userService = userService;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }
    
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    // @Bean
    // public PasswordEncoder passwordEncoder() {
    //     return new BCryptPasswordEncoder();
    // }
    
    @Autowired
    public void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userService);
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/ws/**").permitAll()
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/user/getAll").permitAll()
                .requestMatchers("/api/user/get/**").permitAll()
                .requestMatchers("/api/user/**").permitAll()
                .requestMatchers("/login/oauth2/**").permitAll()
                // Image API paths
                .requestMatchers("/api/images/**").permitAll()
                // Cart API paths
                .requestMatchers("/api/cart/**").permitAll()
                // Order API paths - adding permission for all order endpoints
                .requestMatchers("/api/orders/**").permitAll()
                // Brand API paths
                .requestMatchers("/api/brand/brands").permitAll()
                .requestMatchers("/api/brand/{id}").permitAll()
                .requestMatchers("/api/brand/create").permitAll()
                .requestMatchers("/api/brand/update/{id}").permitAll()
                .requestMatchers("/api/brand/delete/{id}").permitAll()
                // ProductType API paths
                .requestMatchers("/api/producttype/**").permitAll()
                // Address API paths
                .requestMatchers("/api/address/**").permitAll()
                // Message API paths
                .requestMatchers("/api/messages/**").permitAll()
                .requestMatchers("/chat/**").permitAll()
                // Product API paths
                .requestMatchers("/api/tags/**").permitAll()
                // Product API paths
                .requestMatchers("/api/product/**").permitAll()
                // Review API paths 
                .requestMatchers("/api/reviews/**").permitAll()
                // Coupon API paths
                .requestMatchers("/api/coupon/**").permitAll()
                .requestMatchers("/api/coupons/**").permitAll()
                // Dashboard API paths
                .requestMatchers("/api/dashboard/**").permitAll()
                // Overview API paths
                .requestMatchers("/api/overview/**").permitAll()
                // Statistics API paths
                .requestMatchers("/api/statistics/**").permitAll()
                // PC API paths
                .requestMatchers("/api/pc/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2Login(oauth2 -> oauth2
                .defaultSuccessUrl("/api/auth/oauth2-success", true)
                .authorizationEndpoint(endpoint -> 
                    endpoint.baseUri("/oauth2/authorization")
                )
                // Xác định các URL public không yêu cầu xác thực
                .permitAll()
)
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )

            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
            .httpBasic(httpBasic -> httpBasic.disable())
            .formLogin(form -> form.disable());

        return http.build();
    }
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        configuration.setAllowCredentials(true); // Cho phép credentials nếu cần
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}