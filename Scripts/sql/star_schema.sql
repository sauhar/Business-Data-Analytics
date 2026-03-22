-- ============================================================
--  STAR SCHEMA (Data Warehouse)
-- Best for: Analytics, Dashboards, BI Tools
-- ============================================================
 
-- Drop existing tables
DROP TABLE IF EXISTS fact_sales_star_schema;
DROP TABLE IF EXISTS dim_date_star_schema;
DROP TABLE IF EXISTS dim_customer_star_schema;
DROP TABLE IF EXISTS dim_product_star_schema;
DROP TABLE IF EXISTS dim_store_star_schema;
 
-- ------------------------------------------------------------
-- DIMENSION TABLES (The "Who, What, Where, When")
-- ------------------------------------------------------------
 
-- dim_date_star_schema: The special date dimension
CREATE TABLE dim_date_star_schema (
    date_key INT PRIMARY KEY,
    full_date DATE,
    day_of_week INT,
    day_name VARCHAR(15),
    day_of_month INT,
    week_of_year INT,
    month_number INT,
    month_name VARCHAR(15),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    fiscal_year INT,
    fiscal_quarter INT
);
 
-- Insert sample dates (January 2024)
INSERT INTO dim_date_star_schema VALUES
(20240101, '2024-01-01', 1, 'Monday', 1, 1, 1, 'January', 1, 2024, FALSE, TRUE, 2024, 3),
(20240102, '2024-01-02', 2, 'Tuesday', 2, 1, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240115, '2024-01-15', 1, 'Monday', 15, 3, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240116, '2024-01-16', 2, 'Tuesday', 16, 3, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240117, '2024-01-17', 3, 'Wednesday', 17, 3, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240118, '2024-01-18', 4, 'Thursday', 18, 3, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240120, '2024-01-20', 6, 'Saturday', 20, 3, 1, 'January', 1, 2024, TRUE, FALSE, 2024, 3),
(20240125, '2024-01-25', 4, 'Thursday', 25, 4, 1, 'January', 1, 2024, FALSE, FALSE, 2024, 3),
(20240126, '2024-01-26', 5, 'Friday', 26, 4, 1, 'January', 1, 2024, FALSE, TRUE, 2024, 3),  -- Republic Day
(20240215, '2024-02-15', 4, 'Thursday', 15, 7, 2, 'February', 1, 2024, FALSE, FALSE, 2024, 3);
 
-- dim_customer_star_schema: Customer dimension
CREATE TABLE dim_customer_star_schema (
    customer_key INT PRIMARY KEY,      
    customer_id INT,                    
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50),
    province VARCHAR(50),
    customer_segment VARCHAR(20),       -- Gold, Silver, Bronze
    registration_date DATE,
    is_active BOOLEAN
);
 
INSERT INTO dim_customer_star_schema VALUES
(1, 1001, 'Ram Sharma', 'ram@email.com', '9841234567', 'Kathmandu', 'Bagmati', 'Gold', '2023-01-15', TRUE),
(2, 1002, 'Sita Thapa', 'sita@email.com', '9801234567', 'Pokhara', 'Gandaki', 'Silver', '2023-03-20', TRUE),
(3, 1003, 'Hari Gurung', 'hari@email.com', '9812345678', 'Lalitpur', 'Bagmati', 'Bronze', '2023-06-10', TRUE),
(4, 1004, 'Gita Rai', 'gita@email.com', '9867890123', 'Biratnagar', 'Province 1', 'Silver', '2023-08-05', TRUE),
(5, 1005, 'Krishna Tamang', 'krishna@email.com', '9845678901', 'Bharatpur', 'Bagmati', 'Gold', '2023-02-28', TRUE);
 
-- dim_product_star_schema: Product dimension
CREATE TABLE dim_product_star_schema (
    product_key INT PRIMARY KEY,        -- Surrogate key
    product_id INT,                     -- Natural key
    product_name VARCHAR(100),
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    is_active BOOLEAN
);
 
INSERT INTO dim_product_star_schema VALUES
(1, 101, 'Dell Laptop', 'Electronics', 'Computers', 'Dell', 85000, 70000, TRUE),
(2, 102, 'Wireless Mouse', 'Electronics', 'Accessories', 'Logitech', 1500, 1000, TRUE),
(3, 103, 'Mechanical Keyboard', 'Electronics', 'Accessories', 'Redragon', 2500, 1800, TRUE),
(4, 104, 'Samsung Phone', 'Electronics', 'Mobile', 'Samsung', 45000, 38000, TRUE),
(5, 105, 'Phone Case', 'Electronics', 'Accessories', 'Generic', 500, 200, TRUE),
(6, 106, 'LG Monitor', 'Electronics', 'Displays', 'LG', 25000, 20000, TRUE),
(7, 107, 'Cotton T-Shirt', 'Clothing', 'Tops', 'North Face', 1200, 600, TRUE),
(8, 108, 'Winter Jacket', 'Clothing', 'Outerwear', 'North Face', 3500, 2000, TRUE);
 
-- dim_store_star_schema: Store/Location dimension
CREATE TABLE dim_store_star_schema (
    store_key INT PRIMARY KEY,
    store_id INT,
    store_name VARCHAR(100),
    city VARCHAR(50),
    province VARCHAR(50),
    store_type VARCHAR(30),             -- Retail, Online, Franchise
    opening_date DATE,
    store_size_sqft INT,
    is_active BOOLEAN
);
 
INSERT INTO dim_store_star_schema VALUES
(1, 1, 'NepalMart Kathmandu Central', 'Kathmandu', 'Bagmati', 'Retail', '2020-01-15', 5000, TRUE),
(2, 2, 'NepalMart Pokhara Lakeside', 'Pokhara', 'Gandaki', 'Retail', '2021-03-10', 3000, TRUE),
(3, 3, 'NepalMart Online', 'Kathmandu', 'Bagmati', 'Online', '2022-01-01', 0, TRUE),
(4, 4, 'NepalMart Biratnagar', 'Biratnagar', 'Province 1', 'Franchise', '2022-06-15', 2500, TRUE);
 
