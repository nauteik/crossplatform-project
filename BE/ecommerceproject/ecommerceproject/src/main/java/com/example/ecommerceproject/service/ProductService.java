package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.repository.BrandRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.ProductTypeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final BrandRepository brandRepository;
    private final ProductTypeRepository productTypeRepository;

    @Autowired
    public ProductService(ProductRepository productRepository, 
                         BrandRepository brandRepository, 
                         ProductTypeRepository productTypeRepository) {
        this.productRepository = productRepository;
        this.brandRepository = brandRepository;
        this.productTypeRepository = productTypeRepository;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product getProductById(String id) {
        Optional<Product> product = productRepository.findById(id);
        return product.orElse(null);
    }

    public List<Product> getProductsByBrand(String brandId) {
        Optional<Brand> brand = brandRepository.findById(brandId);
        if (brand.isPresent()) {
            return productRepository.findByBrand(brand.get());
        }
        return List.of();
    }

    public List<Product> getProductsByProductType(String productTypeId) {
        Optional<ProductType> productType = productTypeRepository.findById(productTypeId);
        if (productType.isPresent()) {
            return productRepository.findByProductType(productType.get());
        }
        return List.of();
    }

    public List<Product> searchProducts(String query) {
        return productRepository.findByNameContainingIgnoreCase(query);
    }

    public Product createProduct(Product product) {
        return productRepository.save(product);
    }

    public Product updateProduct(String id, Product product) {
        if (!productRepository.existsById(id)) {
            return null;
        }

        product.setId(id);
        return productRepository.save(product);
    }

    public boolean deleteProduct(String id) {
        if (!productRepository.existsById(id)) {
            return false;
        }
        productRepository.deleteById(id);
        return true;
    }

    // Phương thức để áp dụng giảm giá cho sản phẩm theo ID
    public Product applyDiscountToProduct(String productId, double discountPercent) {
        Optional<Product> optionalProduct = productRepository.findById(productId);
        if (optionalProduct.isPresent()) {
            Product product = optionalProduct.get();
            product.setDiscountPercent(discountPercent);
            return productRepository.save(product);
        }
        return null;
    }

    // Phương thức để áp dụng giảm giá cho tất cả sản phẩm của một hãng
    public void applyDiscountToBrand(String brandId, double discountPercent) {
        Optional<Brand> optionalBrand = brandRepository.findById(brandId);
        if (optionalBrand.isPresent()) {
            List<Product> products = productRepository.findByBrand(optionalBrand.get());
            products.forEach(product -> product.setDiscountPercent(discountPercent));
            productRepository.saveAll(products);
        }
    }

    // Phương thức để áp dụng giảm giá cho tất cả sản phẩm của một loại
    public void applyDiscountToProductType(String productTypeId, double discountPercent) {
        Optional<ProductType> optionalProductType = productTypeRepository.findById(productTypeId);
        if (optionalProductType.isPresent()) {
            List<Product> products = productRepository.findByProductType(optionalProductType.get());
            products.forEach(product -> product.setDiscountPercent(discountPercent));
            productRepository.saveAll(products);
        }
    }
} 