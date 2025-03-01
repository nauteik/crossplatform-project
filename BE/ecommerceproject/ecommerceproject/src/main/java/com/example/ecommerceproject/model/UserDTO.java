package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "user")
public class UserDTO {

    @Id
    private String id;

    private String username;
    private String password;

    private String name;
    private String email;
    private String phone;
    private String address;
    private String gender;
    private Date birthday;

    private int rank;
    private int totalSpend;

    private int role;


}
