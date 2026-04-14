-- =====================================================
-- Advanced SQL Practice Database
-- Module 4: Advanced SQL & Window Functions
-- SkillShikshya - Business Data Analytics with AI
-- =====================================================

-- Run this script in DBeaver to create tables and load sample data
-- Works with: MySQL, PostgreSQL, SQL Server (minor syntax adjustments may be needed)

-- =====================================================
-- DROP EXISTING TABLES (if any)
-- =====================================================
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS daily_sales;

-- =====================================================
-- TABLE 1: CUSTOMERS
-- =====================================================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    city VARCHAR(50),
    join_date DATE
);

INSERT INTO customers (customer_id, name, email, city, join_date) VALUES
(1, 'Ram Sharma', 'ram.sharma@email.com', 'Kathmandu', '2023-01-15'),
(2, 'Sita Thapa', 'sita.thapa@email.com', 'Pokhara', '2023-02-20'),
(3, 'Hari Gurung', 'hari.gurung@email.com', 'Kathmandu', '2023-03-10'),
(4, 'Gita Rai', 'gita.rai@email.com', 'Lalitpur', '2023-04-05'),
(5, 'Krishna Shrestha', 'krishna.s@email.com', 'Pokhara', '2023-05-12'),
(6, 'Anita Tamang', 'anita.t@email.com', 'Kathmandu', '2023-06-18'),
(7, 'Binod Karki', 'binod.k@email.com', 'Bhaktapur', '2023-07-22'),
(8, 'Chandra Magar', 'chandra.m@email.com', 'Lalitpur', '2023-08-30'),
(9, 'Deepak Adhikari', 'deepak.a@email.com', 'Kathmandu', '2023-09-14'),
(10, 'Elina Basnet', 'elina.b@email.com', 'Pokhara', '2023-10-25'),
(11, 'Fanindra Neupane', 'fanindra.n@email.com', 'Kathmandu', '2023-11-08'),
(12, 'Geeta Poudel', 'geeta.p@email.com', 'Bhaktapur', '2023-12-01'),
(13, 'Himal Lama', 'himal.l@email.com', 'Lalitpur', '2024-01-10'),
(14, 'Indira KC', 'indira.kc@email.com', 'Pokhara', '2024-02-14'),
(15, 'Jeevan Bhandari', 'jeevan.b@email.com', 'Kathmandu', '2024-03-20');

-- =====================================================
-- TABLE 2: PRODUCTS
-- =====================================================
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

INSERT INTO products (product_id, product_name, category, price) VALUES
(101, 'Laptop', 'Electronics', 85000.00),
(102, 'Smartphone', 'Electronics', 45000.00),
(103, 'Tablet', 'Electronics', 35000.00),
(104, 'Headphones', 'Electronics', 5000.00),
(105, 'Mouse', 'Electronics', 1500.00),
(106, 'Keyboard', 'Electronics', 2500.00),
(107, 'Winter Jacket', 'Clothing', 3500.00),
(108, 'T-Shirt', 'Clothing', 800.00),
(109, 'Jeans', 'Clothing', 2200.00),
(110, 'Sneakers', 'Clothing', 4500.00),
(111, 'Backpack', 'Accessories', 2800.00),
(112, 'Watch', 'Accessories', 8500.00),
(113, 'Sunglasses', 'Accessories', 1800.00),
(114, 'Water Bottle', 'Accessories', 450.00),
(115, 'Desk Lamp', 'Home', 1200.00),
(116, 'Coffee Maker', 'Home', 6500.00),
(117, 'Blender', 'Home', 3800.00),
(118, 'Rice Cooker', 'Home', 4200.00),
(119, 'Notebook Set', 'Stationery', 350.00),
(120, 'Pen Pack', 'Stationery', 180.00);

-- =====================================================
-- TABLE 3: ORDERS
-- =====================================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(1001, 1, '2024-01-05', 'Delivered'),
(1002, 2, '2024-01-08', 'Delivered'),
(1003, 3, '2024-01-10', 'Delivered'),
(1004, 1, '2024-01-15', 'Delivered'),
(1005, 4, '2024-01-18', 'Delivered'),
(1006, 5, '2024-01-22', 'Delivered'),
(1007, 6, '2024-01-25', 'Delivered'),
(1008, 2, '2024-02-01', 'Delivered'),
(1009, 7, '2024-02-05', 'Delivered'),
(1010, 8, '2024-02-10', 'Delivered'),
(1011, 3, '2024-02-14', 'Delivered'),
(1012, 9, '2024-02-18', 'Delivered'),
(1013, 1, '2024-02-22', 'Delivered'),
(1014, 10, '2024-02-28', 'Delivered'),
(1015, 11, '2024-03-05', 'Delivered'),
(1016, 4, '2024-03-10', 'Delivered'),
(1017, 12, '2024-03-15', 'Delivered'),
(1018, 5, '2024-03-20', 'Delivered'),
(1019, 13, '2024-03-25', 'Delivered'),
(1020, 6, '2024-03-30', 'Shipped'),
(1021, 14, '2024-04-02', 'Shipped'),
(1022, 7, '2024-04-05', 'Processing'),
(1023, 15, '2024-04-08', 'Processing'),
(1024, 8, '2024-04-10', 'Processing'),
(1025, 2, '2024-04-12', 'Pending');

