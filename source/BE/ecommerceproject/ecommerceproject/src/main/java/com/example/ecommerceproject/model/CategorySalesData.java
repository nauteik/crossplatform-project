package com.example.ecommerceproject.model;

 import lombok.Data;
 import lombok.NoArgsConstructor;
// import lombok.AllArgsConstructor;

 @Data // Nếu sử dụng Lombok
 @NoArgsConstructor // Nếu sử dụng Lombok
// @AllArgsConstructor // Nếu sử dụng Lombok
public class CategorySalesData {

    private String categoryName;
    private int totalQuantitySold; // Tổng số lượng bán của danh mục này

    // Constructor đầy đủ tham số
    public CategorySalesData(String categoryName, int totalQuantitySold) {
        this.categoryName = categoryName;
        this.totalQuantitySold = totalQuantitySold;
    }
}