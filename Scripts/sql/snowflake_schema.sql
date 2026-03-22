-- ============================================================
-- PART 3: SNOWFLAKE SCHEMA
-- Normalized dimensions - more tables, more joins
-- ============================================================
 
-- Drop existing snowflake tables
DROP TABLE IF EXISTS fact_sales_snowflake;
DROP TABLE IF EXISTS dim_product_snowflake;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_subcategory;
DROP TABLE IF EXISTS dim_brand;
DROP TABLE IF EXISTS dim_customer_snowflake;
DROP TABLE IF EXISTS dim_city;
DROP TABLE IF EXISTS dim_province;
 
-- ------------------------------------------------------------
-- NORMALIZED DIMENSION TABLES (Snowflake)
-- ------------------------------------------------------------
 
-- Province dimension (normalized from customer)
CREATE TABLE dim_province (
    province_key INT PRIMARY KEY,
    province_name VARCHAR(50),
    region VARCHAR(50)
);
 
INSERT INTO dim_province VALUES
(1, 'Bagmati', 'Central'),
(2, 'Gandaki', 'Western'),
(3, 'Province 1', 'Eastern'),
(4, 'Lumbini', 'Western'),
(5, 'Sudurpashchim', 'Far-Western');
 
-- City dimension (references province)
CREATE TABLE dim_city (
    city_key INT PRIMARY KEY,
    city_name VARCHAR(50),
    province_key INT,
    population INT,
    FOREIGN KEY (province_key) REFERENCES dim_province(province_key)
);
 
INSERT INTO dim_city VALUES
(1, 'Kathmandu', 1, 1442271),
(2, 'Pokhara', 2, 436344),
(3, 'Lalitpur', 1, 299964),
(4, 'Biratnagar', 3, 242548),
(5, 'Bharatpur', 1, 369284);
 
-- Customer dimension (references city)
CREATE TABLE dim_customer_snowflake (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    city_key INT,
    customer_segment VARCHAR(20),
    FOREIGN KEY (city_key) REFERENCES dim_city(city_key)
);
 
INSERT INTO dim_customer_snowflake VALUES
(1, 1001, 'Ram Sharma', 'ram@email.com', 1, 'Gold'),
(2, 1002, 'Sita Thapa', 'sita@email.com', 2, 'Silver'),
(3, 1003, 'Hari Gurung', 'hari@email.com', 3, 'Bronze'),
(4, 1004, 'Gita Rai', 'gita@email.com', 4, 'Silver'),
(5, 1005, 'Krishna Tamang', 'krishna@email.com', 5, 'Gold');
 
-- Brand dimension
CREATE TABLE dim_brand (
    brand_key INT PRIMARY KEY,
    brand_name VARCHAR(50),
    brand_country VARCHAR(50)
);
 
INSERT INTO dim_brand VALUES
(1, 'Dell', 'USA'),
(2, 'Logitech', 'Switzerland'),
(3, 'Redragon', 'China'),
(4, 'Samsung', 'South Korea'),
(5, 'Generic', 'Various'),
(6, 'LG', 'South Korea'),
(7, 'North Face', 'USA');
 
-- Category dimension
CREATE TABLE dim_category (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(50),
    department VARCHAR(50)
);
 
INSERT INTO dim_category VALUES
(1, 'Electronics', 'Technology'),
(2, 'Clothing', 'Apparel');
 
-- Subcategory dimension (references category)
CREATE TABLE dim_subcategory (
    subcategory_key INT PRIMARY KEY,
    subcategory_name VARCHAR(50),
    category_key INT,
    FOREIGN KEY (category_key) REFERENCES dim_category(category_key)
);
 
INSERT INTO dim_subcategory VALUES
(1, 'Computers', 1),
(2, 'Accessories', 1),
(3, 'Mobile', 1),
(4, 'Displays', 1),
(5, 'Tops', 2),
(6, 'Outerwear', 2);
 
-- Product dimension (references subcategory and brand)
CREATE TABLE dim_product_snowflake (
    product_key INT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(100),
    subcategory_key INT,
    brand_key INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (subcategory_key) REFERENCES dim_subcategory(subcategory_key),
    FOREIGN KEY (brand_key) REFERENCES dim_brand(brand_key)
);
 
