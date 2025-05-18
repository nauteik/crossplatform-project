
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255),
    name VARCHAR(255),
    username VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    gender VARCHAR(10),
    birthday DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    rank VARCHAR(50),
    total_spend DECIMAL(10, 2) DEFAULT 0.00,
    loyalty_points INT DEFAULT 0,
    role INT NOT NULL
);


CREATE TABLE addresses (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    address_line VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    ward VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE brands (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);


CREATE TABLE product_types (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    image VARCHAR(255)
);


CREATE TABLE tags (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    color VARCHAR(20),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    active BOOLEAN DEFAULT TRUE
);


CREATE TABLE products (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 0,
    description TEXT,
    primary_image_url VARCHAR(255),
    image_urls JSON,
    specifications JSON,
    sold_count INT DEFAULT 0,
    discount_percent DECIMAL(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    brand_id VARCHAR(255),
    product_type_id VARCHAR(255),
    tags_ids JSON,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
    FOREIGN KEY (product_type_id) REFERENCES product_types(id) ON DELETE SET NULL
);


CREATE TABLE reviews (
    id VARCHAR(255) PRIMARY KEY,
    product_id VARCHAR(255) NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    media JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE carts (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL UNIQUE,
    items JSON,
    total_price DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE orders (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    items JSON,
    total_amount DECIMAL(12, 2) NOT NULL,
    coupon_code VARCHAR(50),
    coupon_discount DECIMAL(10, 2) DEFAULT 0.00,
    loyalty_points_used INT DEFAULT 0,
    loyalty_points_discount DECIMAL(10, 2) DEFAULT 0.00,
    status VARCHAR(50) NOT NULL,
    payment_method VARCHAR(50),
    shipping_address JSON,
    status_history JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


CREATE TABLE coupons (
    id VARCHAR(255) PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    value DECIMAL(10, 2) NOT NULL,
    max_uses INT NOT NULL,
    used_count INT DEFAULT 0,
    orders_applied JSON,
    creation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE messages (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255), 
    admin_id VARCHAR(255), 
    sender_id VARCHAR(255) NOT NULL,
    receiver_id VARCHAR(255),
    content TEXT NOT NULL,
    images JSON,
    is_from_user BOOLEAN,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE SET NULL
);


CREATE TABLE custom_pcs (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255),
    user_id VARCHAR(255) NOT NULL,
    total_price DECIMAL(12, 2) DEFAULT 0.00,
    cpu_id VARCHAR(255),
    motherboard_id VARCHAR(255),
    gpu_id VARCHAR(255),
    ram_id VARCHAR(255),
    storage_id VARCHAR(255),
    power_supply_id VARCHAR(255),
    pc_case_id VARCHAR(255),
    cooling_id VARCHAR(255),
    compatibility_notes JSON,
    is_complete BOOLEAN DEFAULT FALSE,
    build_status VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (cpu_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (motherboard_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (gpu_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (ram_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (storage_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (power_supply_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (pc_case_id) REFERENCES products(id) ON DELETE SET NULL,
    FOREIGN KEY (cooling_id) REFERENCES products(id) ON DELETE SET NULL
);


CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);


DELIMITER //
CREATE FUNCTION json_array_contains(json_array JSON, search_val VARCHAR(255)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE arr_length INT;
    
    SET arr_length = JSON_LENGTH(json_array);
    
    WHILE i < arr_length DO
        IF JSON_UNQUOTE(JSON_EXTRACT(json_array, CONCAT('$[', i, ']'))) = search_val THEN
            RETURN TRUE;
        END IF;
        SET i = i + 1;
    END WHILE;
    
    RETURN FALSE;
END //
DELIMITER ;

