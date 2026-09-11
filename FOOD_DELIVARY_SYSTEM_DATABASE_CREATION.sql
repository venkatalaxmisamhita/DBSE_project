DROP DATABASE IF EXISTS food_delivery_test;

CREATE DATABASE food_delivery_test;

USE food_delivery_test;

-- 1. USERS
CREATE TABLE users (
    user_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL,
    phone CHAR(10) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id),
    UNIQUE (email),
    UNIQUE (phone)
) ENGINE=InnoDB;


-- 2. ADDRESSES
CREATE TABLE addresses (
    address_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    label ENUM('HOME','WORK','OTHER') NOT NULL DEFAULT 'HOME',
    line1 VARCHAR(150) NOT NULL,
    line2 VARCHAR(150),
    city VARCHAR(60) NOT NULL,
    state VARCHAR(60) NOT NULL,
    pincode CHAR(6) NOT NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (address_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 3. RESTAURANTS
CREATE TABLE restaurants (
    restaurant_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(120) NOT NULL,
    phone CHAR(10) NOT NULL,
    email VARCHAR(120),
    address_line VARCHAR(200) NOT NULL,
    city VARCHAR(60) NOT NULL,
    pincode CHAR(6) NOT NULL,
    opening_time TIME NOT NULL DEFAULT '09:00:00',
    closing_time TIME NOT NULL DEFAULT '23:00:00',
    rating DECIMAL(2,1) NOT NULL DEFAULT 0.0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (restaurant_id),
    UNIQUE (phone),
    UNIQUE (name, city),

    CHECK (rating BETWEEN 0.0 AND 5.0)
) ENGINE=InnoDB;


-- 4. FOOD CATEGORIES
CREATE TABLE food_categories (
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(60) NOT NULL,
    description VARCHAR(200),

    PRIMARY KEY (category_id),
    UNIQUE (category_name)
) ENGINE=InnoDB;


-- 5. FOOD ITEMS
CREATE TABLE food_items (
    food_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    restaurant_id INT UNSIGNED NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    name VARCHAR(120) NOT NULL,
    description VARCHAR(255),
    price DECIMAL(8,2) NOT NULL,
    is_veg TINYINT(1) NOT NULL DEFAULT 1,
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (food_item_id),
    UNIQUE (restaurant_id, name),

    FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (category_id)
        REFERENCES food_categories(category_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (price > 0)
) ENGINE=InnoDB;


-- 6. CARTS
CREATE TABLE carts (
    cart_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    restaurant_id INT UNSIGNED NOT NULL,

    status ENUM('ACTIVE','CHECKED_OUT','ABANDONED')
        NOT NULL DEFAULT 'ACTIVE',

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    PRIMARY KEY (cart_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 7. CART ITEMS
CREATE TABLE cart_items (
    cart_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cart_id INT UNSIGNED NOT NULL,
    food_item_id INT UNSIGNED NOT NULL,
    quantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    added_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (cart_item_id),
    UNIQUE (cart_id, food_item_id),

    FOREIGN KEY (cart_id)
        REFERENCES carts(cart_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (food_item_id)
        REFERENCES food_items(food_item_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CHECK (quantity BETWEEN 1 AND 50)
) ENGINE=InnoDB;


-- 8. ORDERS
CREATE TABLE orders (
    order_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    address_id INT UNSIGNED NOT NULL,

    item_total DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10,2) NOT NULL,

    order_status ENUM(
        'PLACED',
        'CONFIRMED',
        'OUT_FOR_DELIVERY',
        'DELIVERED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'PLACED',

    placed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (order_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 9. ORDER RESTAURANTS
CREATE TABLE order_restaurants (
    order_restaurant_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id INT UNSIGNED NOT NULL,
    restaurant_id INT UNSIGNED NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,

    status ENUM(
        'PENDING',
        'ACCEPTED',
        'PREPARING',
        'READY',
        'PICKED_UP',
        'DELIVERED',
        'REJECTED'
    ) NOT NULL DEFAULT 'PENDING',

    PRIMARY KEY (order_restaurant_id),
    UNIQUE (order_id, restaurant_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 10. ORDER ITEMS
CREATE TABLE order_items (
    order_item_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_restaurant_id INT UNSIGNED NOT NULL,
    food_item_id INT UNSIGNED NOT NULL,

    item_name VARCHAR(120) NOT NULL,
    quantity SMALLINT UNSIGNED NOT NULL,
    price_at_order DECIMAL(8,2) NOT NULL,

    PRIMARY KEY (order_item_id),
    UNIQUE (order_restaurant_id, food_item_id),

    FOREIGN KEY (order_restaurant_id)
        REFERENCES order_restaurants(order_restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (food_item_id)
        REFERENCES food_items(food_item_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CHECK (quantity BETWEEN 1 AND 50),
    CHECK (price_at_order > 0)
) ENGINE=InnoDB;


-- 11. PAYMENTS
CREATE TABLE payments (
    payment_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id INT UNSIGNED NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    method ENUM(
        'UPI',
        'CARD',
        'NETBANKING',
        'WALLET',
        'COD'
    ) NOT NULL DEFAULT 'UPI',

    payment_status ENUM(
        'PENDING',
        'SUCCESS',
        'FAILED',
        'REFUNDED'
    ) NOT NULL DEFAULT 'PENDING',

    txn_reference VARCHAR(60),
    paid_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (payment_id),
    UNIQUE (order_id),
    UNIQUE (txn_reference),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 12. DELIVERY PARTNERS
CREATE TABLE delivery_partners (
    partner_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    phone CHAR(10) NOT NULL,

    vehicle_type ENUM(
        'BIKE',
        'SCOOTER',
        'BICYCLE'
    ) NOT NULL DEFAULT 'BIKE',

    vehicle_no VARCHAR(20),
    is_available TINYINT(1) NOT NULL DEFAULT 1,
    rating DECIMAL(2,1) NOT NULL DEFAULT 0.0,

    PRIMARY KEY (partner_id),
    UNIQUE (phone),
    UNIQUE (vehicle_no),

    CHECK (rating BETWEEN 0.0 AND 5.0)
) ENGINE=InnoDB;


-- 13. DELIVERIES
CREATE TABLE deliveries (
    delivery_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_restaurant_id INT UNSIGNED NOT NULL,
    partner_id INT UNSIGNED,

    delivery_status ENUM(
        'ASSIGNED',
        'PICKED_UP',
        'ON_THE_WAY',
        'DELIVERED',
        'FAILED'
    ) NOT NULL DEFAULT 'ASSIGNED',

    assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivered_at DATETIME,

    PRIMARY KEY (delivery_id),
    UNIQUE (order_restaurant_id),

    FOREIGN KEY (order_restaurant_id)
        REFERENCES order_restaurants(order_restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (partner_id)
        REFERENCES delivery_partners(partner_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- 14. REVIEWS
CREATE TABLE reviews (
    review_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT UNSIGNED NOT NULL,
    restaurant_id INT UNSIGNED NOT NULL,
    order_restaurant_id INT UNSIGNED NOT NULL,

    rating TINYINT UNSIGNED NOT NULL,
    comment VARCHAR(500),

    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (review_id),
    UNIQUE (order_restaurant_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (restaurant_id)
        REFERENCES restaurants(restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    FOREIGN KEY (order_restaurant_id)
        REFERENCES order_restaurants(order_restaurant_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB;
SHOW TABLES;




SELECT * FROM users;
INSERT INTO users
(user_id, full_name, email, phone, password_hash)
VALUES
(101, 'Ravi Kumar', 'ravi@gmail.com', '9876543210', 'ravi123'),
(102, 'Sneha Reddy', 'sneha@gmail.com', '9876543211', 'sneha123'),
(103, 'Arjun Mehta', 'arjun@gmail.com', '9876543212', 'arjun123');
SELECT * FROM users;
INSERT INTO addresses
(address_id, user_id, label, line1, line2, city, state, pincode, is_default)
VALUES
(1, 101, 'HOME', '12 MG Road', NULL, 'Hyderabad', 'Telangana', '500001', 1),
(2, 101, 'WORK', '45 Hitech City', NULL, 'Hyderabad', 'Telangana', '500081', 0),
(3, 102, 'HOME', '22 Banjara Hills', NULL, 'Hyderabad', 'Telangana', '500034', 1),
(4, 103, 'HOME', '18 Jubilee Hills', NULL, 'Hyderabad', 'Telangana', '500033', 1);
SELECT * FROM addresses;
USE food_delivery_test;

-- PART 5: RESTAURANTS
INSERT INTO restaurants
(restaurant_id, name, phone, email, address_line, city, pincode, rating)
VALUES
(1, 'Burger Adda', '9000000001', 'burgeradda@gmail.com',
 'Madhapur', 'Hyderabad', '500081', 4.3),

(2, 'Pizza Point', '9000000002', 'pizzapoint@gmail.com',
 'Hitech City', 'Hyderabad', '500081', 4.5),

(3, 'Biryani House', '9000000003', 'biryanihouse@gmail.com',
 'Banjara Hills', 'Hyderabad', '500034', 4.4);


-- PART 6: FOOD CATEGORIES
INSERT INTO food_categories
(category_id, category_name, description)
VALUES
(1, 'Starters', 'Starter dishes'),
(2, 'Main Course', 'Main course dishes'),
(3, 'Beverages', 'Drinks and beverages'),
(4, 'Desserts', 'Sweet dishes');


-- PART 7: FOOD ITEMS
INSERT INTO food_items
(food_item_id, restaurant_id, category_id, name, description,
 price, is_veg, is_available)
VALUES
(1, 1, 2, 'Veg Burger', 'Fresh vegetable burger',
 150.00, 1, 1),

(2, 1, 1, 'French Fries', 'Crispy golden fries',
 80.00, 1, 1),

(3, 1, 3, 'Cold Coffee', 'Chilled creamy coffee',
 120.00, 1, 1),

(4, 2, 2, 'Farmhouse Pizza', 'Vegetable loaded pizza',
 300.00, 1, 1),

(5, 2, 1, 'Garlic Bread', 'Crispy garlic bread',
 140.00, 1, 1),

(6, 2, 4, 'Choco Lava Cake', 'Chocolate lava cake',
 110.00, 1, 1),

(7, 3, 2, 'Chicken Biryani', 'Hyderabadi chicken biryani',
 280.00, 0, 1),

(8, 3, 3, 'Sweet Lassi', 'Sweet chilled lassi',
 90.00, 1, 1);
 
 SELECT * FROM restaurants;
 
 INSERT INTO delivery_partners
(partner_id, full_name, phone, vehicle_type, vehicle_no, is_available, rating)
VALUES
(301, 'Kiran Kumar', '9876543210', 'BIKE', 'TS09AB1234', 1, 4.5),
(302, 'Rahul Singh', '9876543211', 'SCOOTER', 'TS09CD5678', 1, 4.2);

INSERT INTO deliveries
(delivery_id, order_restaurant_id, partner_id, delivery_status)
VALUES
(4001, 9001, 301, 'ASSIGNED'),
(4002, 9002, 302, 'ASSIGNED');

INSERT INTO reviews
(review_id, user_id, restaurant_id, order_restaurant_id, rating, comment)
VALUES
(6001, 101, 1, 9001, 5, 'Good food and fast service'),
(6002, 101, 2, 9002, 4, 'Pizza was tasty');

SELECT * FROM food_categories;


/*MENU*/
SELECT
    f.food_item_id,
    r.name AS restaurant,
    f.name AS food_item,
    f.price
FROM food_items f
JOIN restaurants r
ON f.restaurant_id = r.restaurant_id
ORDER BY f.food_item_id;



USE food_delivery_test;

INSERT INTO carts
(cart_id, user_id, restaurant_id, status)
VALUES
(201, 101, 1, 'ACTIVE'),
(202, 101, 2, 'ACTIVE');
SELECT
    c.cart_id,
    u.full_name AS customer,
    r.name AS restaurant,
    c.status
FROM carts c
JOIN users u
    ON c.user_id = u.user_id
JOIN restaurants r
    ON c.restaurant_id = r.restaurant_id
ORDER BY c.cart_id;
/*add orders*/
INSERT INTO cart_items
(cart_item_id, cart_id, food_item_id, quantity)
VALUES
(1, 201, 1, 1),
(2, 201, 2, 1),
(3, 202, 4, 1);
SELECT
    ci.cart_item_id,
    c.cart_id,
    u.full_name AS customer,
    r.name AS restaurant,
    f.name AS food_item,
    ci.quantity,
    f.price,
    (ci.quantity * f.price) AS item_total
FROM cart_items ci
JOIN carts c
    ON ci.cart_id = c.cart_id
JOIN users u
    ON c.user_id = u.user_id
JOIN restaurants r
    ON c.restaurant_id = r.restaurant_id
JOIN food_items f
    ON ci.food_item_id = f.food_item_id
ORDER BY c.cart_id, ci.cart_item_id;

/*checking order*/
INSERT INTO orders
(order_id, user_id, address_id, item_total, delivery_fee, total_amount, order_status)
VALUES
(5001, 101, 1, 530.00, 0.00, 530.00, 'CONFIRMED');
SELECT
    o.order_id,
    u.full_name AS customer,
    o.item_total,
    o.delivery_fee,
    o.total_amount,
    o.order_status
FROM orders o
JOIN users u
ON o.user_id = u.user_id
WHERE o.order_id = 5001;

/*resto checking*/
INSERT INTO order_restaurants
(order_restaurant_id, order_id, restaurant_id, subtotal, status)
VALUES
(9001, 5001, 1, 230.00, 'PREPARING'),
(9002, 5001, 2, 300.00, 'ACCEPTED');
SELECT
    orr.order_restaurant_id,
    orr.order_id,
    r.name AS restaurant,
    orr.subtotal,
    orr.status
FROM order_restaurants orr
JOIN restaurants r
ON orr.restaurant_id = r.restaurant_id
WHERE orr.order_id = 5001;

INSERT INTO payments
(payment_id, order_id, amount, method, payment_status, txn_reference)
VALUES
(7001, 5001, 530.00, 'UPI', 'SUCCESS', 'TXN5001');
SELECT
    p.payment_id,
    p.order_id,
    p.amount,
    p.method,
    p.payment_status,
    p.txn_reference
FROM payments p
WHERE p.order_id = 5001;
UPDATE carts
SET status = 'CHECKED_OUT'
WHERE cart_id IN (201, 202);
SELECT
    c.cart_id,
    u.full_name AS customer,
    r.name AS restaurant,
    c.status
FROM carts c
JOIN users u
ON c.user_id = u.user_id
JOIN restaurants r
ON c.restaurant_id = r.restaurant_id
WHERE c.user_id = 101
ORDER BY c.cart_id;

INSERT INTO order_items
(order_item_id, order_restaurant_id, food_item_id, item_name, quantity, price_at_order)
VALUES
(1, 9001, 1, 'Veg Burger', 1, 150.00),
(2, 9001, 2, 'French Fries', 1, 80.00),
(3, 9002, 4, 'Farmhouse Pizza', 1, 300.00);
SELECT * FROM order_items;
SELECT
    o.order_id,
    u.full_name AS customer,
    r.name AS restaurant,
    oi.item_name,
    oi.quantity,
    oi.price_at_order,
    (oi.quantity * oi.price_at_order) AS item_total,
    orr.subtotal AS restaurant_subtotal,
    o.total_amount AS complete_checkout_total,
    p.method AS payment_method,
    p.payment_status,
    o.order_status
FROM orders o
JOIN users u
    ON o.user_id = u.user_id
JOIN order_restaurants orr
    ON o.order_id = orr.order_id
JOIN restaurants r
    ON orr.restaurant_id = r.restaurant_id
JOIN order_items oi
    ON orr.order_restaurant_id = oi.order_restaurant_id
JOIN payments p
    ON o.order_id = p.order_id
WHERE o.order_id = 5001
ORDER BY orr.order_restaurant_id;






SELECT * FROM users;

SELECT * FROM addresses;

SELECT * FROM restaurants;

SELECT * FROM food_categories;

SELECT * FROM food_items;

SELECT * FROM carts;

SELECT * FROM cart_items;

SELECT * FROM orders;

SELECT * FROM order_restaurants;

SELECT * FROM order_items;

SELECT * FROM payments;

SELECT * FROM delivery_partners;

SELECT * FROM deliveries;

SELECT * FROM reviews;