INSERT INTO dim_product_snowflake VALUES
(1, 101, 'Dell Laptop', 1, 1, 85000),
(2, 102, 'Wireless Mouse', 2, 2, 1500),
(3, 103, 'Mechanical Keyboard', 2, 3, 2500),
(4, 104, 'Samsung Phone', 3, 4, 45000),
(5, 105, 'Phone Case', 2, 5, 500),
(6, 106, 'LG Monitor', 4, 6, 25000),
(7, 107, 'Cotton T-Shirt', 5, 7, 1200),
(8, 108, 'Winter Jacket', 6, 7, 3500);
 
-- Fact table for snowflake (same structure, references snowflake dimensions)
CREATE TABLE fact_sales_snowflake (
    sales_key INT PRIMARY KEY,
    date_key INT,
    customer_key INT,
    product_key INT,
    store_key INT,
    quantity INT,
    sales_amount DECIMAL(10,2),
    profit_amount DECIMAL(10,2),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer_snowflake(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product_snowflake(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store(store_key)
);
 
INSERT INTO fact_sales_snowflake VALUES
(1, 20240115, 1, 1, 1, 1, 85000, 15000),
(2, 20240115, 1, 2, 1, 2, 3000, 1000),
(3, 20240116, 2, 4, 2, 1, 43000, 5000),
(4, 20240117, 1, 6, 3, 1, 23500, 3500),
(5, 20240118, 3, 7, 1, 3, 3600, 1800);
 
-- View snowflake schema structure
SELECT '=== SNOWFLAKE SCHEMA ===' AS schema_type;
 
SELECT '--- dim_province ---' AS tbl;
SELECT * FROM dim_province;
 
SELECT '--- dim_city ---' AS tbl;
SELECT * FROM dim_city;
 
SELECT '--- dim_customer_snowflake ---' AS tbl;
SELECT * FROM dim_customer_snowflake;
 
SELECT '--- dim_brand ---' AS tbl;
SELECT * FROM dim_brand;
 
SELECT '--- dim_category ---' AS tbl;
SELECT * FROM dim_category;
 
SELECT '--- dim_subcategory ---' AS tbl;
SELECT * FROM dim_subcategory;
 
SELECT '--- dim_product_snowflake ---' AS tbl;
SELECT * FROM dim_product_snowflake;
 
 
-- ------------------------------------------------------------
-- SNOWFLAKE QUERY: Requires more joins
-- ------------------------------------------------------------
 
-- Complete sales analysis with snowflake schema
SELECT 
    d.full_date,
    c.customer_name,
    ci.city_name,
    pr.province_name,
    p.product_name,
    cat.category_name,
    sub.subcategory_name,
    b.brand_name,
    b.brand_country,
    s.store_name,
    f.quantity,
    f.sales_amount,
    f.profit_amount
FROM fact_sales_snowflake f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer_snowflake c ON f.customer_key = c.customer_key
JOIN dim_city ci ON c.city_key = ci.city_key
JOIN dim_province pr ON ci.province_key = pr.province_key
JOIN dim_product_snowflake p ON f.product_key = p.product_key
JOIN dim_subcategory sub ON p.subcategory_key = sub.subcategory_key
JOIN dim_category cat ON sub.category_key = cat.category_key
JOIN dim_brand b ON p.brand_key = b.brand_key
JOIN dim_store s ON f.store_key = s.store_key
ORDER BY d.full_date;
 
 
-- ============================================================
-- SUMMARY: COMPARISON QUERIES
-- ============================================================
 
-- Star Schema: Simple query (4 joins)
SELECT 'STAR SCHEMA - 4 JOINS' AS schema_type;
SELECT 
    c.customer_name, c.city, p.product_name, p.category,
    f.sales_amount
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
LIMIT 5;
 
-- Snowflake Schema: Complex query (9 joins for same info)
SELECT 'SNOWFLAKE SCHEMA - 9 JOINS' AS schema_type;
SELECT 
    c.customer_name, ci.city_name, p.product_name, cat.category_name,
    f.sales_amount
FROM fact_sales_snowflake f
JOIN dim_customer_snowflake c ON f.customer_key = c.customer_key
JOIN dim_city ci ON c.city_key = ci.city_key
JOIN dim_province pr ON ci.province_key = pr.province_key
JOIN dim_product_snowflake p ON f.product_key = p.product_key
JOIN dim_subcategory sub ON p.subcategory_key = sub.subcategory_key
JOIN dim_category cat ON sub.category_key = cat.category_key
JOIN dim_brand b ON p.brand_key = b.brand_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_store s ON f.store_key = s.store_key
LIMIT 5;