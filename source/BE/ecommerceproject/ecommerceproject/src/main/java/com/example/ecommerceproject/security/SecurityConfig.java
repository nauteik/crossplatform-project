package com.example.ecommerceproject.security;

import com.example.ecommerceproject.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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

import java.io.PrintWriter;
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
                .requestMatchers("/api/producttype/types").permitAll()
                .requestMatchers("/api/producttype/{id}").permitAll()
                .requestMatchers("/api/producttype/create").permitAll()
                .requestMatchers("/api/producttype/update/{id}").permitAll()
                .requestMatchers("/api/producttype/delete/{id}").permitAll()
                // Message API paths
                .requestMatchers("/api/messages/**").permitAll()
                // Product API paths
                .requestMatchers("/api/tags/**").permitAll()
                // Product API paths
                .requestMatchers("/api/product/products").permitAll()
                .requestMatchers("/api/product/products/paged").permitAll()
                .requestMatchers("/api/product/{id}").permitAll()
                .requestMatchers("/api/product/search").permitAll()
                .requestMatchers("/api/product/by-brand/{brandId}").permitAll()
                .requestMatchers("/api/product/by-type/{productTypeId}").permitAll()
                .requestMatchers("/api/product/create").permitAll()
                .requestMatchers("/api/product/update/{id}").permitAll()
                .requestMatchers("/api/product/delete/{id}").permitAll()
                .requestMatchers("/api/product/discount/{id}").permitAll()
                .requestMatchers("/api/product/discount-brand/{brandId}").permitAll()
                .requestMatchers("/api/product/discount-type/{productTypeId}").permitAll()
                // Review API paths 
                .requestMatchers("/api/reviews/**").permitAll()
                // Coupon API paths
                .requestMatchers("/api/coupon/**").permitAll()
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
        configuration.setAllowedOrigins(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("authorization", "content-type", "x-auth-token"));
        configuration.setExposedHeaders(Arrays.asList("x-auth-token"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}