-- ------------------------------------------------------------
-- FACT TABLE (The "Measures" - What we want to analyze)
-- ------------------------------------------------------------
 
CREATE TABLE fact_sales_star_schema (
    sales_key INT PRIMARY KEY,
    -- Foreign keys to dimensions
    date_key INT,
    customer_key INT,
    product_key INT,
    store_key INT,
    -- Measures (numbers we want to aggregate)
    quantity INT,
    unit_price DECIMAL(10,2),
    discount_amount DECIMAL(10,2),
    sales_amount DECIMAL(10,2),
    cost_amount DECIMAL(10,2),
    profit_amount DECIMAL(10,2),
    -- Foreign key constraints
    FOREIGN KEY (date_key) REFERENCES dim_date_star_schema(date_key),
    FOREIGN KEY (customer_key) REFERENCES dim_customer_star_schema(customer_key),
    FOREIGN KEY (product_key) REFERENCES dim_product_star_schema(product_key),
    FOREIGN KEY (store_key) REFERENCES dim_store_star_schema(store_key)
);
 
-- Insert sample sales data
INSERT INTO fact_sales_star_schema VALUES
(1, 20240115, 1, 1, 1, 1, 85000, 0, 85000, 70000, 15000),
(2, 20240115, 1, 2, 1, 2, 1500, 0, 3000, 2000, 1000),
(3, 20240115, 1, 3, 1, 1, 2500, 0, 2500, 1800, 700),
(4, 20240116, 2, 4, 2, 1, 45000, 2000, 43000, 38000, 5000),
(5, 20240116, 2, 5, 2, 2, 500, 0, 1000, 400, 600),
(6, 20240117, 1, 6, 3, 1, 25000, 1500, 23500, 20000, 3500),
(7, 20240118, 3, 7, 1, 3, 1200, 0, 3600, 1800, 1800),
(8, 20240118, 3, 8, 1, 1, 3500, 500, 3000, 2000, 1000),
(9, 20240120, 4, 4, 4, 1, 45000, 0, 45000, 38000, 7000),
(10, 20240125, 5, 1, 3, 1, 85000, 5000, 80000, 70000, 10000),
(11, 20240126, 2, 2, 2, 1, 1500, 0, 1500, 1000, 500),
(12, 20240215, 3, 6, 3, 2, 25000, 0, 50000, 40000, 10000);
 
-- View the star schema
SELECT '=== dim_date_star_schema ===' AS dimension;
SELECT date_key, full_date, day_name, month_name, quarter, year FROM dim_date_star_schema;
 
SELECT '=== dim_customer_star_schema ===' AS dimension;
SELECT customer_key, customer_name, city, customer_segment FROM dim_customer_star_schema;
 
SELECT '=== dim_product_star_schema ===' AS dimension;
SELECT product_key, product_name, category, brand, unit_price FROM dim_product_star_schema;
 
SELECT '=== dim_store_star_schema ===' AS dimension;
SELECT store_key, store_name, city, store_type FROM dim_store_star_schema;
 
SELECT '=== fact_sales_star_schema ===' AS fact_table;
SELECT * FROM fact_sales_star_schema;
 
 
-- ------------------------------------------------------------
-- STAR SCHEMA QUERIES (Analytics Examples)
-- ------------------------------------------------------------
 
-- Query 1: Total sales by month
SELECT 
    d.month_name,
    d.year,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.profit_amount) AS total_profit
FROM fact_sales_star_schema f
JOIN dim_date_star_schema d ON f.date_key = d.date_key
GROUP BY d.month_name, d.year, d.month_number
ORDER BY d.year, d.month_number;
 
-- Query 2: Sales by customer segment
SELECT 
    c.customer_segment,
    COUNT(DISTINCT c.customer_key) AS num_customers,
    SUM(f.sales_amount) AS total_sales,
    ROUND(AVG(f.sales_amount), 2) AS avg_order_value
FROM fact_sales_star_schema f
JOIN dim_customer_star_schema c ON f.customer_key = c.customer_key
GROUP BY c.customer_segment
ORDER BY total_sales DESC;
 
-- Query 3: Top selling products by category
SELECT 
    p.category,
    p.product_name,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.profit_amount) AS total_profit
FROM fact_sales_star_schema f
JOIN dim_product_star_schema p ON f.product_key = p.product_key
GROUP BY p.category, p.product_name
ORDER BY total_sales DESC;
 
-- Query 4: Sales by store and day of week
SELECT 
    s.store_name,
    d.day_name,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales_star_schema f
JOIN dim_store_star_schema s ON f.store_key = s.store_key
JOIN dim_date_star_schema d ON f.date_key = d.date_key
GROUP BY s.store_name, d.day_name, d.day_of_week
ORDER BY s.store_name, d.day_of_week;
 
-- Query 5: Complete drill-down analysis
SELECT 
    d.full_date,
    d.day_name,
    c.customer_name,
    c.city AS customer_city,
    c.customer_segment,
    p.product_name,
    p.category,
    s.store_name,
    s.store_type,
    f.quantity,
    f.sales_amount,
    f.profit_amount
FROM fact_sales_star_schema f
JOIN dim_date_star_schema d ON f.date_key = d.date_key
JOIN dim_customer_star_schema c ON f.customer_key = c.customer_key
JOIN dim_product_star_schema p ON f.product_key = p.product_key
JOIN dim_store_star_schema s ON f.store_key = s.store_key
ORDER BY d.full_date;