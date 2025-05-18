package com.example.ecommerceproject.service;

import com.example.ecommerceproject.model.Brand;
import com.example.ecommerceproject.model.Product;
import com.example.ecommerceproject.model.ProductType;
import com.example.ecommerceproject.model.Tag;
import com.example.ecommerceproject.repository.BrandRepository;
import com.example.ecommerceproject.repository.ProductRepository;
import com.example.ecommerceproject.repository.ProductTypeRepository;
import com.example.ecommerceproject.repository.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class ProductService {

    private final ProductRepository productRepository;
    private final BrandRepository brandRepository;
    private final ProductTypeRepository productTypeRepository;
    private final TagRepository tagRepository;

    @Autowired
    public ProductService(ProductRepository productRepository, 
                         BrandRepository brandRepository, 
                         ProductTypeRepository productTypeRepository,
                         TagRepository tagRepository) {
        this.productRepository = productRepository;
        this.brandRepository = brandRepository;
        this.productTypeRepository = productTypeRepository;
        this.tagRepository = tagRepository;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Map<String, Object> getPagedProducts(int page, int size) {
        Pageable paging = PageRequest.of(page, size);
        Page<Product> pageProducts = productRepository.findAll(paging);
        
        Map<String, Object> result = new HashMap<>();
        result.put("products", pageProducts.getContent());
        result.put("currentPage", pageProducts.getNumber());
        result.put("totalItems", pageProducts.getTotalElements());
        result.put("totalPages", pageProducts.getTotalPages());
        
        return result;
    }

    public Product getProductById(String id) {
        return productRepository.findById(id).orElse(null);
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

    public List<Product> getProductsByTag(String tagId) {
        Optional<Tag> tag = tagRepository.findById(tagId);
        if (tag.isPresent()) {
            return productRepository.findByTagsContaining(tag.get());
        }
        return List.of();
    }

    public List<Product> searchProducts(String query) {
        return productRepository.findByNameContainingIgnoreCase(query);
    }

    public Product createProduct(Product product) {
        product.setId(null);
        return productRepository.save(product);
    }

    public Product updateProduct(String id, Product product) {
        if (!productRepository.existsById(id)) {
            return null;
        }

        Product existingProduct = productRepository.findById(id).orElse(null);
        if (existingProduct != null) {
            product.setId(id);
            product.setCreatedAt(existingProduct.getCreatedAt());
            return productRepository.save(product);
        }

        return null;
    }

    public boolean deleteProduct(String id) {
        if (!productRepository.existsById(id)) {
            return false;
        }
        productRepository.deleteById(id);
        return true;
    }

    public Product applyDiscountToProduct(String productId, double discountPercent) {
        Optional<Product> optionalProduct = productRepository.findById(productId);
        if (optionalProduct.isPresent()) {
            Product product = optionalProduct.get();
            product.setDiscountPercent(discountPercent);
            return productRepository.save(product);
        }
        return null;
    }

    public void applyDiscountToBrand(String brandId, double discountPercent) {
        Optional<Brand> optionalBrand = brandRepository.findById(brandId);
        if (optionalBrand.isPresent()) {
            List<Product> products = productRepository.findByBrand(optionalBrand.get());
            products.forEach(product -> product.setDiscountPercent(discountPercent));
            productRepository.saveAll(products);
        }
    }

    public void applyDiscountToProductType(String productTypeId, double discountPercent) {
        Optional<ProductType> productTypeOptional = productTypeRepository.findById(productTypeId);
        productTypeOptional.ifPresent(productType -> {
            List<Product> products = productRepository.findByProductType(productType);
            for (Product product : products) {
                product.setDiscountPercent(discountPercent);
                productRepository.save(product);
            }
        });
    }

    public void increaseQuantity(String productId, int quantity) {
        Optional<Product> optionalProduct = productRepository.findById(productId);
        if (optionalProduct.isPresent()) {
            Product product = optionalProduct.get();
            int newQuantity = product.getQuantity() + quantity;
            product.setQuantity(newQuantity);
            productRepository.save(product);
        }
    }

    public void decreaseQuantity(String productId, int quantity) {
        Optional<Product> optionalProduct = productRepository.findById(productId);
        if (optionalProduct.isPresent()) {
            Product product = optionalProduct.get();
            int newQuantity = product.getQuantity() - quantity;
            product.setQuantity(newQuantity);
            productRepository.save(product);
        }
    }

    // Tag management methods
    public Product addTagToProduct(String productId, String tagId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        Tag tag = tagRepository.findById(tagId)
                .orElseThrow(() -> new RuntimeException("Tag not found with id: " + tagId));
        
        // Kiểm tra xem tag đã tồn tại trong danh sách của sản phẩm chưa
        if (product.getTags() == null) {
            product.setTags(new ArrayList<>());
        }
        
        // Kiểm tra xem tag đã tồn tại chưa để tránh trùng lặp
        boolean tagExists = product.getTags().stream()
                .anyMatch(t -> t.getId().equals(tagId));
        
        if (!tagExists) {
            product.getTags().add(tag);
            return productRepository.save(product);
        }
        
        return product;
    }

    public Product removeTagFromProduct(String productId, String tagId) {
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + productId));
        
        if (product.getTags() == null) {
            return product;
        }
        
        product.setTags(product.getTags().stream()
                .filter(tag -> !tag.getId().equals(tagId))
                .collect(Collectors.toList()));
        
        return productRepository.save(product);
    }

    public int getProductCount() {
        return (int) productRepository.count();
    }

    public String getProductTypeNameById(String id) {
        Optional<ProductType> optionalProductType = productTypeRepository.findById(id);
        if (optionalProductType.isPresent()) {
            return optionalProductType.get().getName();
        }
        return null;
    }
} 