-- =====================================================
-- TABLE 4: ORDER_ITEMS
-- =====================================================
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items (item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 85000.00),
(2, 1001, 104, 2, 5000.00),
(3, 1002, 102, 1, 45000.00),
(4, 1002, 108, 3, 800.00),
(5, 1003, 107, 2, 3500.00),
(6, 1003, 109, 1, 2200.00),
(7, 1004, 103, 1, 35000.00),
(8, 1004, 105, 1, 1500.00),
(9, 1005, 111, 1, 2800.00),
(10, 1005, 112, 1, 8500.00),
(11, 1006, 116, 1, 6500.00),
(12, 1006, 114, 2, 450.00),
(13, 1007, 102, 1, 45000.00),
(14, 1007, 106, 1, 2500.00),
(15, 1008, 110, 1, 4500.00),
(16, 1008, 108, 2, 800.00),
(17, 1009, 115, 2, 1200.00),
(18, 1009, 119, 5, 350.00),
(19, 1010, 117, 1, 3800.00),
(20, 1010, 118, 1, 4200.00),
(21, 1011, 101, 1, 85000.00),
(22, 1011, 113, 1, 1800.00),
(23, 1012, 104, 1, 5000.00),
(24, 1012, 106, 2, 2500.00),
(25, 1013, 112, 1, 8500.00),
(26, 1014, 107, 1, 3500.00),
(27, 1014, 109, 2, 2200.00),
(28, 1015, 103, 1, 35000.00),
(29, 1016, 110, 2, 4500.00),
(30, 1016, 111, 1, 2800.00),
(31, 1017, 116, 1, 6500.00),
(32, 1017, 117, 1, 3800.00),
(33, 1018, 102, 1, 45000.00),
(34, 1019, 118, 2, 4200.00),
(35, 1019, 115, 1, 1200.00),
(36, 1020, 105, 3, 1500.00),
(37, 1020, 106, 2, 2500.00),
(38, 1021, 108, 4, 800.00),
(39, 1021, 119, 10, 350.00),
(40, 1022, 104, 2, 5000.00),
(41, 1023, 101, 1, 85000.00),
(42, 1023, 102, 1, 45000.00),
(43, 1024, 113, 2, 1800.00),
(44, 1024, 114, 3, 450.00),
(45, 1025, 107, 1, 3500.00);

-- =====================================================
-- TABLE 5: DAILY_SALES (for time-series analysis)
-- =====================================================
CREATE TABLE daily_sales (
    sale_date DATE PRIMARY KEY,
    total_orders INT,
    total_revenue DECIMAL(12, 2)
);

INSERT INTO daily_sales (sale_date, total_orders, total_revenue) VALUES
('2024-01-01', 5, 45000.00),
('2024-01-02', 8, 62000.00),
('2024-01-03', 6, 48000.00),
('2024-01-04', 12, 95000.00),
('2024-01-05', 9, 71000.00),
('2024-01-06', 4, 32000.00),
('2024-01-07', 3, 28000.00),
('2024-01-08', 7, 55000.00),
('2024-01-09', 11, 88000.00),
('2024-01-10', 10, 78000.00),
('2024-01-11', 8, 64000.00),
('2024-01-12', 6, 51000.00),
('2024-01-13', 5, 42000.00),
('2024-01-14', 4, 35000.00),
('2024-01-15', 9, 72000.00),
('2024-01-16', 13, 105000.00),
('2024-01-17', 11, 89000.00),
('2024-01-18', 8, 67000.00),
('2024-01-19', 7, 58000.00),
('2024-01-20', 5, 43000.00),
('2024-01-21', 4, 36000.00),
('2024-01-22', 10, 82000.00),
('2024-01-23', 12, 96000.00),
('2024-01-24', 9, 74000.00),
('2024-01-25', 8, 65000.00),
('2024-01-26', 6, 52000.00),
('2024-01-27', 5, 44000.00),
('2024-01-28', 4, 37000.00),
('2024-01-29', 11, 91000.00),
('2024-01-30', 14, 115000.00),
('2024-01-31', 10, 83000.00);

-- =====================================================
-- VERIFY DATA LOADED
-- =====================================================
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'daily_sales', COUNT(*) FROM daily_sales;

-- =====================================================
-- YOU'RE READY! Now try these practice queries:
-- =====================================================

-- 1. Basic multi-table join
 SELECT c.name, p.product_name, oi.quantity
 FROM customers c
 JOIN orders o ON c.customer_id = o.customer_id
 JOIN order_items oi ON o.order_id = oi.order_id
 JOIN products p ON oi.product_id = p.product_id;

-- 2. Window function - ROW_NUMBER
 SELECT name, city, 
        ROW_NUMBER() OVER (ORDER BY name) AS row_num
 FROM customers;

-- 3. Running total
 SELECT sale_date, total_revenue,
        SUM(total_revenue) OVER (ORDER BY sale_date) AS running_total
 FROM daily_sales;



------for group by and window function difference

--------group by example

SELECT category, COUNT(*) AS total_products
FROM products
GROUP BY category;

----window function example

SELECT 
    product_name,
    category,
    COUNT(*) OVER (PARTITION BY category) AS total_products
FROM products;




