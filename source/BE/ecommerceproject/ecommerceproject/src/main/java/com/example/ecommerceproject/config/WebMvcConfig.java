package com.example.ecommerceproject.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.ContentNegotiationConfigurer;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.List;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${upload.dir}")
    private String uploadDir;
    
    @Value("${upload.path}")
    private String uploadPath;

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        // Ensure all JSON responses are UTF-8 encoded
        converters.stream()
            .filter(converter -> converter instanceof MappingJackson2HttpMessageConverter)
            .forEach(converter -> ((MappingJackson2HttpMessageConverter) converter).setDefaultCharset(StandardCharsets.UTF_8));
        
        // Ensure all string responses are UTF-8 encoded
        converters.stream()
            .filter(converter -> converter instanceof StringHttpMessageConverter)
            .forEach(converter -> ((StringHttpMessageConverter) converter).setDefaultCharset(StandardCharsets.UTF_8));
    }
    
    @Override
    public void configureContentNegotiation(ContentNegotiationConfigurer configurer) {
        configurer.defaultContentType(org.springframework.http.MediaType.APPLICATION_JSON);
    }
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Cho phép tất cả các đường dẫn
                .allowedOriginPatterns("*") // Cho phép tất cả các origin (sử dụng allowedOriginPatterns thay vì allowedOrigins để hỗ trợ wildcard tốt hơn)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS") // Cho phép các phương thức HTTP
                .allowedHeaders("*") // Cho phép tất cả các header
                .allowCredentials(true); // Cho phép gửi cookie
    }
    
    @Bean
    public StringHttpMessageConverter stringHttpMessageConverter() {
        return new StringHttpMessageConverter(StandardCharsets.UTF_8);
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Đăng ký handler để phục vụ tệp từ thư mục uploads
        // Ánh xạ đường dẫn /api/images/ tới thư mục uploads
        String uploadDirPath = Paths.get(uploadDir).toFile().getAbsolutePath();
        
        // Cấu hình cho phép phục vụ tệp từ thư mục uploads
        registry.addResourceHandler("/api/images/**")
                .addResourceLocations("file:" + uploadDirPath + "/")
                .setCachePeriod(0); // Tắt cache để luôn tải hình ảnh mới
        
        // Giữ nguyên cấu hình tài nguyên tĩnh mặc định
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
    }
}