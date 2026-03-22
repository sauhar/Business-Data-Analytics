
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

