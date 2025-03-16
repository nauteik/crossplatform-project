package com.example.ecommerceproject.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.util.Date;

@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
@Getter
@Setter
public class UserDTO {

    @Id
    private String id;

    private String email;
    private String password;

    private String name;
    private String username;
    private String phone;
    private String address;
    private String gender;
    private Date birthday;

    private int rank;
    private int totalSpend;

    private int role;

    public String getUsername() {
        return username;
    }
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getRole() {
        return role;
    }

    public String getEmail() {
        return email;
    }
}
