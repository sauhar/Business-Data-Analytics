-- =====================================================
-- Advanced SQL Practice Exercises
-- Module 4: Advanced SQL & Window Functions
-- SkillShikshya - Business Data Analytics with AI
-- =====================================================

-- =====================================================
-- EXERCISE 1: Multi-Table Joins
-- =====================================================

-- Q1: Show customer name, product name, quantity, and order date for all orders
-- Expected: Join 4 tables

SELECT 
    c.name AS customer_name,
    p.product_name,
    oi.quantity,
    o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_date;


-- Q2: Find customers who live in the same city (Self Join)

SELECT 
    a.name AS customer1,
    b.name AS customer2,
    a.city
FROM customers a
JOIN customers b ON a.city = b.city
AND a.customer_id < b.customer_id
ORDER BY a.city, a.name;


-----Products with the same category (pair comparison)

SELECT p1.product_name AS product1,
       p2.product_name AS product2,
       p1.category
FROM products p1
JOIN products p2
  ON p1.category = p2.category
  AND p1.product_id < p2.product_id
ORDER BY p1.category;

-- =====================================================
-- EXERCISE 2: Subqueries (Non-Correlated)
-- These run ONCE and return a fixed value/list
-- =====================================================

-- Q3: Find products that cost more than the average price
-- This is a SUBQUERY - the inner query runs ONCE

SELECT product_name, category, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;


-- Q4: Find customers who have placed more than 2 orders

SELECT name, email, city
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(*) > 2
);




select *
from customers order by 2;


-- =====================================================
-- EXERCISE 3: Nested Queries (Correlated Subqueries)
-- These run for EACH row and reference the outer query
-- =====================================================

-- Q5: Find the most expensive product in each category
-- This is a NESTED/CORRELATED query - runs for EACH product

SELECT product_name, category, price
FROM products p1
WHERE price = (
    SELECT MAX(price)
    FROM products p2
    WHERE p2.category = p1.category   -- References outer query!
)
ORDER BY category;


-- Q6: Find customers whose total spending is above average
-- Correlated subquery example

SELECT c.name, c.city, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers c
WHERE (
    SELECT SUM(oi.quantity * oi.unit_price)
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id   -- References outer query!
) > (
    SELECT AVG(total) FROM (
        SELECT SUM(oi.quantity * oi.unit_price) AS total
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY o.customer_id
    ) AS customer_totals
);





-- Q7: Find orders where the order amount is above the customer's average order
-- Each row compared against that customer's own average

SELECT o.order_id, c.name, order_total, customer_avg
FROM (
    SELECT o.order_id, o.customer_id, 
           SUM(oi.quantity * oi.unit_price) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) o
JOIN customers c ON o.customer_id = c.customer_id
WHERE order_total > (
    SELECT AVG(order_amt)
    FROM (
        SELECT o2.customer_id, SUM(oi2.quantity * oi2.unit_price) AS order_amt
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        GROUP BY o2.order_id, o2.customer_id
    ) AS cust_orders
    WHERE cust_orders.customer_id = o.customer_id   -- Correlated!
);


-- =====================================================
-- EXERCISE 4: CASE Statements
-- =====================================================

-- Q8: Categorize products by price range

SELECT 
    product_name,
    price,
    CASE 
        WHEN price >= 50000 THEN 'Premium'
        WHEN price >= 10000 THEN 'Standard'
        WHEN price >= 1000 THEN 'Budget'
        ELSE 'Economy'
    END AS price_tier
FROM products
ORDER BY price DESC;


-- Q9: Categorize customers by total spending

SELECT 
    c.name,
    SUM(oi.quantity * oi.unit_price) AS total_spent,
    CASE 
        WHEN SUM(oi.quantity * oi.unit_price) >= 100000 THEN 'Gold'
        WHEN SUM(oi.quantity * oi.unit_price) >= 50000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;


-- =====================================================
-- EXERCISE 5: PIVOT Tables using CASE
-- Turn rows into columns - like Excel Pivot Tables!
-- =====================================================

