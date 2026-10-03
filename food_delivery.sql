-- ============================================================
-- Food Delivery Platform - GPS & Live Delivery Tracking MySQL Dump
-- Generated on: 2026-10-02T15:14:59.952Z
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_restaurant_summary;
DROP VIEW IF EXISTS v_popular_items;
DROP VIEW IF EXISTS v_order_details;

DROP TABLE IF EXISTS vendor_notifications;
DROP TABLE IF EXISTS vendor_reviews;
DROP TABLE IF EXISTS vendor_offers;
DROP TABLE IF EXISTS user_notifications;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS order_restaurants;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS coupons;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS restaurant_menu_categories;
DROP TABLE IF EXISTS restaurant_cuisines;
DROP TABLE IF EXISTS restaurant_categories;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS user_addresses;
DROP TABLE IF EXISTS users;


CREATE TABLE users (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20),
  avatar TEXT,
  role VARCHAR(20) DEFAULT 'Customer',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_addresses (
  id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  title VARCHAR(100),
  tag VARCHAR(50),
  address_line TEXT NOT NULL,
  city VARCHAR(100) NOT NULL,
  pincode VARCHAR(20) NOT NULL,
  latitude DECIMAL(10,8) DEFAULT 17.4486,
  longitude DECIMAL(11,8) DEFAULT 78.3808,
  is_default TINYINT(1) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE categories (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  icon VARCHAR(10),
  image TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurants (
  id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  rating DECIMAL(3,2) DEFAULT 0.0,
  rating_count VARCHAR(50),
  delivery_time VARCHAR(50),
  delivery_fee DECIMAL(10,2) DEFAULT 0.00,
  min_order DECIMAL(10,2) DEFAULT 0.00,
  offer VARCHAR(150),
  image TEXT,
  banner TEXT,
  description TEXT,
  address TEXT,
  latitude DECIMAL(10,8) DEFAULT 17.4399,
  longitude DECIMAL(11,8) DEFAULT 78.3989,
  is_favorite TINYINT(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_categories (
  restaurant_id VARCHAR(50) NOT NULL,
  category_id VARCHAR(50) NOT NULL,
  PRIMARY KEY (restaurant_id, category_id),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_cuisines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  cuisine_name VARCHAR(100) NOT NULL,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE restaurant_menu_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  category_name VARCHAR(100) NOT NULL,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE menu_items (
  id VARCHAR(50) PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  restaurant_name VARCHAR(150),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  is_veg TINYINT(1) DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0.0,
  is_bestseller TINYINT(1) DEFAULT 0,
  category VARCHAR(100),
  image TEXT,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE coupons (
  code VARCHAR(50) PRIMARY KEY,
  discount DECIMAL(10,2) NOT NULL,
  min_subtotal DECIMAL(10,2) NOT NULL,
  type VARCHAR(20) NOT NULL,
  description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE orders (
  id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  address_id VARCHAR(50),
  created_at DATETIME NOT NULL,
  status VARCHAR(50) NOT NULL,
  delivery_status VARCHAR(50) DEFAULT 'ASSIGNED',
  partner_latitude DECIMAL(10,8) DEFAULT 17.4420,
  partner_longitude DECIMAL(11,8) DEFAULT 78.3910,
  location_updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  estimated_delivery VARCHAR(50),
  payment_method VARCHAR(50),
  subtotal DECIMAL(10,2) NOT NULL,
  delivery_fee DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0.00,
  total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (address_id) REFERENCES user_addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_restaurants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(50) NOT NULL,
  restaurant_id VARCHAR(50) NOT NULL,
  restaurant_name VARCHAR(150),
  status VARCHAR(50) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id VARCHAR(50) NOT NULL,
  order_restaurant_id INT NOT NULL,
  food_id VARCHAR(50),
  food_name VARCHAR(200) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  is_veg TINYINT(1) DEFAULT 0,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (order_restaurant_id) REFERENCES order_restaurants(id) ON DELETE CASCADE,
  FOREIGN KEY (food_id) REFERENCES menu_items(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE user_notifications (
  id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  time VARCHAR(50),
  is_read TINYINT(1) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vendor_offers (
  id VARCHAR(50) PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(200) NOT NULL,
  discount_type VARCHAR(20) NOT NULL,
  discount_value DECIMAL(10,2) NOT NULL,
  max_discount DECIMAL(10,2),
  min_subtotal DECIMAL(10,2),
  start_date DATE,
  end_date DATE,
  status VARCHAR(20) DEFAULT 'Active',
  usage_count INT DEFAULT 0,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vendor_reviews (
  id VARCHAR(50) PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  customer_name VARCHAR(100) NOT NULL,
  rating INT NOT NULL,
  date DATE NOT NULL,
  dish_name VARCHAR(200),
  comment TEXT,
  reply TEXT,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE vendor_notifications (
  id VARCHAR(50) PRIMARY KEY,
  restaurant_id VARCHAR(50) NOT NULL,
  title VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  timestamp VARCHAR(50),
  type VARCHAR(50),
  is_read TINYINT(1) DEFAULT 0,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Data
INSERT INTO users (id, name, email, phone, avatar, role) VALUES ('usr-101', 'Customer User', 'customer@foodfusion.com', '+91 98765 43210', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80', 'Customer');
INSERT INTO user_addresses (id, user_id, title, tag, address_line, city, pincode, latitude, longitude, is_default) VALUES ('addr-1', 'usr-101', 'Home Address', 'Home', 'Plot 42, Road No. 36, Jubilee Hills', 'Hyderabad', '500033', 17.4486, 78.3808, 1);
INSERT INTO user_addresses (id, user_id, title, tag, address_line, city, pincode, latitude, longitude, is_default) VALUES ('addr-2', 'usr-101', 'Work / Office', 'Work', '8th Floor, Cyber Towers, HITEC City', 'Hyderabad', '500081', 17.4486, 78.3808, 0);
INSERT INTO user_addresses (id, user_id, title, tag, address_line, city, pincode, latitude, longitude, is_default) VALUES ('addr-3', 'usr-101', 'College Campus', 'College', 'Hostel Block B, Gachibowli Campus', 'Hyderabad', '500032', 17.4486, 78.3808, 0);
INSERT INTO categories (id, name, icon, image) VALUES ('biryani', 'Hyderabadi Biryani', '🍲', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('pizza', 'Gourmet Pizza', '🍕', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('burgers', 'Smash Burgers', '🍔', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('kebabs', 'Kebabs & Tandoor', '🍢', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('indian', 'North Indian Curry', '🍛', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('southindian', 'South Indian Dosa', '🥘', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('chinese', 'Chinese & Noodles', '🥢', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('mexican', 'Mexican Tacos', '🌮', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('japanese', 'Sushi & Asian', '🍱', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('desserts', 'Cakes & Brownies', '🍰', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('beverages', 'Shakes & Drinks', '🥤', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO categories (id, name, icon, image) VALUES ('icecream', 'Artisanal Gelato', '🍨', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-1', 'Paradise Biryani', 4.9, '12k+ ratings', '25-35 mins', 30, 150, '20% OFF up to ₹120', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=1200&auto=format&fit=crop&q=80', 'World-famous authentic Hyderabadi Dum Biryani slow-cooked with royal spices and pure ghee.', 'Secunderabad & Jubilee Hills, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-1', 'biryani');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-1', 'kebabs');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-1', 'indian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-1', 'Hyderabadi Biryani');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-1', 'Kebabs & Tandoor');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-1', 'North Indian Curry');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-1', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-1', 'Biryani & Rice');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-1', 'Kebabs & Tandoor');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-1', 'Curries & Breads');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-1', 'Desserts & Drinks');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-100', 'rest-1', 'Paradise Biryani', 'Paradise Royal Feast Combo (Biryani + Kebab + Drink)', 'Royal Chicken Biryani + 2 Pcs Chicken Reshmi Kebab + Mirchi Ka Salan + Raita + Chilled Thums Up 500ml', 399, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-100v', 'rest-1', 'Paradise Biryani', 'Hyderabadi Veg Biryani Family Combo (Biryani + Paneer Tikka + Drink)', 'Veg Dum Biryani + Paneer Tikka 4 Pcs + Mirchi Ka Salan + Raita + 1.25L Thums Up', 349, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-101', 'rest-1', 'Paradise Biryani', 'Royal Chicken Dum Biryani', 'Fragrant basmati rice layered with juicy marinated chicken, served with Mirchi Ka Salan & Raita', 289, 0, 4.9, 1, 'Biryani & Rice', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-102', 'rest-1', 'Paradise Biryani', 'Special Mutton Dum Biryani', 'Tender tenderized lamb meat cooked in saffron basmati rice with caramelised onions', 369, 0, 4.9, 0, 'Biryani & Rice', 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-103', 'rest-1', 'Paradise Biryani', 'Paneer Tikka Dum Biryani', 'Chargrilled cottage cheese cubes cooked in rich saffron long-grain basmati rice', 239, 1, 4.7, 0, 'Biryani & Rice', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-104', 'rest-1', 'Paradise Biryani', 'Hyderabadi Veg Dum Biryani', 'Assorted seasonal vegetables slow-cooked in aromatic biryani spices and pure ghee', 219, 1, 4.6, 0, 'Biryani & Rice', 'https://images.unsplash.com/photo-1642821373181-696a14044e73?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-105', 'rest-1', 'Paradise Biryani', 'Hyderabadi Chicken 65', 'Deep fried spicy marinated chicken chunks tossed with curry leaves & green chilies', 249, 0, 4.8, 1, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-106', 'rest-1', 'Paradise Biryani', 'Tandoori Chicken Tikka (6 Pcs)', 'Smoky chicken breast cubes marinated in yogurt & red chili cooked over clay tandoor', 269, 0, 4.8, 0, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-107', 'rest-1', 'Paradise Biryani', 'Paneer Malai Tikka (6 Pcs)', 'Soft cottage cheese cubes marinated in rich cashew cream and green cardamom', 229, 1, 4.7, 0, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-108', 'rest-1', 'Paradise Biryani', 'Butter Chicken Masala', 'Tender boneless tandoori chicken simmered in rich tomato gravy with pure butter', 279, 0, 4.8, 1, 'Curries & Breads', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-109', 'rest-1', 'Paradise Biryani', 'Paneer Butter Masala', 'Fresh cottage cheese cubes cooked in spiced tomato butter gravy with fenugreek', 239, 1, 4.7, 0, 'Curries & Breads', 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-110', 'rest-1', 'Paradise Biryani', 'Butter Garlic Naan (2 Pcs)', 'Clay tandoor baked leavened flatbread brushed with fresh garlic butter', 79, 1, 4.9, 0, 'Curries & Breads', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-111', 'rest-1', 'Paradise Biryani', 'Hyderabadi Double Ka Meetha', 'Traditional Nizam dessert made with fried bread soaked in saffron milk & dry fruits', 119, 1, 4.8, 0, 'Desserts & Drinks', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-2', 'Pizza Palace', 4.8, '4.5k+ ratings', '20-30 mins', 25, 150, '50% OFF up to ₹100', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1579751626657-72bc17010498?w=1200&auto=format&fit=crop&q=80', 'Authentic wood-fired Italian pizzas, cheesy garlic breads, and hand-tossed pasta.', 'Road No. 36, Jubilee Hills, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-2', 'pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2', 'Gourmet Pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2', 'Italian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2', 'Shakes & Drinks');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2', 'Gourmet Pizzas');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2', 'Starters & Sides');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2', 'Pastas & Drinks');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-200', 'rest-2', 'Pizza Palace', 'Family Pizza Party Combo (2 Large Pizzas + Garlic Bread + Drink)', '1 Margherita + 1 Pepperoni Feast + Cheesy Stuffed Garlic Bread + 1.25L Coca-Cola', 699, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-200v', 'rest-2', 'Pizza Palace', 'Veggie Deluxe Feast Combo (1 Large Pizza + Stuffed Garlic Bread + Shake)', 'Farmhouse Veggie Pizza + Cheesy Stuffed Garlic Bread + Belgian Choco Shake', 499, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-201', 'rest-2', 'Pizza Palace', 'Margherita Gourmet Pizza', 'Classic delight with 100% real Italian mozzarella, fresh basil & San Marzano sauce', 249, 1, 4.8, 1, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-202', 'rest-2', 'Pizza Palace', 'Pepperoni Feast Pizza', 'Loaded with premium smoked pepperoni, extra mozzarella cheese, and chili flakes', 349, 0, 4.9, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-203', 'rest-2', 'Pizza Palace', 'BBQ Smoked Chicken Pizza', 'Tender grilled barbecue chicken chunks, red paprika, onion & mozzarella cheese', 329, 0, 4.8, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-204', 'rest-2', 'Pizza Palace', 'Farmhouse Fresh Veggie Pizza', 'Loaded with crunchy bell peppers, sweet corn, mushrooms, olives & fresh mozzarella', 289, 1, 4.7, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-205', 'rest-2', 'Pizza Palace', 'Cheesy Stuffed Garlic Bread', 'Freshly baked garlic bread stuffed with liquid cheese dip & Italian herbs', 149, 1, 4.9, 1, 'Starters & Sides', 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-206', 'rest-2', 'Pizza Palace', 'Fiery Peri Peri Chicken Wings (6 Pcs)', 'Crispy fried chicken wings coated in hot peri peri spicy marinade', 219, 0, 4.8, 0, 'Starters & Sides', 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-207', 'rest-2', 'Pizza Palace', 'Creamy Alfredo Chicken Pasta', 'Penne pasta tossed in rich white parmesan cream sauce with herb grilled chicken', 269, 0, 4.7, 0, 'Pastas & Drinks', 'https://images.unsplash.com/photo-1621996346565-e3d5d6281288?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-208', 'rest-2', 'Pizza Palace', 'Penne Arrabbiata Red Sauce Pasta', 'Penne tossed in spicy garlic tomato basil sauce with black olives & chili flakes', 229, 1, 4.6, 0, 'Pastas & Drinks', 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-209', 'rest-2', 'Pizza Palace', 'Belgian Chocolate Shake', 'Rich dark Belgian chocolate blended with creamy ice cream & chocolate fudge', 139, 1, 4.8, 0, 'Pastas & Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-2a', 'La Pino''s Gourmet Pizza', 4.7, '3.8k+ ratings', '25-35 mins', 20, 150, 'FLAT ₹120 OFF', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=1200&auto=format&fit=crop&q=80', 'Giant slice Italian pizzas loaded with liquid cheese, toppings and fiery seasonings.', 'Madhapur, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-2a', 'pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2a', 'Gourmet Pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2a', 'Italian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2a', 'Fast Food');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2a', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2a', 'Gourmet Pizzas');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2a', 'Sides & Dips');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2a', 'Drinks & Desserts');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a0', 'rest-2a', 'La Pino''s Gourmet Pizza', 'La Pino''s Monster Slice Combo (2 Slices + Garlic Bread + Coke)', '1 Chicken Tikka Slice + 1 7-Cheese Slice + Cheesy Garlic Bread + 500ml Coca-Cola', 389, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a0v', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Double Cheese Pizza Combo (Medium Pizza + Fries + Dip)', 'Medium 7-Cheese Pizza + Peri Peri Fries + House Garlic Dip', 359, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a1', 'rest-2a', 'La Pino''s Gourmet Pizza', '7 Cheese Molten Lava Pizza', 'Blended Mozzarella, Cheddar, Gouda, Parmesan, Orange Cheese & Liquid Dip', 329, 1, 4.8, 1, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a2', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Chicken Tikka Butter Masala Pizza', 'Tandoori chicken tikka chunks in spiced butter gravy on crispy hand-tossed crust', 359, 0, 4.9, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a3', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Burn To Hell Spicy Pizza', 'Fiery red paprika, jalapeños, red chili flakes & liquid cheddar cheese dip', 339, 1, 4.7, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a4', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Mutton Seekh Kebab Gourmet Pizza', 'Minced mutton seekh kebab, red onions, mozzarella cheese & peri peri drizzle', 389, 0, 4.8, 0, 'Gourmet Pizzas', 'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a5', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Cheesy Garlic Jalapeño Sticks', 'Freshly baked garlic dough sticks stuffed with green jalapeños & cheese', 139, 1, 4.7, 0, 'Sides & Dips', 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a6', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Crispy Peri Peri French Fries', 'Golden potato fries seasoned with signature hot peri peri spice mix', 119, 1, 4.8, 0, 'Sides & Dips', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a7', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Molten Choco Lava Cake', 'Warm chocolate cake with soft molten liquid dark chocolate fudge inside', 99, 1, 4.9, 1, 'Drinks & Desserts', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2a8', 'rest-2a', 'La Pino''s Gourmet Pizza', 'Chilled Mountain Dew (500ml)', 'Chilled carbonated citrus refresher bottle', 60, 1, 4.6, 0, 'Drinks & Desserts', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-2b', 'Ovenstory Woodfired Pizza', 4.8, '2.9k+ ratings', '20-30 mins', 25, 150, 'FLAT ₹100 OFF', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=1200&auto=format&fit=crop&q=80', 'Signature wood-fired crusts topped with Peri-Peri cheese sauce, jalapeños & olives.', 'Gachibowli, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-2b', 'pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2b', 'Gourmet Pizza');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-2b', 'Italian');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2b', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2b', 'Woodfired Pizzas');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2b', 'Sides & Garlic Breads');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-2b', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b0', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Woodfired Couple Feast Combo (2 Medium Pizzas + Garlic Bread + 2 Drinks)', '1 Spicy Lamb Pizza + 1 Margherita + Cheese Garlic Bread + 2 Cold Drinks', 599, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b0v', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Peri Peri Veggie Combo (Pizza + Stuffed Garlic Bread + Dip)', 'Tandoori Paneer Woodfired Pizza + Overloaded Garlic Bread + Peri Peri Dip', 399, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b1', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Middle Eastern Spicy Lamb Pizza', 'Minced spiced lamb kebab meat, red paprika, caramelised onions & mozzarella', 379, 0, 4.8, 1, 'Woodfired Pizzas', 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b2', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Smokey BBQ Chicken Woodfired Pizza', 'Barbecue chicken, red onions, charred bell peppers & liquid gouda cheese', 349, 0, 4.8, 0, 'Woodfired Pizzas', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b3', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Four Cheese Margherita Woodfired Pizza', 'Mozzarella, Cheddar, Gouda & Parmesan cheese blend on crispy woodfired crust', 279, 1, 4.7, 0, 'Woodfired Pizzas', 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b4', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Tandoori Paneer Melt Woodfired Pizza', 'Spiced paneer tikka, capsicum, red paprika & tandoori mayonnaise drizzle', 299, 1, 4.8, 0, 'Woodfired Pizzas', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b5', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Overloaded Cheese Garlic Bread', 'Crispy garlic loaf loaded with melted mozzarella & oregano seasoning', 159, 1, 4.9, 1, 'Sides & Garlic Breads', 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b6', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Spicy Chicken Strips (5 Pcs)', 'Crispy boneless chicken tender strips served with spicy garlic mayo dip', 199, 0, 4.7, 0, 'Sides & Garlic Breads', 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b7', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Hazelnut Cold Brew Coffee', 'Chilled slow brewed arabica coffee infused with hazelnut syrup', 129, 1, 4.8, 0, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-2b8', 'rest-2b', 'Ovenstory Woodfired Pizza', 'Iced Peach Green Tea', 'Refreshing iced green tea blended with sweet natural peach extract', 99, 1, 4.6, 0, 'Beverages', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-3', 'Burger House', 4.7, '5.1k+ ratings', '20-30 mins', 25, 100, 'FLAT ₹75 OFF', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200&auto=format&fit=crop&q=80', 'Juicy handcrafted gourmet smash burgers, peri peri fries, and thick milkshakes.', 'Banjara Hills, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-3', 'burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3', 'Smash Burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3', 'American');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3', 'Shakes & Drinks');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3', 'Smash Burgers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3', 'Sides & Fries');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3', 'Thick Milkshakes');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-300', 'rest-3', 'Burger House', 'Ultimate Smash Combo (Burger + Fries + Shake)', 'Classic Chicken Crunch Burger + Peri Peri Crispy Fries + Belgian Chocolate Shake', 299, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-300v', 'rest-3', 'Burger House', 'Crispy Veggie Deluxe Combo (Veg Burger + Peri Peri Fries + Drink)', 'Crispy Cottage Cheese Veg Burger + Large Peri Peri Fries + Chilled Coke', 249, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-301', 'rest-3', 'Burger House', 'Classic Chicken Crunch Burger', 'Crispy double fried chicken patty topped with fresh lettuce, garlic mayo, and pickles', 189, 0, 4.7, 1, 'Smash Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-302', 'rest-3', 'Burger House', 'Double Beef Bacon Cheeseburger', 'Two grass-fed smashed beef patties, smoked bacon, american cheddar & house smash sauce', 279, 0, 4.9, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-303', 'rest-3', 'Burger House', 'Crispy Cottage Cheese Paneer Burger', 'Deep fried crunchy spiced paneer slab, chipotle mayo, iceberg lettuce & tomatoes', 169, 1, 4.7, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-304', 'rest-3', 'Burger House', 'Spicy Jalapeño Veggie Smash Burger', 'Spiced potato corn patty, sliced green jalapeños, melted cheese & fiery sriracha', 159, 1, 4.6, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-305', 'rest-3', 'Burger House', 'Crispy Peri Peri Fries', 'Golden potato skin fries dusted with hot peri peri chili seasoning', 109, 1, 4.8, 1, 'Sides & Fries', 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-306', 'rest-3', 'Burger House', 'Cheesy Bacon Loaded Fries', 'Crispy french fries topped with melted cheddar cheese sauce & crispy bacon bits', 169, 0, 4.8, 0, 'Sides & Fries', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-307', 'rest-3', 'Burger House', 'Thick Oreo Cookies Shake', 'Blended oreo cookies, vanilla ice cream, whipped cream & chocolate syrup drizzle', 139, 1, 4.9, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-308', 'rest-3', 'Burger House', 'Rich Mango Cream Shake', 'Pure Alphonso mango pulp churned with chilled whole milk & ice cream', 129, 1, 4.7, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-3a', 'The Smash Club', 4.8, '2.4k+ ratings', '20-30 mins', 20, 120, '20% OFF on Combos', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=1200&auto=format&fit=crop&q=80', 'Double patty smash burgers with crispy caramelized lace edges & special house dip.', 'HITEC City, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-3a', 'burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3a', 'Smash Burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3a', 'Fast Food');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3a', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3a', 'Smash Burgers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3a', 'Loaded Fries & Wings');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3a', 'Drinks');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a0', 'rest-3a', 'The Smash Club', 'Smash Club Duo Combo (2 Smash Burgers + Large Fries + 2 Shakes)', '1 Double Beef Smash + 1 Chicken Smash + Cheesy Fries + 2 Belgian Milkshakes', 499, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a0v', 'rest-3a', 'The Smash Club', 'Veggie Smash Combo (Burger + Onion Rings + Dip + Soda)', 'Truffle Mushroom Veg Burger + Beer Battered Onion Rings + Garlic Mayo + Soda', 269, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a1', 'rest-3a', 'The Smash Club', 'Monster Double Patty Smash Burger', 'Two grass-fed beef smash patties, double american cheese, grilled onions & smash sauce', 269, 0, 4.9, 1, 'Smash Burgers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a2', 'rest-3a', 'The Smash Club', 'Smoky Chipotle Chicken Smash Burger', 'Crispy fried chicken breast, smoked chipotle sauce, pickled cucumbers & brioche bun', 219, 0, 4.8, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a3', 'rest-3a', 'The Smash Club', 'Truffle Mushroom Veg Smash Burger', 'Sauteed portobello mushrooms, Swiss cheese, truffle aioli & crispy lettuce', 199, 1, 4.7, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a4', 'rest-3a', 'The Smash Club', 'Crispy Hashbrown Veggie Burger', 'Golden potato hashbrown, cheddar cheese, spiced ranch & toasted sesame bun', 169, 1, 4.6, 0, 'Smash Burgers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a5', 'rest-3a', 'The Smash Club', 'Beer Battered Crispy Onion Rings', 'Thick sliced yellow onions dipped in craft beer batter and deep fried', 129, 1, 4.8, 1, 'Loaded Fries & Wings', 'https://images.unsplash.com/photo-1639024471283-03518883512d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a6', 'rest-3a', 'The Smash Club', 'Smokey BBQ Chicken Wings (6 Pcs)', 'Juicy bone-in wings tossed in hickory smoked BBQ sauce with ranch dip', 229, 0, 4.8, 0, 'Loaded Fries & Wings', 'https://images.unsplash.com/photo-1567620832903-9fc6debc209f?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a7', 'rest-3a', 'The Smash Club', 'Signature House Garlic Mayo Dip', 'Creamy roasted garlic and herb dipping sauce bowl', 39, 1, 4.9, 0, 'Loaded Fries & Wings', 'https://images.unsplash.com/photo-1619535860434-ba1d8fa12536?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3a8', 'rest-3a', 'The Smash Club', 'Chilled Red Bull Energy Drink', 'Original Red Bull energy drink can (250ml)', 160, 1, 4.7, 0, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-3b', 'TGI Smash Burgers', 4.6, '1.9k+ ratings', '25-35 mins', 25, 150, 'Buy 1 Get 1 Fries', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=1200&auto=format&fit=crop&q=80', 'American style gourmet smash burgers with brioche buns and molten swiss cheese.', 'Jubilee Hills, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-3b', 'burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3b', 'Smash Burgers');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-3b', 'American');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3b', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3b', 'Gourmet Burgers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3b', 'Sides');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-3b', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b0', 'rest-3b', 'TGI Smash Burgers', 'TGI Feast Combo (Gourmet Burger + Waffle Fries + Shake)', 'Angus Beef Swiss Burger + Crispy Waffle Fries + Dark Chocolate Milkshake', 379, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b0v', 'rest-3b', 'TGI Smash Burgers', 'Garden Fresh Veggie Combo (Burger + Sweet Potato Fries + Soda)', 'Black Bean Guacamole Veg Burger + Sweet Potato Fries + Chilled Soda', 289, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b1', 'rest-3b', 'TGI Smash Burgers', 'Truffle Mushroom Swiss Burger', 'Sauteed mushrooms, melted Swiss cheese, truffle aioli & crispy lettuce on toasted brioche', 249, 1, 4.7, 1, 'Gourmet Burgers', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b2', 'rest-3b', 'TGI Smash Burgers', 'Angus Beef Double Swiss Burger', 'Double Angus beef smash patties, double swiss cheese, caramelized onions & dijon mayo', 299, 0, 4.9, 0, 'Gourmet Burgers', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b3', 'rest-3b', 'TGI Smash Burgers', 'Crispy Buttermilk Fried Chicken Burger', 'Southern style buttermilk fried chicken thigh, spicy coleslaw & honey mustard sauce', 229, 0, 4.8, 0, 'Gourmet Burgers', 'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b4', 'rest-3b', 'TGI Smash Burgers', 'Black Bean Spicy Guacamole Veg Burger', 'Housemade spiced black bean patty, fresh guacamole, jalapeños & pepper jack cheese', 189, 1, 4.6, 0, 'Gourmet Burgers', 'https://images.unsplash.com/photo-1586190848861-99aa4a171e90?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b5', 'rest-3b', 'TGI Smash Burgers', 'Crispy Waffle Lattice Fries', 'Crispy criss-cross cut potato waffle fries served with chipotle dipping sauce', 139, 1, 4.8, 1, 'Sides', 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b6', 'rest-3b', 'TGI Smash Burgers', 'Cheesy Mozzarella Sticks (5 Pcs)', 'Golden fried breaded mozzarella cheese sticks served with marinara sauce', 179, 1, 4.7, 0, 'Sides', 'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b7', 'rest-3b', 'TGI Smash Burgers', 'Dark Chocolate Milkshake', 'Thick churned dark cocoa ice cream milkshake with whipped cream topping', 149, 1, 4.8, 0, 'Beverages', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-3b8', 'rest-3b', 'TGI Smash Burgers', 'Fresh Strawberry Cream Smoothie', 'Chilled strawberries blended with fresh milk & vanilla cream', 139, 1, 4.7, 0, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-4', 'Bawarchi Biryani', 4.8, '15k+ ratings', '25-35 mins', 30, 180, 'FLAT ₹100 OFF', 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=1200&auto=format&fit=crop&q=80', 'RTC X Roads iconic Hyderabadi Mutton & Chicken Biryani with authentic spiced gravy.', 'RTC X Roads, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-4', 'biryani');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-4', 'indian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-4', 'Hyderabadi Biryani');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-4', 'North Indian Curry');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-4', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-4', 'Biryani');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-4', 'Starters & Kebabs');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-4', 'Curries & Desserts');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-400', 'rest-4', 'Bawarchi Biryani', 'Bawarchi Family Biryani Combo (Mutton Biryani + Chicken 65 + Drink)', 'Bawarchi Special Mutton Dum Biryani + Hyderabadi Chicken 65 + 2 Thums Up Bottles', 499, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-400v', 'rest-4', 'Bawarchi Biryani', 'Veg Biryani Feast Combo (Veg Biryani + Paneer 65 + Cold Drink)', 'Bawarchi Veg Dum Biryani + Paneer 65 Fry + Salan + Raita + 1L Thums Up', 359, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-401', 'rest-4', 'Bawarchi Biryani', 'Bawarchi Special Chicken Biryani', 'Authentic RTC X Roads spicy chicken biryani served with raita and brinjal curry', 269, 0, 4.8, 1, 'Biryani', 'https://images.unsplash.com/photo-1633945274405-b6c8069047b0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-402', 'rest-4', 'Bawarchi Biryani', 'RTC X Roads Special Mutton Biryani', 'Slow cooked tender mutton chunks layered with saffron long grain basmati rice', 359, 0, 4.9, 0, 'Biryani', 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-403', 'rest-4', 'Bawarchi Biryani', 'Egg Dum Biryani', 'Boiled eggs cooked in rich biryani gravy and fragrant spiced saffron rice', 199, 0, 4.6, 0, 'Biryani', 'https://images.unsplash.com/photo-1642821373181-696a14044e73?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-404', 'rest-4', 'Bawarchi Biryani', 'Bawarchi Veg Dum Biryani', 'Fresh vegetables, cottage cheese & fried cashew nuts slow cooked in dum handi', 209, 1, 4.7, 0, 'Biryani', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-405', 'rest-4', 'Bawarchi Biryani', 'Hyderabadi Chicken 65 (RTC X Roads Style)', 'Iconic spicy red chicken fry with curry leaves, mustard seeds & slit chilies', 239, 0, 4.9, 1, 'Starters & Kebabs', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-406', 'rest-4', 'Bawarchi Biryani', 'Paneer 65 Crispy Fry', 'Crispy fried cottage cheese cubes tossed in spicy yogurt garlic sauce', 219, 1, 4.7, 0, 'Starters & Kebabs', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-407', 'rest-4', 'Bawarchi Biryani', 'Tangdi Kebab (3 Pcs)', 'Chicken drumsticks marinated in aromatic spices and chargrilled over coal', 259, 0, 4.8, 0, 'Starters & Kebabs', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-408', 'rest-4', 'Bawarchi Biryani', 'Mutton Rogan Josh Gravy', 'Traditional Kashmiri style slow cooked lamb curry with Kashmiri chili oil', 329, 0, 4.8, 0, 'Curries & Desserts', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-409', 'rest-4', 'Bawarchi Biryani', 'Kadai Paneer Gravy', 'Fresh cottage cheese cubes cooked with capsicum, tomatoes & crushed coriander seeds', 229, 1, 4.7, 0, 'Curries & Desserts', 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-410', 'rest-4', 'Bawarchi Biryani', 'Shahi Qubani Ka Meetha', 'Rich stewed Hyderabadi apricot dessert topped with fresh rabri and almonds', 129, 1, 4.9, 1, 'Curries & Desserts', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-5', 'Chinese Wok', 4.6, '2.8k+ ratings', '20-30 mins', 20, 150, 'Free Dim Sums on ₹350+', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=1200&auto=format&fit=crop&q=80', 'Sizzling wok noodles, Manchurian bowls, steamed dim sums, and spicy Schezwan dishes.', 'HITEC City, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-5', 'chinese');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-5', 'Chinese & Noodles');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-5', 'Asian');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-5', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-5', 'Noodles & Rice');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-5', 'Dim Sums & Starters');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-5', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-500', 'rest-5', 'Chinese Wok', 'Wok Meal Box Combo (Noodles + Manchurian + Dim Sums)', 'Schezwan Hakka Noodles + Veg Manchurian Gravy + 3 Pcs Steamed Dim Sums', 319, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-500n', 'rest-5', 'Chinese Wok', 'Dragon Chicken Wok Combo (Fried Rice + Chilli Chicken + Spring Rolls)', 'Chicken Egg Fried Rice + Chilli Chicken Gravy + 2 Spring Rolls', 369, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-501', 'rest-5', 'Chinese Wok', 'Hakka Veg Schezwan Noodles', 'Wok-tossed noodles with shredded peppers, spring onion and fiery Schezwan glaze', 169, 1, 4.6, 1, 'Noodles & Rice', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-502', 'rest-5', 'Chinese Wok', 'Chicken Egg Fried Rice', 'Wok tossed aromatic jasmine rice with scrambled egg, shredded chicken & garlic oil', 199, 0, 4.8, 0, 'Noodles & Rice', 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-503', 'rest-5', 'Chinese Wok', 'Singapore Spicy Non-Veg Noodles', 'Curry spiced thin rice vermicelli noodles tossed with prawns, chicken & egg', 219, 0, 4.7, 0, 'Noodles & Rice', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-504', 'rest-5', 'Chinese Wok', 'Steamed Veg Dim Sums (6 Pcs)', 'Delicate dough dumplings stuffed with cabbage, carrot & water chestnut', 149, 1, 4.7, 1, 'Dim Sums & Starters', 'https://images.unsplash.com/photo-1541696432-82c6da8ce7bf?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-505', 'rest-5', 'Chinese Wok', 'Crispy Veg Spring Rolls (4 Pcs)', 'Golden fried crispy wrappers stuffed with seasoned julienne glass noodles & veggies', 139, 1, 4.6, 0, 'Dim Sums & Starters', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-506', 'rest-5', 'Chinese Wok', 'Fiery Chilli Chicken Dry', 'Batter fried chicken cubes tossed with bell peppers, green chilies & soy sauce glaze', 229, 0, 4.8, 0, 'Dim Sums & Starters', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-507', 'rest-5', 'Chinese Wok', 'Veg Manchurian Gravy Bowl', 'Crispy vegetable dumplings simmered in dark garlic soy coriander sauce', 179, 1, 4.7, 0, 'Dim Sums & Starters', 'https://images.unsplash.com/photo-1585032226651-759b368d7246?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-508', 'rest-5', 'Chinese Wok', 'Iced Lemon Mint Tea', 'Chilled black tea infused with fresh lemon juice & crushed mint leaves', 89, 1, 4.7, 0, 'Beverages', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-6', 'Dosa Kingdom', 4.8, '6.2k+ ratings', '15-25 mins', 20, 100, 'FLAT ₹50 OFF', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=1200&auto=format&fit=crop&q=80', 'Crispy Golden Masala Dosa, Soft Steamed Idli, Medu Vada, and Filter Coffee.', 'Gachibowli, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-6', 'southindian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-6', 'South Indian Dosa');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-6', 'Breakfast');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-6', 'Shakes & Drinks');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-6', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-6', 'Dosa Specialties');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-6', 'Idli & Vada');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-6', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-600', 'rest-6', 'Dosa Kingdom', 'South Indian Tiffin Combo (Dosa + Idli + Vada + Coffee)', 'Mini Ghee Masala Dosa + 2 Steamed Idlis + 1 Crisp Medu Vada + Filter Coffee', 199, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-600a', 'rest-6', 'Dosa Kingdom', 'Royal Ghee Masala Combo (Rava Dosa + Mini Idli + Filter Coffee)', 'Crispy Rava Onion Dosa + 4 Button Idlis in Sambar + Kumbakonam Filter Coffee', 229, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-601', 'rest-6', 'Dosa Kingdom', 'Special Ghee Butter Masala Dosa', 'Crispy crepe stuffed with spiced potato masala, served with 3 chutneys & sambar', 149, 1, 4.8, 1, 'Dosa Specialties', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-602', 'rest-6', 'Dosa Kingdom', 'Crispy Rava Onion Dosa', 'Lacy semolina crepe roasted with finely chopped onions, green chilies & cumin', 139, 1, 4.7, 0, 'Dosa Specialties', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-603', 'rest-6', 'Dosa Kingdom', 'Paneer Cheese Burst Dosa', 'Golden crispy dosa stuffed with spiced cottage cheese & melted mozzarella', 179, 1, 4.8, 0, 'Dosa Specialties', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-604', 'rest-6', 'Dosa Kingdom', 'Mysore Masala Spicy Dosa', 'Crispy dosa smeared with fiery red garlic chili chutney & spiced potato filling', 159, 1, 4.7, 0, 'Dosa Specialties', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-605', 'rest-6', 'Dosa Kingdom', 'Steamed Button Idli in Sambar (8 Pcs)', 'Mini fluffy steamed rice cakes submerged in hot aromatic lentil vegetable sambar', 99, 1, 4.9, 1, 'Idli & Vada', 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-606', 'rest-6', 'Dosa Kingdom', 'Crispy Medu Vada (2 Pcs)', 'Deep fried savory black lentil doughnut fritters with coconut chutney', 89, 1, 4.7, 0, 'Idli & Vada', 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-607', 'rest-6', 'Dosa Kingdom', 'Traditional Kumbakonam Filter Coffee', 'Authentic South Indian chicory infused frothed hot milk coffee served in davara', 49, 1, 4.9, 1, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-608', 'rest-6', 'Dosa Kingdom', 'Chilled Badam Milk', 'Sweetened milk simmered with crushed almonds, cardamom & saffron strands', 69, 1, 4.7, 0, 'Beverages', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-7', 'Kebabs & Co.', 4.9, '3.4k+ ratings', '25-35 mins', 30, 200, 'Free Naan Basket on ₹400+', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=1200&auto=format&fit=crop&q=80', 'Juicy tandoori chicken seekh kebabs, malai tikka, and garlic butter naans.', 'Madhapur, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-7', 'kebabs');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-7', 'indian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-7', 'Kebabs & Tandoor');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-7', 'North Indian Curry');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-7', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-7', 'Kebabs & Tandoor');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-7', 'Curries & Breads');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-7', 'Drinks');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-700', 'rest-7', 'Kebabs & Co.', 'Royal Kebab Platter Combo (Seekh + Tikka + Naan + Drink)', 'Chicken Seekh 2 Pcs + Reshmi Tikka 2 Pcs + Garlic Butter Naan + Lassi', 449, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-700v', 'rest-7', 'Kebabs & Co.', 'Paneer Tikka Feast Combo (Paneer Tikka + Dal Makhani + Butter Naan)', 'Tandoori Paneer Tikka 4 Pcs + Creamy Dal Makhani + 2 Butter Naans', 369, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-701', 'rest-7', 'Kebabs & Co.', 'Tandoori Chicken Seekh Kebab (4 Pcs)', 'Smoky minced chicken skewers cooked over hot clay tandoor coals', 229, 0, 4.9, 1, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-702', 'rest-7', 'Kebabs & Co.', 'Chicken Malai Reshmi Kebab (6 Pcs)', 'Melt-in-mouth tender chicken cubes marinated in cashew cream & cardamom', 269, 0, 4.8, 0, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-703', 'rest-7', 'Kebabs & Co.', 'Tandoori Paneer Tikka (6 Pcs)', 'Cottage cheese cubes marinated in mustard oil & tandoori masala', 219, 1, 4.7, 0, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-704', 'rest-7', 'Kebabs & Co.', 'Mutton Galouti Kebab (4 Pcs)', 'Lucknowi melt in mouth minced mutton patties served with ulte tawe ka paratha', 319, 0, 4.9, 1, 'Kebabs & Tandoor', 'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-705', 'rest-7', 'Kebabs & Co.', 'Creamy Dal Makhani Gravy', 'Overnight slow cooked black lentils enriched with butter & white cream', 199, 1, 4.8, 0, 'Curries & Breads', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-706', 'rest-7', 'Kebabs & Co.', 'Chicken Tikka Masala Gravy', 'Smoky chicken tikka chunks cooked in spicy onion tomato gravy', 279, 0, 4.8, 0, 'Curries & Breads', 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-707', 'rest-7', 'Kebabs & Co.', 'Butter Garlic Naan (2 Pcs)', 'Tandoor baked white flour bread brushed with garlic butter', 79, 1, 4.9, 0, 'Curries & Breads', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-708', 'rest-7', 'Kebabs & Co.', 'Fresh Sweet Lassi', 'Thick churned sweet yogurt drink topped with malai & rose water syrup', 69, 1, 4.7, 0, 'Drinks', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-8', 'Taco Fiesta', 4.7, '1.9k+ ratings', '20-30 mins', 25, 150, 'FLAT ₹60 OFF', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=1200&auto=format&fit=crop&q=80', 'Crispy corn shell tacos, stuffed burritos, cheesy quesadillas, and loaded nachos.', 'Gachibowli, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-8', 'mexican');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-8', 'Mexican Tacos');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-8', 'Fast Food');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-8', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-8', 'Mexican Tacos');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-8', 'Burritos & Quesadillas');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-8', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-800', 'rest-8', 'Taco Fiesta', 'Fiesta Taco Box Combo (3 Tacos + Loaded Nachos + Mexican Soda)', '2 Chicken Tacos + 1 Veg Taco + Cheesy Nachos + Horchata Soda', 399, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-800v', 'rest-8', 'Taco Fiesta', 'Veggie Burrito Meal Combo (Burrito + Churros + Iced Tea)', 'Cheesy Paneer Burrito + 2 Cinnamon Churros + Peach Iced Tea', 329, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-801', 'rest-8', 'Taco Fiesta', 'Loaded Chicken Crunch Tacos (3 Pcs)', 'Hard corn tortillas stuffed with seasoned chicken, salsa, sour cream & grated cheese', 219, 0, 4.8, 1, 'Mexican Tacos', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-802', 'rest-8', 'Taco Fiesta', 'Crispy Bean & Cheese Tacos (3 Pcs)', 'Refried pinto beans, melted cheddar cheese, pico de gallo & shredded lettuce', 179, 1, 4.7, 0, 'Mexican Tacos', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-803', 'rest-8', 'Taco Fiesta', 'Fiery Shredded Beef Tacos (3 Pcs)', 'Slow cooked spicy shredded beef, jalapeños, chipotle sauce & Monterey Jack cheese', 249, 0, 4.9, 0, 'Mexican Tacos', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-804', 'rest-8', 'Taco Fiesta', 'Overloaded Chicken Burrito Bowl', 'Cilantro lime rice, black beans, grilled chicken, fresh guacamole, corn & salsa', 259, 0, 4.8, 0, 'Burritos & Quesadillas', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-805', 'rest-8', 'Taco Fiesta', 'Cheesy Paneer Corn Quesadilla', 'Grilled flour tortilla folded with spiced cottage cheese, sweet corn & melted cheese', 219, 1, 4.7, 0, 'Burritos & Quesadillas', 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-806', 'rest-8', 'Taco Fiesta', 'Loaded Cheese Nachos with Guacamole', 'Crispy corn tortilla chips drenched in warm queso cheese & fresh guacamole dip', 169, 1, 4.9, 1, 'Burritos & Quesadillas', 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-807', 'rest-8', 'Taco Fiesta', 'Cinnamon Sugar Crispy Churros (4 Pcs)', 'Mexican fried dough pastry sticks dusted with cinnamon sugar & chocolate fudge dip', 129, 1, 4.8, 0, 'Beverages', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-808', 'rest-8', 'Taco Fiesta', 'Mexican Chilled Horchata Drink', 'Traditional creamy rice milk drink flavoured with cinnamon, vanilla & almond', 99, 1, 4.7, 0, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-9', 'Sushi Master', 4.9, '1.2k+ ratings', '30-45 mins', 40, 300, 'Free Miso Soup on ₹500+', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=1200&auto=format&fit=crop&q=80', 'Fresh artisanal sushi rolls, salmon sashimi, ramen bowls, and tempura platters.', 'Inorbit Mall, Madhapur, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-9', 'japanese');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-9', 'Sushi & Asian');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-9', 'Japanese');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-9', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-9', 'Sushi Rolls');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-9', 'Ramen & Asian Bowls');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-9', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-900', 'rest-9', 'Sushi Master', 'Sushi Party Platter Combo (12 Pcs Mixed Sushi + Miso Soup + Green Tea)', '4 Salmon California + 4 Spicy Tuna + 4 Veg Avocado Rolls + Steamed Miso Soup', 699, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-900v', 'rest-9', 'Sushi Master', 'Veg Asian Feast Combo (Avocado Roll + Edamame + Bubble Tea)', '8 Pcs Veg Avocado Cucumber Roll + Steamed Salted Edamame + Matcha Boba Tea', 549, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-901', 'rest-9', 'Sushi Master', 'Salmon California Roll (8 Pcs)', 'Fresh Norwegian salmon, cucumber, avocado, and tobiko wrapped in sushi rice', 399, 0, 4.9, 1, 'Sushi Rolls', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-902', 'rest-9', 'Sushi Master', 'Spicy Tuna Crunch Roll (8 Pcs)', 'Fresh tuna fish chopped with spicy mayo, cucumber & crispy tempura flakes', 429, 0, 4.8, 0, 'Sushi Rolls', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-903', 'rest-9', 'Sushi Master', 'Avocado & Cucumber Veg Sushi (8 Pcs)', 'Creamy Hass avocado, crisp cucumber & toasted sesame seeds wrapped in seaweed', 329, 1, 4.7, 0, 'Sushi Rolls', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-904', 'rest-9', 'Sushi Master', 'Crispy Tempura Prawn Roll (8 Pcs)', 'Deep fried crispy tempura prawn, avocado, unagi eel sauce drizzle', 449, 0, 4.9, 0, 'Sushi Rolls', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-905', 'rest-9', 'Sushi Master', 'Rich Chicken Tonkotsu Ramen Bowl', 'Ramen wheat noodles in slow simmered rich chicken broth, jammy egg & nori', 369, 0, 4.8, 1, 'Ramen & Asian Bowls', 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-906', 'rest-9', 'Sushi Master', 'Spicy Veg Miso Ramen Bowl', 'Ramen noodles in spicy red miso broth, braised tofu, pak choi & bamboo shoots', 319, 1, 4.7, 0, 'Ramen & Asian Bowls', 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-907', 'rest-9', 'Sushi Master', 'Steamed Salted Edamame Pods', 'Young green soybean pods steamed and sea salted', 189, 1, 4.6, 0, 'Ramen & Asian Bowls', 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-908', 'rest-9', 'Sushi Master', 'Matcha Green Iced Boba Tea', 'Japanese Uji matcha green tea with chewy tapioca boba pearls & milk', 159, 1, 4.8, 0, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-10', 'Dessert Hub', 4.9, '4.8k+ ratings', '15-25 mins', 20, 99, 'Buy 1 Get 1 Free Scoops', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&auto=format&fit=crop&q=80', 'Decadent fudgy brownies, warm Belgian waffles, red velvet cheesecakes, and gelato.', 'Sweet Street, Jubilee Hills, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-10', 'desserts');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-10', 'icecream');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-10', 'beverages');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-10', 'Cakes & Brownies');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-10', 'Artisanal Gelato');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-10', 'Shakes & Drinks');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-10', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-10', 'Cakes & Brownies');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-10', 'Artisanal Gelato');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-10', 'Thick Shakes');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1000', 'rest-10', 'Dessert Hub', 'Brownie Sundae Combo (Sizzling Brownie + Gelato Scoop + Hot Fudge)', 'Warm Dark Walnut Brownie + Vanilla Bean Gelato + Extra Hot Fudge Drip', 249, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1000b', 'rest-10', 'Dessert Hub', 'Waffle Party Combo (Belgian Waffle + Chocolate Shake + Nutella Dip)', 'Belgian Nutella Waffle + Thick Belgian Chocolate Shake + Extra Nutella Dip', 289, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1001', 'rest-10', 'Dessert Hub', 'Sizzling Hot Walnut Brownie', 'Warm dark chocolate walnut brownie topped with vanilla gelato and hot fudge drip', 159, 1, 4.9, 1, 'Cakes & Brownies', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1002', 'rest-10', 'Dessert Hub', 'Warm Belgian Nutella Waffle', 'Crispy golden grid waffle smothered in pure Nutella hazelnut spread', 179, 1, 4.8, 0, 'Cakes & Brownies', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1003', 'rest-10', 'Dessert Hub', 'New York Red Velvet Cheesecake Slice', 'Rich creamy red velvet cheesecake slice with graham cracker crust', 199, 1, 4.9, 0, 'Cakes & Brownies', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1004', 'rest-10', 'Dessert Hub', 'Fudgy Dark Chocolate Cupcake', 'Moist 70% dark cocoa cupcake topped with rich chocolate buttercream frosting', 119, 1, 4.7, 0, 'Cakes & Brownies', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1005', 'rest-10', 'Dessert Hub', 'Double Belgian Chocolate Gelato Scoop', 'Slow churned Italian gelato made with Dutch dark cocoa powder', 129, 1, 4.9, 1, 'Artisanal Gelato', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1006', 'rest-10', 'Dessert Hub', 'Sicilian Pistachio Gelato Scoop', 'Authentic roasted Sicilian pistachio nut gelato scoop', 139, 1, 4.8, 0, 'Artisanal Gelato', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1007', 'rest-10', 'Dessert Hub', 'Thick KitKat Wafer Shake', 'Crushed KitKat wafers blended with Belgian chocolate ice cream', 149, 1, 4.8, 0, 'Thick Shakes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1008', 'rest-10', 'Dessert Hub', 'Cold Brew Hazelnut Mocha Shake', 'Arabica cold brew espresso blended with dark cocoa & hazelnut cream', 159, 1, 4.7, 0, 'Thick Shakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-11', 'Dawat North Indian', 4.7, '3.1k+ ratings', '25-35 mins', 25, 150, 'FLAT ₹80 OFF', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=1200&auto=format&fit=crop&q=80', 'Rich Paneer Butter Masala, Creamy Dal Makhani, and Garlic Butter Tandoori Naans.', 'HITEC City, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-11', 'indian');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-11', 'kebabs');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-11', 'North Indian Curry');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-11', 'Kebabs & Tandoor');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-11', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-11', 'North Indian Curries');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-11', 'Tandoori Breads');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-11', 'Beverages');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1100', 'rest-11', 'Dawat North Indian', 'Dawat Royal Thali Combo (Paneer Gravy + Dal Makhani + Naan + Rice + Sweet)', 'Paneer Butter Masala + Dal Makhani + 2 Garlic Naans + Jeera Rice + Gulab Jamun', 329, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1100n', 'rest-11', 'Dawat North Indian', 'Butter Chicken Feast Combo (Butter Chicken + Jeera Rice + Garlic Naan + Lassi)', 'Boneless Butter Chicken + Jeera Basmati Rice + 2 Garlic Naans + Sweet Lassi', 379, 0, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1101', 'rest-11', 'Dawat North Indian', 'Special Paneer Butter Masala', 'Fresh cottage cheese cubes simmered in creamy rich tomato butter sauce', 249, 1, 4.8, 1, 'North Indian Curries', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1102', 'rest-11', 'Dawat North Indian', 'Creamy Dal Makhani', 'Overnight cooked black lentils enriched with butter & white fresh cream', 199, 1, 4.8, 0, 'North Indian Curries', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1103', 'rest-11', 'Dawat North Indian', 'Murgh Makhani Butter Chicken', 'Tender tandoori chicken cooked in velvety tomato gravy with kasuri methi', 289, 0, 4.9, 0, 'North Indian Curries', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1104', 'rest-11', 'Dawat North Indian', 'Mutton Rogan Josh Curry', 'Slow-cooked lamb mutton curry infused with Kashmiri red chillies & spices', 349, 0, 4.8, 0, 'North Indian Curries', 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1105', 'rest-11', 'Dawat North Indian', 'Stuffed Amritsari Kulcha with Chole', 'Crispy potato stuffed kulcha served with spicy Punjabi chickpea gravy', 189, 1, 4.7, 1, 'Tandoori Breads', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1106', 'rest-11', 'Dawat North Indian', 'Butter Garlic Tandoori Naan', 'Soft refined flour flatbread baked in tandoor & slathered with garlic butter', 69, 1, 4.9, 0, 'Tandoori Breads', 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1107', 'rest-11', 'Dawat North Indian', 'Steamed Basmati Jeera Rice', 'Long grain aromatic basmati rice tempered with ghee & cumin seeds', 129, 1, 4.6, 0, 'Tandoori Breads', 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1108', 'rest-11', 'Dawat North Indian', 'Chilled Malai Mango Lassi', 'Thick churned sweet yogurt drink flavoured with Alphonso mango pulp', 79, 1, 4.8, 0, 'Beverages', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-12', 'Shakes & Smoothies Bar', 4.8, '2.5k+ ratings', '15-20 mins', 15, 99, '20% OFF on Smoothies', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=1200&auto=format&fit=crop&q=80', 'Thick KitKat shakes, Alphonso mango smoothies, and cold brewed hazelnut coffee.', 'Road No. 10, Banjara Hills, Hyderabad', 17.4399, 78.3989, 0);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-12', 'beverages');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-12', 'desserts');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-12', 'Shakes & Drinks');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-12', 'Cakes & Brownies');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-12', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-12', 'Thick Milkshakes');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-12', 'Fruit Smoothies');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-12', 'Beverages & Coffee');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1200', 'rest-12', 'Shakes & Smoothies Bar', 'Shake & Brownie Duo Combo (KitKat Shake + Sizzling Brownie)', 'Thick Belgian KitKat Shake + Warm Walnut Dark Brownie Slice', 249, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1200b', 'rest-12', 'Shakes & Smoothies Bar', 'Smoothie & Cookie Combo (Alphonso Mango Smoothie + Choco Cookie)', 'Fresh Mango Cream Smoothie + Double Choco Chip Cookie', 199, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1201', 'rest-12', 'Shakes & Smoothies Bar', 'Thick Belgian KitKat Shake', 'Crushed KitKat wafers blended with Belgian chocolate ice cream & whipped cream', 149, 1, 4.9, 1, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1202', 'rest-12', 'Shakes & Smoothies Bar', 'Oreo Nutella Blast Shake', 'Crunchy Oreo biscuits churned with dense Nutella hazelnut chocolate cream', 159, 1, 4.8, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1203', 'rest-12', 'Shakes & Smoothies Bar', 'Rich Ferrero Rocher Shake', 'Whole Ferrero Rocher chocolates blended with dark cocoa ice cream & hazelnut drip', 179, 1, 4.9, 1, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1204', 'rest-12', 'Shakes & Smoothies Bar', 'Alphonso Mango Cream Smoothie', 'Real Hyderabadi Alphonso mango pulp churned with chilled milk & honey', 139, 1, 4.7, 0, 'Fruit Smoothies', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1205', 'rest-12', 'Shakes & Smoothies Bar', 'Wild Berry Blast Yogurt Smoothie', 'Blueberries, raspberries & strawberries blended with thick Greek yogurt', 149, 1, 4.8, 0, 'Fruit Smoothies', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1206', 'rest-12', 'Shakes & Smoothies Bar', 'Fresh Strawberry Banana Smoothie', 'Fresh strawberries and ripe bananas whipped with chilled almond milk', 139, 1, 4.6, 0, 'Fruit Smoothies', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1207', 'rest-12', 'Shakes & Smoothies Bar', 'Cold Brewed Hazelnut Iced Coffee', '12-hour slow cold brewed arabica coffee with roasted hazelnut cream syrup', 129, 1, 4.8, 0, 'Beverages & Coffee', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1208', 'rest-12', 'Shakes & Smoothies Bar', 'Classic Iced Mocha Frappe', 'Chilled espresso, dark cocoa syrup & ice blended with whipped cream topping', 139, 1, 4.7, 0, 'Beverages & Coffee', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-13', 'Gelato Italiano', 4.9, '1.8k+ ratings', '15-25 mins', 20, 120, 'Buy 2 Tub Scoops Get 1 Free', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=1200&auto=format&fit=crop&q=80', 'Authentic Italian slow-churned gelato, Sicilian pistachio tub, and Dark Chocolate Sorbet.', 'Inorbit Mall, Madhapur, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-13', 'icecream');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-13', 'desserts');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-13', 'Artisanal Gelato');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-13', 'Cakes & Brownies');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-13', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-13', 'Artisanal Gelato');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-13', 'Fruit Sorbets');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-13', 'Gelato Tubs');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1300', 'rest-13', 'Gelato Italiano', 'Gelato Sundae Delight Combo (2 Scoops Gelato + Waffle Cone + Fudge)', '1 Sicilian Pistachio + 1 Dark Chocolate Scoop + 2 Waffle Cones + Hot Fudge', 229, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1300b', 'rest-13', 'Gelato Italiano', 'Family Gelato Tub Combo (500g Tub + Waffle Cones)', '500g Mixed Gelato Tub + 4 Freshly Baked Crispy Waffle Cones', 449, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1301', 'rest-13', 'Gelato Italiano', 'Sicilian Pistachio Gelato Scoop', 'Authentic roasted Sicilian pistachio nut paste churned into creamy Italian gelato', 139, 1, 4.9, 1, 'Artisanal Gelato', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1302', 'rest-13', 'Gelato Italiano', 'Dark Belgian Chocolate Sorbet Scoop', 'Dairy-free intense 70% dark Belgian cocoa Italian fruit sorbet scoop', 129, 1, 4.8, 0, 'Artisanal Gelato', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1303', 'rest-13', 'Gelato Italiano', 'Madagascar Vanilla Bean Gelato Scoop', 'Pure Madagascar bourbon vanilla bean specks infused in rich whole milk gelato', 119, 1, 4.7, 0, 'Artisanal Gelato', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1304', 'rest-13', 'Gelato Italiano', 'Alfonso Mango Fruit Sorbet Scoop', 'Refreshingly light vegan sorbet made from 100% natural Alphonso mangoes', 119, 1, 4.8, 0, 'Fruit Sorbets', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1305', 'rest-13', 'Gelato Italiano', 'Zesty Lemon Lime Italian Sorbet Scoop', 'Tangy Sicilian lemon and lime juice water ice sorbet scoop', 109, 1, 4.6, 0, 'Fruit Sorbets', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1306', 'rest-13', 'Gelato Italiano', 'Sicilian Pistachio Gelato Tub (250g)', 'Authentic roasted Sicilian pistachio nut gelato tub packed for home delivery', 229, 1, 4.9, 1, 'Gelato Tubs', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1307', 'rest-13', 'Gelato Italiano', 'Belgian Dark Chocolate Gelato Tub (250g)', 'Dense rich Belgian chocolate gelato tub packed fresh', 219, 1, 4.8, 0, 'Gelato Tubs', 'https://images.unsplash.com/photo-1560008511-11c63416e52d?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1308', 'rest-13', 'Gelato Italiano', 'Crispy Homemade Waffle Cones (2 Pcs)', 'Freshly baked buttery cinnamon waffle cones', 49, 1, 4.8, 0, 'Gelato Tubs', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&auto=format&fit=crop&q=80');
INSERT INTO restaurants (id, name, rating, rating_count, delivery_time, delivery_fee, min_order, offer, image, banner, description, address, latitude, longitude, is_favorite) VALUES ('rest-14', 'The Thick Shake Factory', 4.9, '5.6k+ ratings', '15-20 mins', 15, 99, 'BUY 1 GET 1 FREE SHAKES', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=600&auto=format&fit=crop&q=80', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=1200&auto=format&fit=crop&q=80', 'Legendary thick milkshakes, Oreo monster shakes, Nutella blast, and mango smoothies.', 'Kavuri Hills, Madhapur, Hyderabad', 17.4399, 78.3989, 1);
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-14', 'beverages');
INSERT INTO restaurant_categories (restaurant_id, category_id) VALUES ('rest-14', 'desserts');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-14', 'Shakes & Drinks');
INSERT INTO restaurant_cuisines (restaurant_id, cuisine_name) VALUES ('rest-14', 'Artisanal Gelato');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-14', 'Combos & Bestsellers');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-14', 'Thick Milkshakes');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-14', 'Smoothies & Frappes');
INSERT INTO restaurant_menu_categories (restaurant_id, category_name) VALUES ('rest-14', 'Desserts');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1400', 'rest-14', 'The Thick Shake Factory', 'Mega Shake & Waffle Combo (Nutella Shake + Waffle Slice)', 'Nutella Ferrero Rocher Shake + Warm Belgian Waffle Slice', 279, 1, 4.9, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1400b', 'rest-14', 'The Thick Shake Factory', 'Oreo Monster Party Combo (2 Oreo Shakes + Choco Chip Cookie)', '2 Large Oreo Monster Thickshakes + Double Choco Chip Cookie', 299, 1, 4.8, 1, 'Combos & Bestsellers', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1401', 'rest-14', 'The Thick Shake Factory', 'Nutella Ferrero Rocher Blast Shake', 'Rich Nutella blend topped with crushed Ferrero Rocher, whipped cream & chocolate drizzle', 189, 1, 4.9, 1, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1402', 'rest-14', 'The Thick Shake Factory', 'Oreo Monster Thickshake', 'Double crunchy Oreo cookie crunch blended in dense ice cream milkshake', 159, 1, 4.8, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1403', 'rest-14', 'The Thick Shake Factory', 'Snickers Peanut Butter Shake', 'Creamy peanut butter, crushed Snickers chocolate bars & chocolate fudge', 169, 1, 4.8, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1404', 'rest-14', 'The Thick Shake Factory', 'Salted Caramel Brownie Shake', 'Butterscotch salted caramel drip blended with dark cocoa brownie bites', 169, 1, 4.7, 0, 'Thick Milkshakes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1405', 'rest-14', 'The Thick Shake Factory', 'Fresh Mango Cream Smoothie', 'Real Hyderabadi Alphonso mango pulp churned with chilled milk and ice', 139, 1, 4.7, 0, 'Smoothies & Frappes', 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1406', 'rest-14', 'The Thick Shake Factory', 'Chilled Hazelnut Frappe', 'Blended espresso cold coffee with rich hazelnut syrup and whipped cream', 149, 1, 4.8, 0, 'Smoothies & Frappes', 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1407', 'rest-14', 'The Thick Shake Factory', 'Dark Choco Lava Cake', 'Warm dark chocolate cake with rich liquid fudge interior', 99, 1, 4.9, 1, 'Desserts', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500&auto=format&fit=crop&q=80');
INSERT INTO menu_items (id, restaurant_id, restaurant_name, name, description, price, is_veg, rating, is_bestseller, category, image) VALUES ('f-1408', 'rest-14', 'The Thick Shake Factory', 'Warm Belgian Waffle Slice', 'Golden crispy waffle quarter slice dusted with powdered sugar', 119, 1, 4.7, 0, 'Desserts', 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80');
INSERT INTO coupons (code, discount, min_subtotal, type, description) VALUES ('FOOD100', 100, 400, 'flat', 'Flat ₹100 OFF on orders above ₹400');
INSERT INTO coupons (code, discount, min_subtotal, type, description) VALUES ('MULTIFOOD20', 20, 300, 'percentage', '20% OFF up to ₹150 on Multi-Restaurant orders');
INSERT INTO coupons (code, discount, min_subtotal, type, description) VALUES ('FREEDEL', 60, 250, 'flat', 'Free Delivery on orders above ₹250');
INSERT INTO coupons (code, discount, min_subtotal, type, description) VALUES ('FESTIVE150', 150, 600, 'flat', 'Special ₹150 OFF on feast orders above ₹600');
INSERT INTO orders (id, user_id, address_id, created_at, status, delivery_status, partner_latitude, partner_longitude, estimated_delivery, payment_method, subtotal, delivery_fee, tax, discount, total) VALUES ('FD10245', 'usr-101', 'addr-1', '2026-10-02 14:29:59', 'Preparing', 'OUT_FOR_DELIVERY', 17.4420, 78.3910, '30-40 mins', 'UPI', 727, 60, 36, 100, 723);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (1, 'FD10245', 'rest-1', 'Paradise Biryani', 'Food Being Prepared', 289);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10245', 1, 'f-101', 'Royal Chicken Dum Biryani', 289, 1, 0);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (2, 'FD10245', 'rest-2', 'Pizza Palace', 'Food Being Prepared', 249);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10245', 2, 'f-201', 'Margherita Gourmet Pizza', 249, 1, 1);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (3, 'FD10245', 'rest-3', 'Burger House', 'Order Confirmed', 189);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10245', 3, 'f-301', 'Classic Chicken Crunch Burger', 189, 1, 0);
INSERT INTO orders (id, user_id, address_id, created_at, status, delivery_status, partner_latitude, partner_longitude, estimated_delivery, payment_method, subtotal, delivery_fee, tax, discount, total) VALUES ('FD10299', 'usr-101', 'addr-2', '2026-10-02 13:14:59', 'Out for Delivery', 'OUT_FOR_DELIVERY', 17.4420, 78.3910, '10-15 mins', 'Credit Card', 557, 45, 28, 50, 580);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (4, 'FD10299', 'rest-5', 'Chinese Wok', 'Out for Delivery', 338);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10299', 4, 'f-501', 'Hakka Veg Schezwan Noodles', 169, 2, 1);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (5, 'FD10299', 'rest-8', 'Taco Fiesta', 'Picked up by Valet', 219);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10299', 5, 'f-801', 'Loaded Chicken Crunch Tacos (3 pcs)', 219, 1, 0);
INSERT INTO orders (id, user_id, address_id, created_at, status, delivery_status, partner_latitude, partner_longitude, estimated_delivery, payment_method, subtotal, delivery_fee, tax, discount, total) VALUES ('FD10310', 'usr-101', 'addr-1', '2026-09-30 15:14:59', 'Delivered', 'OUT_FOR_DELIVERY', 17.4420, 78.3910, 'Delivered', 'Cash on Delivery', 558, 40, 28, 0, 626);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (6, 'FD10310', 'rest-9', 'Sushi Master', 'Delivered', 399);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10310', 6, 'f-901', 'Salmon California Roll (8 pcs)', 399, 1, 0);
INSERT INTO order_restaurants (id, order_id, restaurant_id, restaurant_name, status, subtotal) VALUES (7, 'FD10310', 'rest-10', 'Dessert Hub', 'Delivered', 159);
INSERT INTO order_items (order_id, order_restaurant_id, food_id, food_name, price, quantity, is_veg) VALUES ('FD10310', 7, 'f-1001', 'Sizzling Hot Walnut Brownie', 159, 1, 1);
INSERT INTO user_notifications (id, user_id, title, message, time, is_read) VALUES ('n-1', 'usr-101', 'Order Delivered! 🛵', 'Your combined order #FD10245 containing items from Paradise Biryani & Pizza Palace was delivered successfully.', '10 mins ago', 0);
INSERT INTO user_notifications (id, user_id, title, message, time, is_read) VALUES ('n-2', 'usr-101', 'Special Coupon Unlocked 🎟️', 'Use code MULTIFOOD20 to get 20% OFF on multi-restaurant orders!', '1 hour ago', 0);
INSERT INTO vendor_offers (id, restaurant_id, code, name, discount_type, discount_value, max_discount, min_subtotal, start_date, end_date, status, usage_count) VALUES ('off-1', 'rest-1', 'PARADISE50', '50% OFF Royal Biryani Special', 'percentage', 50, 120, 299, '2026-09-01', '2026-09-30', 'Active', 142);
INSERT INTO vendor_offers (id, restaurant_id, code, name, discount_type, discount_value, max_discount, min_subtotal, start_date, end_date, status, usage_count) VALUES ('off-2', 'rest-1', 'WELCOME100', 'Flat ₹100 OFF First Order', 'flat', 100, 100, 499, '2026-09-10', '2026-10-15', 'Active', 89);
INSERT INTO vendor_offers (id, restaurant_id, code, name, discount_type, discount_value, max_discount, min_subtotal, start_date, end_date, status, usage_count) VALUES ('off-3', 'rest-2', 'PIZZAFEST', '30% OFF Gourmet Pizza Party', 'percentage', 30, 150, 399, '2026-09-05', '2026-09-25', 'Active', 65);
INSERT INTO vendor_reviews (id, restaurant_id, customer_name, rating, date, dish_name, comment, reply) VALUES ('rev-1', 'rest-1', 'Rahul Sharma', 5, '2026-09-16', 'Royal Chicken Dum Biryani', 'Authentic Hyderabadi flavor! The chicken was super soft and cooked to perfection.', 'Thank you Rahul! We take pride in our traditional dum cooking.');
INSERT INTO vendor_reviews (id, restaurant_id, customer_name, rating, date, dish_name, comment, reply) VALUES ('rev-2', 'rest-1', 'Priya Verma', 4, '2026-09-15', 'Hyderabadi Chicken 65', 'Spicy and crispy! Delivered piping hot in 25 minutes.', NULL);
INSERT INTO vendor_reviews (id, restaurant_id, customer_name, rating, date, dish_name, comment, reply) VALUES ('rev-3', 'rest-2', 'Ankit Kumar', 5, '2026-09-14', 'Pepperoni Feast Pizza', 'Best pepperoni pizza in Hyderabad hands down. Loads of cheese!', 'Thanks Ankit! Glad you loved the wood-fired flavor.');
INSERT INTO vendor_notifications (id, restaurant_id, title, message, timestamp, type, is_read) VALUES ('vnot-1', 'rest-1', 'New Order Received! 🛵', 'Order #FD10245 contains items from Paradise Biryani. Total: ₹289', '5 mins ago', 'order', 0);
INSERT INTO vendor_notifications (id, restaurant_id, title, message, timestamp, type, is_read) VALUES ('vnot-2', 'rest-1', '5-Star Customer Review ⭐', 'Rahul Sharma left a 5-star review for Royal Chicken Dum Biryani.', '2 hours ago', 'review', 1);
INSERT INTO vendor_notifications (id, restaurant_id, title, message, timestamp, type, is_read) VALUES ('vnot-3', 'rest-1', 'Offer PARADISE50 Performing Great 🚀', 'Your discount offer PARADISE50 was used 18 times today!', '1 day ago', 'offer', 1);
CREATE INDEX idx_menu_items_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_orders_user ON orders(user_id);

CREATE VIEW v_restaurant_summary AS
SELECT 
  r.id,
  r.name,
  r.rating,
  r.rating_count,
  r.delivery_time,
  r.delivery_fee,
  r.min_order,
  COUNT(DISTINCT m.id) AS total_menu_items
FROM restaurants r
LEFT JOIN menu_items m ON r.id = m.restaurant_id
GROUP BY r.id, r.name, r.rating, r.rating_count, r.delivery_time, r.delivery_fee, r.min_order;

CREATE VIEW v_popular_items AS
SELECT 
  m.id,
  m.name AS food_name,
  m.price,
  m.rating,
  m.is_veg,
  r.name AS restaurant_name
FROM menu_items m
JOIN restaurants r ON m.restaurant_id = r.id
WHERE m.is_bestseller = 1 OR m.rating >= 4.8;

CREATE VIEW v_order_details AS
SELECT 
  o.id AS order_id,
  u.name AS customer_name,
  o.created_at,
  o.status,
  o.delivery_status,
  o.partner_latitude,
  o.partner_longitude,
  o.total
FROM orders o
JOIN users u ON o.user_id = u.id;

SET FOREIGN_KEY_CHECKS = 1;
