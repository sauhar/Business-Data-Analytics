-- =========================================
-- DROP TABLES (if exist)
-- =========================================
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS teachers;

-- =========================================
-- CREATE TABLES
-- =========================================

CREATE TABLE teachers (
    teacher_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    teacher_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE subjects (
    subject_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    subject_name VARCHAR(100),
    teacher_id INT REFERENCES teachers(teacher_id)
);


CREATE TABLE students (
    student_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    student_name VARCHAR(100),
    city VARCHAR(50),
    is_active BOOLEAN
);

CREATE TABLE enrollments (
    enrollment_id INT GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    subject_id INT REFERENCES subjects(subject_id),
    grade VARCHAR(5)
);

-- =========================================
-- INSERT DATA
-- =========================================

-- Teachers
INSERT INTO teachers (teacher_name, city) VALUES
('Ramesh Shrestha', 'Kathmandu'),
('Sunita Tamang', 'Pokhara'),
('Sandesh Adhikari', 'Kathmandu'),
('Anita Maharjan', 'Lalitpur');




-- Subjects
INSERT INTO subjects(subject_name, teacher_id) VALUES
('Mathematics', 1),
('Computer Science', 2),
('Accountancy', 3),
('English', 3),
('Physics', NULL);


select *
from subjects



ALTER TABLE teachers
DROP COLUMN phone;




-- Students
INSERT INTO students (student_name, city, is_active)  VALUES
('Aarav Thapa', 'Kathmandu', TRUE),
('Priya Gurung', 'Pokhara', TRUE),
('Suman Poudel', 'Butwal', TRUE),
('Kabita Shrestha', 'Kathmandu', FALSE),
('Rohan Dahal', 'Chitwan', TRUE);



select *
from students

SELECT student_name, is_active::text AS is_active
FROM students;



-- Enrollments
INSERT INTO enrollments (student_id, subject_id, grade) VALUES
(1, 1, 'A'),
(1, 2, 'B+'),
(1, 3, 'A'),
(2, 1, 'B'),
(2, 2, 'A+'),
(3, 3, 'C'),
(3, 4, 'B'),
(4, 1, 'A');


select *
from enrollments




------------------------------


------one to many

SELECT s.subject_name, t.teacher_name
FROM subjects s
JOIN teachers t ON s.teacher_id = t.teacher_id;


SELECT t.teacher_name,
  COUNT(s.subject_id) AS total
FROM teachers t
JOIN subjects s ON t.teacher_id = s.teacher_id
GROUP BY t.teacher_name;



-----many to many

SELECT st.student_name, su.subject_name, e.grade
FROM enrollments e
JOIN students st ON e.student_id = st.student_id
JOIN subjects  su ON e.subject_id = su.subject_id;



------union

SELECT city FROM teachers
UNION
SELECT city FROM students;


----union all

SELECT city FROM teachers
UNION ALL
SELECT city FROM students;


---self join

SELECT a.student_name AS student_1,
       b.student_name AS student_2, a.city
FROM students a
JOIN students b ON a.city = b.city
             AND a.student_id < b.student_id;



SELECT st.student_name, su.subject_name
FROM students st
CROSS JOIN subjects su
ORDER BY st.student_name;


select *
from students


BEGIN;  -- Start the transaction

  -- Step 1: Add the student
  INSERT INTO students (student_name, city, is_active)
  VALUES ('Manisha Lama', 'Kathmandu', TRUE);



COMMIT;  -- Save both changes together



select *
from customers;


select *
from orders



SELECT 
    c.city,
    COUNT(CASE WHEN o.status = 'Delivered' THEN 1 END) AS Delivered,
    COUNT(CASE WHEN o.status = 'Shipped' THEN 1 END) AS Shipped,
    COUNT(CASE WHEN o.status = 'Processing' THEN 1 END) AS Processing
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.city;



SELECT 
    o.customer_id,
    COUNT(CASE WHEN o.status = 'Delivered' THEN 1 END) AS Delivered,
    COUNT(CASE WHEN o.status = 'Shipped' THEN 1 END) AS Shipped,
    COUNT(CASE WHEN o.status = 'Processing' THEN 1 END) AS Processing
FROM orders o
group by 1 order by 1


select *
from customers


SELECT name, city,
       ROW_NUMBER() OVER (ORDER BY name) AS row_num
FROM customers order by 1;



SELECT product_name, price,
       RANK() OVER (ORDER BY price DESC) AS rank,
       DENSE_RANK() OVER (ORDER BY price DESC) AS dense_rank
FROM products;



SELECT sale_date, total_revenue,
       LAG(total_revenue, 1) OVER (ORDER BY sale_date) AS prev_day,
       LEAD(total_revenue, 1) OVER (ORDER BY sale_date) AS next_day
FROM daily_sales;




WITH customer_totals AS (
  SELECT c.customer_id,c.name,c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity*oi.unit_price) AS total_spent
  FROM customers c
  JOIN orders o ON c.customer_id=o.customer_id
  JOIN order_items oi ON o.order_id=oi.order_id
  GROUP BY c.customer_id,c.name,c.city
)
SELECT name,city,total_orders,total_spent
FROM   customer_totals
WHERE  total_spent > 50000
ORDER  BY total_spent DESC;


WITH customer_cte_ktm AS (
  SELECT 
    customer_id,
    name,
    city
  FROM customers
  WHERE city = 'Kathmandu'
)
SELECT *
FROM customer_cte_ktm;


CREATE TEMP TABLE temp_customers AS
SELECT 
  customer_id,
  name,
  city
FROM customers
WHERE city = 'Kathmandu';

SELECT *
FROM temp_customers;


DROP TABLE temp_customers;





--nested query

SELECT product_name, category, price
FROM products p1
WHERE price = (
    SELECT MAX(price) FROM products p2
    WHERE p2.category = p1.category   -- References outer query!
);


--sub query

SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);




-------------------windows function

CREATE TABLE windows_function_table (
    id INT,
    name VARCHAR(50),
    city VARCHAR(50),
    score INT
);

INSERT INTO windows_function_table VALUES
(1, 'A', 'Kathmandu', 90),
(2, 'B', 'Kathmandu', 80),
(3, 'C', 'Kathmandu', 80),
(4, 'D', 'Kathmandu', 70),

(5, 'E', 'Pokhara', 95),
(6, 'F', 'Pokhara', 95),
(7, 'G', 'Pokhara', 85),
(8, 'H', 'Pokhara', 80);


select *
from windows_function_table


SELECT 
    id,
    name,
    city,
    score,

    ROW_NUMBER() OVER (
        PARTITION BY city 
        ORDER BY score DESC
    ) AS row_num,

    RANK() OVER (
        PARTITION BY city 
        ORDER BY score DESC
    ) AS rank_num,

    DENSE_RANK() OVER (
        PARTITION BY city 
        ORDER BY score DESC
    ) AS dense_rank_num

FROM windows_function_table;