-- Q10: PIVOT - Show total sales by category as columns for each city

SELECT 
    c.city,
    SUM(CASE WHEN p.category = 'Electronics' THEN oi.quantity * oi.unit_price ELSE 0 END) AS Electronics,
    SUM(CASE WHEN p.category = 'Clothing' THEN oi.quantity * oi.unit_price ELSE 0 END) AS Clothing,
    SUM(CASE WHEN p.category = 'Accessories' THEN oi.quantity * oi.unit_price ELSE 0 END) AS Accessories,
    SUM(CASE WHEN p.category = 'Home' THEN oi.quantity * oi.unit_price ELSE 0 END) AS Home,
    SUM(CASE WHEN p.category = 'Stationery' THEN oi.quantity * oi.unit_price ELSE 0 END) AS Stationery
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.city
ORDER BY c.city;


-- Q11: PIVOT - Order count by status for each city

SELECT 
    c.city,
    COUNT(CASE WHEN o.status = 'Delivered' THEN 1 END) AS Delivered,
    COUNT(CASE WHEN o.status = 'Shipped' THEN 1 END) AS Shipped,
    COUNT(CASE WHEN o.status = 'Processing' THEN 1 END) AS Processing,
    COUNT(CASE WHEN o.status = 'Pending' THEN 1 END) AS Pending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY c.city;


-- Q12: PIVOT - Product quantity sold by month (Jan, Feb, Mar, Apr)
-- Note: Use EXTRACT(MONTH FROM date) for PostgreSQL, MONTH(date) for MySQL

SELECT 
    p.product_name,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.order_date) = 1 THEN oi.quantity ELSE 0 END) AS Jan,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.order_date) = 2 THEN oi.quantity ELSE 0 END) AS Feb,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.order_date) = 3 THEN oi.quantity ELSE 0 END) AS Mar,
    SUM(CASE WHEN EXTRACT(MONTH FROM o.order_date) = 4 THEN oi.quantity ELSE 0 END) AS Apr
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name
ORDER BY p.product_name;


-- =====================================================
-- EXERCISE 6: ROW_NUMBER, RANK, DENSE_RANK
-- =====================================================

-- Q13: Number all customers alphabetically

SELECT 
    name,
    city,
    ROW_NUMBER() OVER (ORDER BY name) AS row_num
FROM customers;


-- Q14: Number customers within each city

SELECT 
    name,
    city,
    ROW_NUMBER() OVER (PARTITION BY city ORDER BY name) AS row_in_city
FROM customers
ORDER BY city, row_in_city;


-- Q15: Rank products by price (show RANK vs DENSE_RANK difference)

SELECT 
    product_name,
    category,
    price,
    RANK() OVER (ORDER BY price DESC) AS rank_num,
    DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank_num
FROM products;


-- Q16: Rank products within each category by price

SELECT 
    category,
    product_name,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category
FROM products
ORDER BY category, rank_in_category;


-- Q17: Find top 3 products in each category

SELECT *
FROM (
    SELECT 
        category,
        product_name,
        price,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS rn
    FROM products
) ranked
WHERE rn <= 3
ORDER BY category, rn;


-- =====================================================
-- EXERCISE 7: LAG and LEAD
-- =====================================================

-- Q18: Show daily sales with previous day's revenue

SELECT 
    sale_date,
    total_revenue,
    LAG(total_revenue, 1) OVER (ORDER BY sale_date) AS prev_day_revenue
FROM daily_sales
ORDER BY sale_date;


-- Q19: Calculate day-over-day change in revenue

SELECT 
    sale_date,
    total_revenue,
    LAG(total_revenue, 1) OVER (ORDER BY sale_date) AS prev_day,
    total_revenue - LAG(total_revenue, 1) OVER (ORDER BY sale_date) AS daily_change,
    ROUND(
        (total_revenue - LAG(total_revenue, 1) OVER (ORDER BY sale_date)) * 100.0 / 
        LAG(total_revenue, 1) OVER (ORDER BY sale_date), 
    2) AS pct_change
