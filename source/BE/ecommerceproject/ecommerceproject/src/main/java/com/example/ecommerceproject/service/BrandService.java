package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.repository.BrandRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class BrandService {

    private final BrandRepository brandRepository;

    @Autowired
    public BrandService(BrandRepository brandRepository) {
        this.brandRepository = brandRepository;
    }

    public List<Brand> getAllBrands() {
        return brandRepository.findAll();
    }

    public Brand getBrandById(String id) {
        Optional<Brand> brand = brandRepository.findById(id);
        return brand.orElse(null);
    }

    public Brand createBrand(Brand brandRequest) {
        Brand brand = new Brand();
        brand.setName(brandRequest.getName());
        return brandRepository.save(brand);
    }

    public Brand updateBrand(String id, Brand brandRequest) {
        Optional<Brand> existingBrandOptional = brandRepository.findById(id);
        if (existingBrandOptional.isEmpty()) {
            return null;
        }

        Brand existingBrand = existingBrandOptional.get();
        existingBrand.setName(brandRequest.getName());
        return brandRepository.save(existingBrand);
    }

    public boolean deleteBrand(String id) {
        if (!brandRepository.existsById(id)) {
            return false;
        }
        brandRepository.deleteById(id);
        return true;
    }
} 