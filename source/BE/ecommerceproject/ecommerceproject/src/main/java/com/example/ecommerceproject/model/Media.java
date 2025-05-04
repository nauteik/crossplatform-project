package com.example.ecommerceproject.model;

import lombok.*;

@Data
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Media {
    private String type; // image hoặc video
    private String url;
}