FROM daily_sales
ORDER BY sale_date;


-- Q20: Compare each day with next day

SELECT 
    sale_date,
    total_revenue AS today,
    LEAD(total_revenue, 1) OVER (ORDER BY sale_date) AS tomorrow,
    LEAD(sale_date, 1) OVER (ORDER BY sale_date) AS tomorrow_date
FROM daily_sales
ORDER BY sale_date;


-- =====================================================
-- EXERCISE 8: Running Total & Moving Average
-- =====================================================

-- Q21: Calculate running total of daily revenue

SELECT 
    sale_date,
    total_revenue,
    SUM(total_revenue) OVER (ORDER BY sale_date) AS running_total
FROM daily_sales
ORDER BY sale_date;


-- Q22: Calculate 3-day moving average

SELECT 
    sale_date,
    total_revenue,
    ROUND(
        AVG(total_revenue) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 
    2) AS moving_avg_3day
FROM daily_sales
ORDER BY sale_date;


-- Q23: Calculate 7-day moving average

SELECT 
    sale_date,
    total_revenue,
    ROUND(
        AVG(total_revenue) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 
    2) AS moving_avg_7day
FROM daily_sales
ORDER BY sale_date;


-- =====================================================
-- EXERCISE 9: Common Table Expressions (CTEs)
-- =====================================================

-- Q24: Find high-spending customers using CTE

WITH customer_totals AS (
    SELECT 
        c.customer_id,
        c.name,
        c.city,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.name, c.city
)
SELECT name, city, total_spent
FROM customer_totals
WHERE total_spent > 50000
ORDER BY total_spent DESC;

----------------------------------

-- STEP 1: build the temp table ONCE
CREATE TEMP TABLE cust_summary AS
SELECT c.customer_id, c.name, c.city,
  COUNT(DISTINCT o.order_id)     AS total_orders,
  SUM(oi.quantity*oi.unit_price) AS total_spent
FROM   customers c
JOIN   orders o      ON c.customer_id = o.customer_id
JOIN   order_items oi ON o.order_id   = oi.order_id
GROUP  BY c.customer_id, c.name, c.city;

-- STEP 2: query it multiple times (no re-computing!)
SELECT name, city, total_spent
FROM   cust_summary  WHERE total_spent > 50000
ORDER  BY total_spent DESC;





-- Q25: Analyze sales by category using CTE

WITH category_sales AS (
    SELECT 
        p.category,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.category
)
SELECT 
    category,
    total_quantity,
    total_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER (), 2) AS pct_of_total
FROM category_sales
ORDER BY total_revenue DESC;


-- =====================================================
-- EXERCISE 10: Comprehensive Analysis
-- =====================================================

-- Q26: Complete customer behavior analysis

WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.name,
        c.city,
        c.join_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price) AS total_spent,
        MIN(o.order_date) AS first_order,
        MAX(o.order_date) AS last_order
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.name, c.city, c.join_date
)
SELECT 
    name,
    city,
    total_orders,
    total_spent,
    first_order,
    last_order,
    CASE 
        WHEN total_spent >= 100000 THEN 'Gold'
        WHEN total_spent >= 50000 THEN 'Silver'
        WHEN total_spent > 0 THEN 'Bronze'
        ELSE 'No Purchase'
    END AS customer_tier,
    RANK() OVER (ORDER BY total_spent DESC) AS spending_rank,
    RANK() OVER (PARTITION BY city ORDER BY total_spent DESC) AS city_rank
FROM customer_metrics
ORDER BY total_spent DESC;


---------------------index

--- Run Query WITHOUT Index


EXPLAIN ANALYZE
SELECT *
FROM customers
WHERE city = 'Kathmandu';



create index idx_city
on customers(city)


select *
from dirty_cafe_sales_dataset limit 10

create index idx_transaction_id
on dirty_cafe_sales_dataset(transaction_id)

drop index idx_transaction_id

explain analyze
select *
from dirty_cafe_sales_dataset
where transaction_id = 'TXN_9899571'











