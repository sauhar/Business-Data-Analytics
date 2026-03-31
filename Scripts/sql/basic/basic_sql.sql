
-- ============================================
-- SQL BASICS PRACTICE QUERIES
-- ============================================

-- ============================================
-- 1. SELECT (Retrieve Data)
-- ============================================

-- Get all customers
SELECT * FROM customers;

-- Get specific columns (name and city)
SELECT name, city FROM customers;


-- ============================================
-- 2. WHERE (Filtering Data)
-- ============================================

-- Customers from Kathmandu
SELECT * 
FROM customers
WHERE city = 'Kathmandu';


SELECT * 
FROM customers
WHERE city like 'Kathmandu';

-- Orders after Feb 1, 2024
SELECT * 
FROM orders
WHERE order_date > '2024-02-01';


-- ============================================
-- 3. ORDER BY (Sorting Data)
-- ============================================

-- Customers sorted alphabetically by name
SELECT * 
FROM customers
ORDER BY name ASC;

-- Products sorted by price (highest first)
SELECT * 
FROM products
ORDER BY price DESC;


-- ============================================
-- 4. GROUP BY (Grouping Data)
-- ============================================

-- Count number of customers in each city
SELECT city, COUNT(*) AS total_customers
FROM customers
GROUP BY city;

-- Total revenue per product
SELECT product_id, SUM(quantity * unit_price) AS revenue
FROM order_items
GROUP BY product_id;


-- ============================================
-- 5. AGGREGATE FUNCTIONS
-- ============================================

-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Total sales revenue
SELECT SUM(quantity * unit_price) AS total_sales
FROM order_items;

-- Average product price
SELECT AVG(price) AS avg_price
FROM products;

-- Minimum product price
SELECT MIN(price) AS min_price
FROM products;

-- Maximum product price
SELECT MAX(price) AS max_price
FROM products;


---------------------Having Clause

--- categories witrh the average price greater than 5000

SELECT category, AVG(price) AS avg_price
FROM products
GROUP BY category
HAVING AVG(price) > 5000;



-- ============================================
-- 6. INNER JOIN (Matching Records Only)
-- ============================================

-- Get order details with customer names

SELECT o.order_id, c.name, o.order_date
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;


-- ============================================
-- 7. LEFT JOIN (All Left + Matching Right)
-- ============================================

-- All customers and their orders (if any)
SELECT c.name, o.order_id
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id;


-- ============================================
-- 8. RIGHT JOIN (All Right + Matching Left)
-- ============================================

-- All orders with customer info
SELECT c.name, o.order_id
FROM customers c
RIGHT JOIN orders o
ON c.customer_id = o.customer_id;


-- ============================================
-- 9. FULL JOIN (All Records from Both)
-- ============================================

-- All customers and all orders (matched + unmatched)
SELECT c.name, o.order_id
FROM customers c
FULL OUTER JOIN orders o
ON c.customer_id = o.customer_id;


-- ============================================
-- 10. FILTER + GROUP BY
-- ============================================

-- Total orders per city
SELECT c.city, COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.city;


-- ============================================
-- 11. SORT + AGGREGATION
-- ============================================

-- Top selling products by revenue
SELECT product_id, SUM(quantity * unit_price) AS revenue
FROM order_items
GROUP BY product_id
ORDER BY revenue DESC;



SELECT * FROM products WHERE price > 500 AND category = 'Electronics';

SELECT * FROM customers WHERE city = 'Kathmandu' OR city = 'Pokhara';


SELECT * FROM customers WHERE city not in('Kathmandu', 'Pokhara');


SELECT * FROM orders WHERE NOT status = 'Pending';




SELECT 'Kathmandu' AS city
UNION
SELECT 'Kathmandu';



SELECT 'Kathmandu' AS city
UNION ALL
SELECT 'Kathmandu';


SELECT order_date,
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month
FROM orders o




CREATE TABLE constraint_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2)
    	check (price > 0),
    stock_qty int default 0,
    made_in char(5) ---fill extra part by space
);

INSERT INTO constraint_products (product_id, product_name, category, price, stock_qty, made_in) VALUES
(100.5, 'Laptop', 'Electronics', 18000.00,default,'c'),
(102, 'Smartphone', 'Electronics', 45000.00,1,'Nepal'),
(103, 'Tablet', 'Electronics', 35000.00,2,'Nepal'),
(104, 'Headphones', 'Electronics', 5000.00,3,'Nepal');


select *
from constraint_products

drop table constraint_orders




CREATE TABLE constraint_orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    	check (status in ('Pending','Processing'))
);


INSERT INTO constraint_orders (order_id, customer_id, order_date, status) VALUES
(1, 101, '2026-03-01', 'Pending'),
(2, 102, '2026-03-02', 'Processing'),
(3, 103, '2026-03-03', 'Pending'),
--(4, 103, '2026-03-03', 'Delivered');



select *
from constraint_orders


INSERT INTO constraint_orders (order_id, customer_id, order_date, status)
VALUES (5, 200, '2026-03-10', NULL);


-------calculate the total number of orders and total sales for each month.
-- The output should show the year, month, total orders, and total sales, sorted by year and month.


SELECT 
    EXTRACT(YEAR FROM o.order_date) AS year,
    EXTRACT(MONTH FROM o.order_date) AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY 
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date)
ORDER BY year, month;

