-- =====================================================
-- WordPress Store Database Schema and Sample Data
-- =====================================================

-- Drop tables if they exist (for clean installation)
DROP TABLE IF EXISTS wp_store_orders;
DROP TABLE IF EXISTS wp_store_customers;
DROP TABLE IF EXISTS wp_store_products;

-- =====================================================
-- Table: wp_store_products
-- Based loosely on WooCommerce product structure
-- =====================================================
CREATE TABLE wp_store_products (
    product_id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(200) NOT NULL,
    product_slug VARCHAR(200) NOT NULL,
    product_description TEXT,
    product_short_description TEXT,
    sku VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    regular_price DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    sale_price DECIMAL(10, 2) DEFAULT NULL,
    stock_quantity INT(11) DEFAULT NULL,
    stock_status VARCHAR(20) DEFAULT 'instock',
    product_type VARCHAR(50) DEFAULT 'simple',
    featured TINYINT(1) DEFAULT 0,
    `virtual` TINYINT(1) DEFAULT 0,
    downloadable TINYINT(1) DEFAULT 0,
    weight VARCHAR(50),
    length VARCHAR(50),
    width VARCHAR(50),
    height VARCHAR(50),
    category VARCHAR(100),
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (product_id),
    UNIQUE KEY sku (sku),
    KEY product_slug (product_slug),
    KEY stock_status (stock_status),
    KEY category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: wp_store_customers
-- =====================================================
CREATE TABLE wp_store_customers (
    customer_id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    username VARCHAR(60) NOT NULL,
    phone VARCHAR(20),
    billing_address_1 VARCHAR(200),
    billing_address_2 VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_postcode VARCHAR(20),
    billing_country VARCHAR(2) DEFAULT 'US',
    shipping_address_1 VARCHAR(200),
    shipping_address_2 VARCHAR(200),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postcode VARCHAR(20),
    shipping_country VARCHAR(2) DEFAULT 'US',
    date_registered DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_order_date DATETIME,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    order_count INT(11) DEFAULT 0,
    PRIMARY KEY (customer_id),
    UNIQUE KEY email (email),
    UNIQUE KEY username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Table: wp_store_orders
-- =====================================================
CREATE TABLE wp_store_orders (
    order_id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id BIGINT(20) UNSIGNED NOT NULL,
    product_id BIGINT(20) UNSIGNED NOT NULL,
    order_key VARCHAR(100) NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    order_currency VARCHAR(3) DEFAULT 'USD',
    quantity INT(11) NOT NULL DEFAULT 1,
    product_price DECIMAL(10, 2) NOT NULL,
    line_total DECIMAL(10, 2) NOT NULL,
    tax_total DECIMAL(10, 2) DEFAULT 0.00,
    shipping_total DECIMAL(10, 2) DEFAULT 0.00,
    order_total DECIMAL(10, 2) NOT NULL,
    payment_method VARCHAR(100),
    payment_method_title VARCHAR(200),
    transaction_id VARCHAR(200),
    customer_ip_address VARCHAR(100),
    customer_user_agent TEXT,
    billing_email VARCHAR(100),
    billing_first_name VARCHAR(100),
    billing_last_name VARCHAR(100),
    shipping_method VARCHAR(200),
    order_notes TEXT,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    date_completed DATETIME,
    PRIMARY KEY (order_id),
    UNIQUE KEY order_key (order_key),
    KEY customer_id (customer_id),
    KEY product_id (product_id),
    KEY order_status (order_status),
    KEY date_created (date_created),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES wp_store_customers(customer_id) ON DELETE CASCADE,
    CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES wp_store_products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Insert Sample Products (40 products)
-- =====================================================
INSERT INTO wp_store_products (product_name, product_slug, product_description, product_short_description, sku, price, regular_price, sale_price, stock_quantity, stock_status, category, featured, weight) VALUES
('Premium Wireless Headphones', 'premium-wireless-headphones', 'High-quality wireless headphones with noise cancellation and 30-hour battery life.', 'Premium audio experience', 'WH-001', 199.99, 249.99, 199.99, 45, 'instock', 'Electronics', 1, '250'),
('Smart Fitness Watch', 'smart-fitness-watch', 'Track your fitness goals with GPS, heart rate monitor, and sleep tracking.', 'Advanced fitness tracking', 'FW-002', 299.99, 299.99, NULL, 32, 'instock', 'Electronics', 1, '50'),
('Ergonomic Office Chair', 'ergonomic-office-chair', 'Comfortable office chair with lumbar support and adjustable armrests.', 'Ultimate comfort for work', 'OC-003', 349.99, 399.99, 349.99, 18, 'instock', 'Furniture', 0, '15000'),
('Stainless Steel Water Bottle', 'stainless-steel-water-bottle', 'Insulated water bottle keeps drinks cold for 24 hours or hot for 12 hours.', 'Stay hydrated in style', 'WB-004', 29.99, 34.99, 29.99, 150, 'instock', 'Kitchen', 0, '300'),
('Yoga Mat Premium', 'yoga-mat-premium', 'Extra thick yoga mat with non-slip surface for all types of yoga.', 'Perfect for your practice', 'YM-005', 49.99, 49.99, NULL, 75, 'instock', 'Sports', 0, '1200'),
('LED Desk Lamp', 'led-desk-lamp', 'Adjustable LED lamp with multiple brightness levels and USB charging port.', 'Illuminate your workspace', 'DL-006', 39.99, 44.99, 39.99, 62, 'instock', 'Home', 0, '800'),
('Bluetooth Speaker Portable', 'bluetooth-speaker-portable', 'Waterproof Bluetooth speaker with 360-degree sound and 12-hour battery.', 'Music anywhere you go', 'BS-007', 79.99, 79.99, NULL, 88, 'instock', 'Electronics', 1, '600'),
('Coffee Maker Programmable', 'coffee-maker-programmable', 'Programmable coffee maker with thermal carafe and auto-shutoff feature.', 'Wake up to fresh coffee', 'CM-008', 89.99, 109.99, 89.99, 25, 'instock', 'Kitchen', 0, '2500'),
('Running Shoes Men', 'running-shoes-men', 'Lightweight running shoes with responsive cushioning and breathable mesh.', 'Run faster, run longer', 'RS-009', 119.99, 119.99, NULL, 40, 'instock', 'Footwear', 0, '350'),
('Laptop Backpack', 'laptop-backpack', 'Durable backpack with padded laptop compartment and multiple pockets.', 'Protect your tech', 'LB-010', 59.99, 69.99, 59.99, 95, 'instock', 'Accessories', 0, '800'),
('Electric Kettle', 'electric-kettle', 'Fast-boiling electric kettle with auto-shutoff and boil-dry protection.', 'Quick and safe boiling', 'EK-011', 34.99, 39.99, 34.99, 58, 'instock', 'Kitchen', 0, '1100'),
('Wireless Mouse', 'wireless-mouse', 'Ergonomic wireless mouse with precision tracking and long battery life.', 'Smooth and precise', 'WM-012', 24.99, 24.99, NULL, 120, 'instock', 'Electronics', 0, '100'),
('Bath Towel Set', 'bath-towel-set', 'Luxury cotton bath towel set with 4 towels in various sizes.', 'Soft and absorbent', 'BT-013', 54.99, 64.99, 54.99, 35, 'instock', 'Home', 0, '1500'),
('Portable Charger 20000mAh', 'portable-charger-20000', 'High-capacity portable charger with fast charging and dual USB ports.', 'Never run out of power', 'PC-014', 44.99, 44.99, NULL, 78, 'instock', 'Electronics', 1, '400'),
('Indoor Plant Pot Set', 'indoor-plant-pot-set', 'Set of 3 ceramic plant pots with drainage holes and saucers.', 'Beautify your space', 'PP-015', 29.99, 34.99, 29.99, 42, 'instock', 'Home', 0, '2000'),
('Protein Powder Chocolate', 'protein-powder-chocolate', 'Whey protein powder with 25g protein per serving, chocolate flavor.', 'Fuel your fitness', 'PR-016', 39.99, 49.99, 39.99, 65, 'instock', 'Sports', 0, '900'),
('Hardcover Journal', 'hardcover-journal', 'Premium hardcover journal with lined pages and elastic closure.', 'Capture your thoughts', 'HJ-017', 19.99, 19.99, NULL, 105, 'instock', 'Stationery', 0, '400'),
('Kitchen Knife Set', 'kitchen-knife-set', 'Professional 8-piece knife set with wooden block and sharpener.', 'Essential kitchen tools', 'KK-018', 129.99, 159.99, 129.99, 22, 'instock', 'Kitchen', 0, '3000'),
('Fleece Blanket Queen', 'fleece-blanket-queen', 'Soft fleece blanket in queen size, machine washable.', 'Cozy comfort', 'FB-019', 39.99, 39.99, NULL, 48, 'instock', 'Home', 0, '1200'),
('Sunglasses Polarized', 'sunglasses-polarized', 'UV400 polarized sunglasses with durable frames and protective case.', 'Protect your eyes', 'SG-020', 89.99, 109.99, 89.99, 72, 'instock', 'Accessories', 0, '50'),
('Air Fryer 5.8 Quart', 'air-fryer-5-8-quart', 'Digital air fryer with 8 preset programs and dishwasher-safe basket.', 'Healthier frying', 'AF-021', 99.99, 119.99, 99.99, 28, 'instock', 'Kitchen', 1, '4500'),
('Gaming Mouse RGB', 'gaming-mouse-rgb', 'High-DPI gaming mouse with customizable RGB lighting and programmable buttons.', 'Level up your game', 'GM-022', 59.99, 59.99, NULL, 55, 'instock', 'Electronics', 0, '150'),
('Dumbbell Set Adjustable', 'dumbbell-set-adjustable', 'Adjustable dumbbell set from 5-52.5 lbs with storage tray.', 'Complete home gym', 'DB-023', 299.99, 349.99, 299.99, 15, 'instock', 'Sports', 0, '22000'),
('Wall Art Canvas Set', 'wall-art-canvas-set', 'Modern abstract canvas wall art set of 3 panels with wooden frames.', 'Elevate your decor', 'WA-024', 79.99, 99.99, 79.99, 38, 'instock', 'Home', 0, '3000'),
('Mechanical Keyboard', 'mechanical-keyboard', 'RGB mechanical keyboard with blue switches and aluminum frame.', 'Tactile typing experience', 'MK-025', 119.99, 119.99, NULL, 44, 'instock', 'Electronics', 1, '900'),
('Insulated Lunch Box', 'insulated-lunch-box', 'Leakproof insulated lunch box with multiple compartments and utensils.', 'Fresh meals on the go', 'LX-026', 24.99, 29.99, 24.99, 85, 'instock', 'Kitchen', 0, '500'),
('Resistance Bands Set', 'resistance-bands-set', 'Exercise resistance bands set with 5 different resistance levels and handles.', 'Versatile workout tool', 'RB-027', 29.99, 29.99, NULL, 92, 'instock', 'Sports', 0, '600'),
('Floor Lamp Modern', 'floor-lamp-modern', 'Contemporary floor lamp with adjustable head and foot switch.', 'Modern lighting solution', 'FL-028', 89.99, 109.99, 89.99, 31, 'instock', 'Home', 0, '3500'),
('Wireless Earbuds Pro', 'wireless-earbuds-pro', 'True wireless earbuds with active noise cancellation and wireless charging case.', 'Premium sound quality', 'WE-029', 149.99, 179.99, 149.99, 67, 'instock', 'Electronics', 1, '60'),
('Cutting Board Bamboo', 'cutting-board-bamboo', 'Large bamboo cutting board with juice groove and non-slip grips.', 'Eco-friendly kitchen essential', 'CB-030', 34.99, 34.99, NULL, 73, 'instock', 'Kitchen', 0, '1800'),
('Desk Organizer Set', 'desk-organizer-set', 'Wooden desk organizer set with compartments for office supplies.', 'Organize your workspace', 'DO-031', 44.99, 49.99, 44.99, 52, 'instock', 'Stationery', 0, '1200'),
('Electric Toothbrush', 'electric-toothbrush', 'Rechargeable electric toothbrush with 3 brushing modes and travel case.', 'Superior oral care', 'ET-032', 69.99, 79.99, 69.99, 46, 'instock', 'Personal Care', 0, '200'),
('Throw Pillow Set', 'throw-pillow-set', 'Decorative throw pillow covers set of 4 with zipper closure.', 'Refresh your living space', 'TP-033', 39.99, 39.99, NULL, 68, 'instock', 'Home', 0, '800'),
('Digital Kitchen Scale', 'digital-kitchen-scale', 'Precise digital kitchen scale with tare function and LCD display.', 'Accurate measurements', 'KS-034', 19.99, 24.99, 19.99, 98, 'instock', 'Kitchen', 0, '400'),
('Phone Stand Adjustable', 'phone-stand-adjustable', 'Adjustable phone stand compatible with all smartphones and tablets.', 'Hands-free convenience', 'PS-035', 14.99, 14.99, NULL, 135, 'instock', 'Accessories', 0, '150'),
('Blender High Speed', 'blender-high-speed', 'Professional high-speed blender with 6 blades and multiple speed settings.', 'Blend anything', 'BL-036', 129.99, 149.99, 129.99, 26, 'instock', 'Kitchen', 0, '4000'),
('Memory Foam Pillow', 'memory-foam-pillow', 'Contoured memory foam pillow with breathable bamboo cover.', 'Perfect sleep support', 'MF-037', 49.99, 59.99, 49.99, 54, 'instock', 'Home', 0, '900'),
('USB-C Hub Multiport', 'usb-c-hub-multiport', '7-in-1 USB-C hub with HDMI, USB 3.0, SD card reader, and power delivery.', 'Expand your connectivity', 'UH-038', 39.99, 39.99, NULL, 82, 'instock', 'Electronics', 0, '100'),
('Aromatherapy Diffuser', 'aromatherapy-diffuser', 'Ultrasonic aromatherapy diffuser with LED lights and auto-shutoff.', 'Create a relaxing atmosphere', 'AD-039', 34.99, 44.99, 34.99, 61, 'instock', 'Home', 0, '600'),
('Camping Tent 4-Person', 'camping-tent-4-person', 'Waterproof 4-person camping tent with easy setup and ventilation windows.', 'Adventure awaits', 'CT-040', 149.99, 149.99, NULL, 19, 'instock', 'Sports', 0, '5500');

-- =====================================================
-- Insert Sample Customers (5 customers)
-- =====================================================
INSERT INTO wp_store_customers (email, first_name, last_name, username, phone, billing_address_1, billing_city, billing_state, billing_postcode, billing_country, shipping_address_1, shipping_city, shipping_state, shipping_postcode, shipping_country) VALUES
('sarah.johnson@email.com', 'Sarah', 'Johnson', 'sjohnson', '555-0101', '123 Maple Street', 'Springfield', 'IL', '62701', 'US', '123 Maple Street', 'Springfield', 'IL', '62701', 'US'),
('michael.chen@email.com', 'Michael', 'Chen', 'mchen', '555-0102', '456 Oak Avenue', 'Portland', 'OR', '97201', 'US', '456 Oak Avenue', 'Portland', 'OR', '97201', 'US'),
('emma.williams@email.com', 'Emma', 'Williams', 'ewilliams', '555-0103', '789 Pine Road', 'Austin', 'TX', '78701', 'US', '789 Pine Road', 'Austin', 'TX', '78701', 'US'),
('david.martinez@email.com', 'David', 'Martinez', 'dmartinez', '555-0104', '321 Elm Boulevard', 'Seattle', 'WA', '98101', 'US', '321 Elm Boulevard', 'Seattle', 'WA', '98101', 'US'),
('olivia.brown@email.com', 'Olivia', 'Brown', 'obrown', '555-0105', '654 Birch Lane', 'Denver', 'CO', '80201', 'US', '654 Birch Lane', 'Denver', 'CO', '80201', 'US');

-- =====================================================
-- Insert Sample Orders (50 orders)
-- =====================================================
INSERT INTO wp_store_orders (customer_id, product_id, order_key, order_status, quantity, product_price, line_total, tax_total, shipping_total, order_total, payment_method, payment_method_title, billing_email, billing_first_name, billing_last_name, shipping_method, date_created, date_completed) VALUES
(1, 1, 'wc_order_001', 'completed', 1, 199.99, 199.99, 16.00, 8.99, 224.98, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'flat_rate', '2024-12-15 10:23:45', '2024-12-16 14:30:22'),
(2, 7, 'wc_order_002', 'completed', 2, 79.99, 159.98, 12.80, 8.99, 181.77, 'paypal', 'PayPal', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2024-12-16 14:15:33', '2024-12-17 09:45:11'),
(3, 4, 'wc_order_003', 'completed', 3, 29.99, 89.97, 7.20, 5.99, 103.16, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2024-12-17 09:42:18', '2024-12-18 11:22:45'),
(4, 12, 'wc_order_004', 'processing', 1, 24.99, 24.99, 2.00, 4.99, 31.98, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2024-12-18 16:30:55', NULL),
(5, 17, 'wc_order_005', 'completed', 4, 19.99, 79.96, 6.40, 8.99, 95.35, 'paypal', 'PayPal', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2024-12-19 11:05:22', '2024-12-20 15:18:33'),
(1, 25, 'wc_order_006', 'completed', 1, 119.99, 119.99, 9.60, 0.00, 129.59, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'free_shipping', '2024-12-20 13:45:10', '2024-12-21 10:30:45'),
(2, 14, 'wc_order_007', 'completed', 1, 44.99, 44.99, 3.60, 4.99, 53.58, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2024-12-21 08:20:44', '2024-12-22 12:15:20'),
(3, 30, 'wc_order_008', 'cancelled', 2, 34.99, 69.98, 5.60, 5.99, 81.57, 'paypal', 'PayPal', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2024-12-22 15:33:27', NULL),
(4, 5, 'wc_order_009', 'completed', 1, 49.99, 49.99, 4.00, 8.99, 62.98, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2024-12-23 10:18:55', '2024-12-24 09:30:12'),
(5, 21, 'wc_order_010', 'completed', 1, 99.99, 99.99, 8.00, 0.00, 107.99, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'free_shipping', '2024-12-24 14:25:39', '2024-12-26 11:45:22'),
(1, 29, 'wc_order_011', 'completed', 1, 149.99, 149.99, 12.00, 0.00, 161.99, 'paypal', 'PayPal', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'free_shipping', '2024-12-26 09:12:18', '2024-12-27 14:20:35'),
(2, 35, 'wc_order_012', 'processing', 5, 14.99, 74.95, 6.00, 5.99, 86.94, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2024-12-27 16:40:22', NULL),
(3, 6, 'wc_order_013', 'completed', 2, 39.99, 79.98, 6.40, 8.99, 95.37, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2024-12-28 11:55:44', '2024-12-29 10:15:28'),
(4, 22, 'wc_order_014', 'completed', 1, 59.99, 59.99, 4.80, 4.99, 69.78, 'paypal', 'PayPal', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2024-12-29 13:22:15', '2024-12-30 15:40:55'),
(5, 9, 'wc_order_015', 'completed', 1, 119.99, 119.99, 9.60, 0.00, 129.59, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'free_shipping', '2024-12-30 10:08:33', '2024-12-31 11:25:18'),
(1, 34, 'wc_order_016', 'completed', 2, 19.99, 39.98, 3.20, 4.99, 48.17, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'flat_rate', '2025-01-02 15:35:28', '2025-01-03 09:50:42'),
(2, 26, 'wc_order_017', 'completed', 3, 24.99, 74.97, 6.00, 5.99, 86.96, 'paypal', 'PayPal', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2025-01-03 12:18:50', '2025-01-04 14:30:25'),
(3, 16, 'wc_order_018', 'on-hold', 2, 39.99, 79.98, 6.40, 8.99, 95.37, 'bank_transfer', 'Direct Bank Transfer', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-01-04 09:45:12', NULL),
(4, 32, 'wc_order_019', 'completed', 1, 69.99, 69.99, 5.60, 4.99, 80.58, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2025-01-05 14:52:38', '2025-01-06 10:20:15'),
(5, 38, 'wc_order_020', 'completed', 2, 39.99, 79.98, 6.40, 8.99, 95.37, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2025-01-06 11:28:44', '2025-01-07 13:45:22'),
(1, 10, 'wc_order_021', 'completed', 1, 59.99, 59.99, 4.80, 4.99, 69.78, 'paypal', 'PayPal', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'flat_rate', '2025-01-07 16:15:33', '2025-01-08 09:30:50'),
(2, 2, 'wc_order_022', 'completed', 1, 299.99, 299.99, 24.00, 0.00, 323.99, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'free_shipping', '2025-01-08 10:42:18', '2025-01-09 15:20:35'),
(3, 27, 'wc_order_023', 'completed', 2, 29.99, 59.98, 4.80, 5.99, 70.77, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-01-09 13:55:27', '2025-01-10 11:40:12'),
(4, 39, 'wc_order_024', 'processing', 1, 34.99, 34.99, 2.80, 4.99, 42.78, 'paypal', 'PayPal', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2025-01-10 15:20:45', NULL),
(5, 15, 'wc_order_025', 'completed', 1, 29.99, 29.99, 2.40, 4.99, 37.38, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2025-01-11 09:33:52', '2025-01-12 10:15:28'),
(1, 8, 'wc_order_026', 'completed', 1, 89.99, 89.99, 7.20, 0.00, 97.19, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'free_shipping', '2025-01-12 14:28:16', '2025-01-13 09:45:30'),
(2, 19, 'wc_order_027', 'completed', 1, 39.99, 39.99, 3.20, 4.99, 48.18, 'paypal', 'PayPal', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2025-01-13 11:15:42', '2025-01-14 10:30:15'),
(3, 33, 'wc_order_028', 'completed', 3, 39.99, 119.97, 9.60, 8.99, 138.56, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-01-14 15:40:28', '2025-01-15 12:20:45'),
(4, 11, 'wc_order_029', 'completed', 2, 34.99, 69.98, 5.60, 5.99, 81.57, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2025-01-15 09:52:33', '2025-01-16 11:15:20'),
(5, 24, 'wc_order_030', 'completed', 1, 79.99, 79.99, 6.40, 8.99, 95.38, 'paypal', 'PayPal', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2025-01-16 13:25:18', '2025-01-17 14:40:55'),
(1, 36, 'wc_order_031', 'processing', 1, 129.99, 129.99, 10.40, 0.00, 140.39, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'free_shipping', '2025-01-17 16:18:44', NULL),
(2, 3, 'wc_order_032', 'completed', 1, 349.99, 349.99, 28.00, 0.00, 377.99, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'free_shipping', '2025-01-18 10:35:22', '2025-01-19 09:20:15'),
(3, 13, 'wc_order_033', 'completed', 2, 54.99, 109.98, 8.80, 8.99, 127.77, 'paypal', 'PayPal', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-01-19 14:42:55', '2025-01-20 11:30:40'),
(4, 28, 'wc_order_034', 'completed', 1, 89.99, 89.99, 7.20, 0.00, 97.19, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'free_shipping', '2025-01-20 12:15:38', '2025-01-21 10:45:22'),
(5, 37, 'wc_order_035', 'completed', 2, 49.99, 99.98, 8.00, 8.99, 116.97, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2025-01-21 15:28:47', '2025-01-22 13:20:30'),
(1, 18, 'wc_order_036', 'completed', 1, 129.99, 129.99, 10.40, 0.00, 140.39, 'paypal', 'PayPal', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'free_shipping', '2025-01-22 09:45:19', '2025-01-23 11:15:45'),
(2, 31, 'wc_order_037', 'on-hold', 1, 44.99, 44.99, 3.60, 4.99, 53.58, 'bank_transfer', 'Direct Bank Transfer', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2025-01-23 13:52:28', NULL),
(3, 20, 'wc_order_038', 'completed', 1, 89.99, 89.99, 7.20, 0.00, 97.19, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'free_shipping', '2025-01-24 11:20:33', '2025-01-25 10:40:18'),
(4, 23, 'wc_order_039', 'completed', 1, 299.99, 299.99, 24.00, 0.00, 323.99, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'free_shipping', '2025-01-25 14:35:42', '2025-01-26 12:20:55'),
(5, 40, 'wc_order_040', 'completed', 1, 149.99, 149.99, 12.00, 0.00, 161.99, 'paypal', 'PayPal', 'olivia.brown@email.com', 'Olivia', 'Brown', 'free_shipping', '2025-01-26 16:48:15', '2025-01-27 15:30:28'),
(1, 27, 'wc_order_041', 'completed', 3, 29.99, 89.97, 7.20, 5.99, 103.16, 'stripe', 'Credit Card', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'flat_rate', '2025-01-27 10:12:44', '2025-01-28 09:45:20'),
(2, 4, 'wc_order_042', 'completed', 4, 29.99, 119.96, 9.60, 8.99, 138.55, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2025-01-28 13:25:38', '2025-01-29 11:20:15'),
(3, 12, 'wc_order_043', 'processing', 2, 24.99, 49.98, 4.00, 4.99, 58.97, 'paypal', 'PayPal', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-01-29 15:40:22', NULL),
(4, 26, 'wc_order_044', 'completed', 5, 24.99, 124.95, 10.00, 5.99, 140.94, 'stripe', 'Credit Card', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2025-01-30 09:55:18', '2025-01-31 10:30:45'),
(5, 14, 'wc_order_045', 'completed', 1, 44.99, 44.99, 3.60, 4.99, 53.58, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'flat_rate', '2025-01-31 12:18:33', '2025-02-01 11:45:20'),
(1, 5, 'wc_order_046', 'completed', 2, 49.99, 99.98, 8.00, 8.99, 116.97, 'paypal', 'PayPal', 'sarah.johnson@email.com', 'Sarah', 'Johnson', 'flat_rate', '2025-02-01 14:32:47', '2025-02-02 13:20:35'),
(2, 35, 'wc_order_047', 'completed', 3, 14.99, 44.97, 3.60, 4.99, 53.56, 'stripe', 'Credit Card', 'michael.chen@email.com', 'Michael', 'Chen', 'flat_rate', '2025-02-02 16:45:28', '2025-02-03 15:10:40'),
(3, 6, 'wc_order_048', 'completed', 1, 39.99, 39.99, 3.20, 4.99, 48.18, 'stripe', 'Credit Card', 'emma.williams@email.com', 'Emma', 'Williams', 'flat_rate', '2025-02-03 11:28:15', '2025-02-04 10:50:25'),
(4, 17, 'wc_order_049', 'completed', 6, 19.99, 119.94, 9.60, 8.99, 138.53, 'paypal', 'PayPal', 'david.martinez@email.com', 'David', 'Martinez', 'flat_rate', '2025-02-04 13:52:38', '2025-02-05 12:30:18'),
(5, 25, 'wc_order_050', 'pending', 1, 119.99, 119.99, 9.60, 0.00, 129.59, 'stripe', 'Credit Card', 'olivia.brown@email.com', 'Olivia', 'Brown', 'free_shipping', '2025-02-05 15:20:44', NULL);