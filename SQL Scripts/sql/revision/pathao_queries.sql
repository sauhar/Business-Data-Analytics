-- ============================================================
--  PATHAO NEPAL — SQL Revision Questions & Answers
--  SkillShikshya · Business Data Analytics with AI
--  Simple → Intermediate · Nepal-based real scenarios
-- ============================================================
--
--  TOPICS COVERED (matching your slides):
--  LEVEL 1 (Basic)      — SELECT, WHERE, ORDER BY, GROUP BY, aggregates
--  LEVEL 2 (Basic+)     — JOINs (INNER, LEFT, RIGHT, FULL, SELF)
--  LEVEL 3 (Intermed.)  — UNION/UNION ALL, Subqueries, CASE, PIVOT
--  LEVEL 4 (Intermed.)  — Window Functions, CTE, Temp Tables
--  BONUS               — DDL/DML: ALTER, INSERT, UPDATE, DELETE, TCL
-- ============================================================

-- ════════════════════════════════════════════════════════════
-- LEVEL 1 — BASIC SELECT, FILTER, SORT, AGGREGATE
-- ════════════════════════════════════════════════════════════


-- Q1. Show all active riders with their city.
SELECT rider_id, full_name, phone, city
FROM   riders
WHERE  is_active = TRUE
ORDER BY full_name;

-- Q2. How many rides were completed vs cancelled?
SELECT status,
       COUNT(*) AS total_rides
FROM   rides
GROUP  BY status
ORDER  BY total_rides DESC;


-- Q3. What is the total fare collected from all COMPLETED rides?
SELECT SUM(fare_nrs) AS total_fare_collected
FROM   rides
WHERE  status = 'Completed';

-- Q4. Show the top 5 highest-fare rides with rider_id and driver_id.
SELECT ride_id,
       rider_id,
       driver_id,
       pickup,
       dropoff,
       fare_nrs
FROM   rides
ORDER  BY fare_nrs DESC
LIMIT  5;

-- Q5. How many riders joined Pathao in 2023?
SELECT COUNT(*) AS riders_joined_2023
FROM   riders
WHERE  joined_date >= '2023-01-01'
  AND  joined_date <= '2023-12-31';


-- Q6. What is the average driver rating per zone?
--     (zone_id only — we join zones in next level)
SELECT zone_id,
       ROUND(AVG(rating), 2) AS avg_rating,
       COUNT(*)              AS total_drivers
FROM   drivers
WHERE  is_active = TRUE
GROUP  BY zone_id
ORDER  BY avg_rating DESC;

-- Q7. Show all rides where distance was more than 8 km.
SELECT ride_id,
       pickup,
       dropoff,
       distance_km,
       fare_nrs
FROM   rides
WHERE  distance_km > 8
ORDER  BY distance_km DESC;

-- Q8. What payment methods are used? Show count for each and the amount
SELECT method,
       COUNT(*)           AS total_payments,
       SUM(amount_nrs)    AS total_amount
FROM   payments
GROUP  BY method
ORDER  BY total_amount DESC;

-- Q9. Show all rides from January 2024 only.
SELECT ride_id, rider_id, pickup, dropoff, ride_date, fare_nrs
FROM   rides
WHERE  ride_date >= '2024-01-01'
  AND  ride_date <  '2024-02-01'
ORDER  BY ride_date;

SELECT ride_id, rider_id, pickup, dropoff, ride_date, fare_nrs
FROM   rides
where ride_date between '2024-01-01' and '2024-01-31'
ORDER  BY ride_date;


-- Q10. Find the rider who has the highest single ride fare.
SELECT rider_id, fare_nrs, pickup, dropoff
FROM   rides
WHERE  fare_nrs = (SELECT MAX(fare_nrs) FROM rides);

-- ════════════════════════════════════════════════════════════
-- LEVEL 2 — JOINS (INNER, LEFT, RIGHT, FULL, SELF)
-- ════════════════════════════════════════════════════════════

-- Q11. Show each completed ride with the rider's full name and city.
SELECT r.ride_id,
       ri.full_name    AS rider_name,
       ri.city,
       r.pickup,
       r.dropoff,
       r.fare_nrs
FROM   rides r
INNER  JOIN riders ri ON r.rider_id = ri.rider_id
WHERE  r.status = 'Completed'
ORDER  BY r.ride_date;



SELECT r.*, ri.*
FROM   rides r
INNER  JOIN riders ri ON r.rider_id = ri.rider_id
WHERE  r.status = 'Completed'
ORDER  BY r.ride_date;


-- Q12. Show each completed ride with rider name AND driver name.
SELECT r.ride_id,
       ri.full_name    AS rider_name,
       d.full_name     AS driver_name,
       d.rating        AS driver_rating,
       r.pickup,
       r.dropoff,
       r.fare_nrs,
       r.ride_date
FROM   rides r
INNER  JOIN riders  ri ON r.rider_id  = ri.rider_id
INNER  JOIN drivers d  ON r.driver_id = d.driver_id
WHERE  r.status = 'Completed'
ORDER  BY r.ride_date;


-- Q13. Show every ride with its zone name, driver name, vehicle type.
--      (4-table JOIN)
SELECT r.ride_id,
       ri.full_name    AS rider,
       d.full_name     AS driver,
       v.vehicle_type,
       v.model,
       z.zone_name,
       r.fare_nrs,
       r.status
FROM   rides r
INNER  JOIN riders  ri ON r.rider_id  = ri.rider_id
INNER  JOIN drivers d  ON r.driver_id = d.driver_id
INNER  JOIN vehicles v ON d.driver_id = v.driver_id
INNER  JOIN zones    z ON r.zone_id   = z.zone_id
ORDER  BY r.ride_date;


-- Q14. LEFT JOIN — Show ALL drivers including those with NO rides yet.
SELECT d.full_name   AS driver_name,
       d.rating,
       COUNT(r.ride_id) AS total_rides
FROM   drivers d
LEFT   JOIN rides r  ON d.driver_id = r.driver_id
GROUP  BY d.driver_id, d.full_name, d.rating
ORDER  BY total_rides DESC;

-- Q15. LEFT JOIN — Show ALL zones including ones with no drivers assigned.
SELECT z.zone_name,
       z.district,
       COUNT(d.driver_id) AS total_drivers
FROM   zones z
LEFT   JOIN drivers d ON z.zone_id = d.zone_id
GROUP  BY z.zone_id, z.zone_name, z.district
ORDER  BY total_drivers DESC;

-- Q16. RIGHT JOIN — Show ALL payment records with ride details.
--      (even payments whose ride might be missing — data integrity check)
SELECT p.payment_id,
       p.method,
       p.amount_nrs,
       p.status        AS payment_status,
       r.pickup,
       r.dropoff,
       r.status        AS ride_status
FROM   rides r
RIGHT  JOIN payments p ON r.ride_id = p.ride_id
ORDER  BY p.paid_at;

-- Q17. FULL OUTER JOIN — Find any rides without a payment
--      AND any payments without a ride (data quality check).
SELECT r.ride_id,
       r.status        AS ride_status,
       p.payment_id,
       p.method,
       p.status        AS payment_status
FROM   rides r
FULL   OUTER JOIN payments p ON r.ride_id = p.ride_id
WHERE  r.ride_id IS NULL
   OR  p.payment_id IS NULL;

-- Q18. SELF JOIN — Find pairs of drivers working in the SAME zone.
SELECT a.full_name  AS driver_1,
       b.full_name  AS driver_2,
       a.zone_id
FROM   drivers a
INNER  JOIN drivers b
       ON  a.zone_id   = b.zone_id
       AND a.driver_id < b.driver_id   -- avoid duplicates
WHERE  a.is_active = TRUE
ORDER  BY a.zone_id;

-- Q19. Many-to-Many JOIN — Show which riders used which promo codes.
SELECT ri.full_name   AS rider_name,
       r.ride_id,
       p.code         AS promo_code,
       p.discount_pct AS discount_percent,
       r.fare_nrs     AS original_fare,
       ROUND(r.fare_nrs * (1 - p.discount_pct / 100.0), 2) AS discounted_fare
FROM   ride_promotions rp
INNER  JOIN rides      r  ON rp.ride_id  = r.ride_id
INNER  JOIN riders     ri ON r.rider_id  = ri.rider_id
INNER  JOIN promotions p  ON rp.promo_id = p.promo_id
ORDER  BY ri.full_name;

-- Q20. How many rides and total fare per zone?
--      (INNER JOIN: rides → zones)
SELECT z.zone_name,
       COUNT(r.ride_id)    AS total_rides,
       SUM(r.fare_nrs)     AS total_fare,
       ROUND(AVG(r.fare_nrs), 2) AS avg_fare
FROM   zones z
INNER  JOIN rides r ON z.zone_id = r.zone_id
GROUP  BY z.zone_id, z.zone_name
ORDER  BY total_fare DESC;


-- ════════════════════════════════════════════════════════════
-- LEVEL 3 — UNION, SUBQUERY, CASE, PIVOT
-- ════════════════════════════════════════════════════════════

-- Q21. UNION — Create one combined contact list of
--      all riders AND all drivers (name + phone + role).
SELECT full_name, phone, 'Rider'  AS role FROM riders  WHERE is_active = TRUE
UNION
SELECT full_name, phone, 'Driver' AS role FROM drivers WHERE is_active = TRUE
ORDER BY full_name;

-- Q22. UNION ALL — List all cities from riders + drivers
--      (with duplicates — to count frequency).
SELECT full_name, phone, 'Rider'  AS role FROM riders  WHERE is_active = TRUE
union ALL
SELECT full_name, phone, 'Driver' AS role FROM drivers WHERE is_active = TRUE
ORDER BY full_name;





-- Q23. Subquery — Find all rides that cost MORE than the average fare.

SELECT ride_id,
       pickup,
       dropoff,
       fare_nrs
FROM   rides
WHERE  fare_nrs > (SELECT AVG(fare_nrs) FROM rides)
ORDER  BY fare_nrs DESC;



---Show rides taken by riders who live in Pokhara

SELECT ride_id,
       rider_id,
       pickup,
       dropoff,
       fare_nrs,
       status
FROM   rides
WHERE  rider_id IN (SELECT rider_id
                    FROM   riders
                    WHERE  city = 'Pokhara')
ORDER  BY ride_id;


-- Q24. Correlated Subquery — For each zone, show the ride with
--      the HIGHEST fare in that zone.
SELECT r.ride_id,
       r.zone_id,
       r.pickup,
       r.dropoff,
       r.fare_nrs
FROM   rides r
WHERE  r.fare_nrs = (
    SELECT MAX(r2.fare_nrs)
    FROM   rides r2
    WHERE  r2.zone_id = r.zone_id   -- references outer query
)
ORDER  BY r.zone_id;

-- Q25. CASE — Categorise every ride by fare range
--      (Budget, Standard, Premium).
SELECT ride_id,
       pickup,
       dropoff,
       fare_nrs,
       CASE
           WHEN fare_nrs >= 250 THEN 'Premium'
           WHEN fare_nrs >= 150 THEN 'Standard'
           ELSE                      'Budget'
       END AS fare_category
FROM   rides
WHERE  status = 'Completed'
ORDER  BY fare_nrs DESC;

-- Q26. CASE — Classify drivers by rating tier.
SELECT full_name,
       rating,
       CASE
           WHEN rating >= 4.8 THEN 'Excellent'
           WHEN rating >= 4.5 THEN 'Good'
           WHEN rating >= 4.0 THEN 'Average'
           ELSE                    'Needs Improvement'
       END AS rating_tier
FROM   drivers
WHERE  is_active = TRUE
ORDER  BY rating DESC;

-- Q27. PIVOT — Show count of completed rides per payment method
--      as separate columns (Cash | eSewa | Khalti | Bank).
SELECT
    COUNT(CASE WHEN p.method = 'Cash'   THEN 1 END) AS cash_rides,
    COUNT(CASE WHEN p.method = 'eSewa'  THEN 1 END) AS esewa_rides,
    COUNT(CASE WHEN p.method = 'Khalti' THEN 1 END) AS khalti_rides,
    COUNT(CASE WHEN p.method = 'Bank'   THEN 1 END) AS bank_rides
FROM   payments p
INNER  JOIN rides r ON p.ride_id = r.ride_id
WHERE  r.status = 'Completed';



-- ════════════════════════════════════════════════════════════
-- LEVEL 4 — WINDOW FUNCTIONS, CTE, TEMP TABLE
-- ════════════════════════════════════════════════════════════

-- Q29. ROW_NUMBER — Rank all rides by fare (highest first)
--      within each zone.
SELECT r.ride_id,
       z.zone_name,
       r.pickup,
       r.dropoff,
       r.fare_nrs,
       ROW_NUMBER() OVER (
           PARTITION BY r.zone_id
           ORDER BY r.fare_nrs DESC
       ) AS rank_in_zone
FROM   rides r
INNER  JOIN zones z ON r.zone_id = z.zone_id
WHERE  r.status = 'Completed'
ORDER  BY z.zone_name, rank_in_zone;

-- Q30. RANK vs DENSE_RANK — Rank all drivers by total rides completed.
SELECT d.full_name,
       COUNT(r.ride_id)    AS completed_rides,
       RANK()       OVER (ORDER BY COUNT(r.ride_id) DESC) AS rank_with_gap,
       DENSE_RANK() OVER (ORDER BY COUNT(r.ride_id) DESC) AS rank_no_gap
FROM   drivers d
LEFT   JOIN rides r
       ON  d.driver_id = r.driver_id
       AND r.status = 'Completed'
GROUP  BY d.driver_id, d.full_name
ORDER  BY completed_rides DESC;

-- Q31. LAG — Show each day's total fare and the PREVIOUS day's fare
--      to calculate day-over-day change.
SELECT ride_date,
       SUM(fare_nrs)                                           AS daily_fare,
       LAG(SUM(fare_nrs), 1) OVER (ORDER BY ride_date)         AS prev_day_fare,
       SUM(fare_nrs)
           - LAG(SUM(fare_nrs), 1) OVER (ORDER BY ride_date)   AS change
FROM   rides
WHERE  status = 'Completed'
GROUP  BY ride_date
ORDER  BY ride_date;

-- Q32. Running Total — Show cumulative fare earned day by day.
SELECT ride_date,
       SUM(fare_nrs)                                    AS daily_fare,
       SUM(SUM(fare_nrs)) OVER (ORDER BY ride_date)     AS running_total
FROM   rides
WHERE  status = 'Completed'
GROUP  BY ride_date
ORDER  BY ride_date;

-- Q33. CTE — Find top spending riders (total fare > 400).
WITH rider_totals AS (
    SELECT r.rider_id,
           ri.full_name,
           ri.city,
           COUNT(r.ride_id)       AS total_rides,
           SUM(r.fare_nrs)        AS total_spent
    FROM   rides r
    INNER  JOIN riders ri ON r.rider_id = ri.rider_id
    WHERE  r.status = 'Completed'
    GROUP  BY r.rider_id, ri.full_name, ri.city
)
SELECT full_name,
       city,
       total_rides,
       total_spent
FROM   rider_totals
WHERE  total_spent > 400
ORDER  BY total_spent DESC;

-- Q34. CTE — Find drivers with above-average ratings who also
--      have at least 2 completed rides.
WITH driver_stats AS (
    SELECT d.driver_id,
           d.full_name,
           d.rating,
           COUNT(r.ride_id) AS completed_rides
    FROM   drivers d
    LEFT   JOIN rides r
           ON  d.driver_id = r.driver_id
           AND r.status = 'Completed'
    GROUP  BY d.driver_id, d.full_name, d.rating
),
avg_rating AS (
    SELECT AVG(rating) AS overall_avg FROM drivers WHERE is_active = TRUE
)
SELECT ds.full_name,
       ds.rating,
       ds.completed_rides,
       ROUND(ar.overall_avg, 2) AS avg_all_drivers
FROM   driver_stats ds, avg_rating ar
WHERE  ds.rating > ar.overall_avg
  AND  ds.completed_rides >= 2
ORDER  BY ds.rating DESC;

-- Q35. TEMP TABLE — Build a summary of each rider's activity
--      and reuse it for two different queries.

-- Step 1: create once
CREATE TEMP TABLE rider_summary AS
SELECT r.rider_id,
       ri.full_name,
       ri.city,
       COUNT(r.ride_id)            AS total_rides,
       SUM(r.fare_nrs)             AS total_spent,
       ROUND(AVG(r.fare_nrs), 2)   AS avg_fare,
       MAX(r.ride_date)            AS last_ride_date
FROM   rides r
INNER  JOIN riders ri ON r.rider_id = ri.rider_id
WHERE  r.status = 'Completed'
GROUP  BY r.rider_id, ri.full_name, ri.city;

-- Step 2a: top riders by total spent
SELECT full_name, city, total_rides, total_spent
FROM   rider_summary
ORDER  BY total_spent DESC
LIMIT  5;

-- Step 2b: riders who haven't ridden since Feb 2024
SELECT full_name, city, last_ride_date
FROM   rider_summary
WHERE  last_ride_date < '2024-02-01';

-- Clean up
DROP TABLE rider_summary;


-- ════════════════════════════════════════════════════════════
-- BONUS — DDL / DML / TCL OPERATIONS
-- ════════════════════════════════════════════════════════════

-- B1. ALTER TABLE — Add a 'loyalty_points' column to riders.
ALTER TABLE riders
ADD COLUMN loyalty_points INT DEFAULT 0;

-- B2. UPDATE — Set loyalty points = total completed rides × 10.
UPDATE riders
SET    loyalty_points = (
    SELECT COUNT(*) * 10
    FROM   rides
    WHERE  rides.rider_id = riders.rider_id
      AND  rides.status   = 'Completed'
);

-- B3. INSERT — Add a new rider from Pokhara.
INSERT INTO riders (full_name, phone, email, city, joined_date, is_active)
VALUES ('Kabita Gurung', '9812345678', 'kabita@gmail.com', 'Pokhara', '2024-03-15', TRUE);

-- B4. DELETE — Remove all cancelled rides older than Feb 2024.
DELETE FROM rides
WHERE  status   = 'Cancelled'
  AND  ride_date < '2024-02-01';

-- B5. TRANSACTION — Safely transfer a ride from one driver to another.
BEGIN;
    -- Deactivate old driver
    UPDATE drivers
    SET    is_active = FALSE
    WHERE  driver_id = 10;

    -- Reassign their pending ride to driver 1
    UPDATE rides
    SET    driver_id = 1
    WHERE  driver_id = 10
      AND  status    = 'Ongoing';

COMMIT;
-- ROLLBACK;  -- use this to undo if something is wrong

-- B6. GRANT — Give read-only access to an analyst user.
-- GRANT SELECT ON rides, riders, drivers, zones TO analyst_user;

-- B7. REVOKE — Remove insert permission from that user.
-- REVOKE INSERT ON rides FROM analyst_user;






------------------------------------------index vs seq scan


-- Drop and recreate cleanly
DROP TABLE IF EXISTS new_employees;

CREATE TABLE new_employees (
    emp_id SERIAL PRIMARY KEY,
    name   VARCHAR(50),
    salary INT
);

-- Insert 100,000 rows so PostgreSQL takes index seriously
INSERT INTO new_employees (name, salary)
SELECT 
    'Employee_' || i,
    (random() * 100000)::INT
FROM generate_series(1, 100000) as i;


SELECT random() --0 ≤ x < 1


---() is not a default table
---It is a built-in PostgreSQL temporary  that returns temporary data
SELECT * FROM generate_series(1, 25);


select count(*)
from new_employees;

select *
from new_employees limit 20;

-- Create indexes
CREATE INDEX idx_salary ON new_employees(salary);
CREATE INDEX idx_name   ON new_employees(name);


-- Query 1: Find 1 row → should use Index Scan
EXPLAIN ANALYZE
SELECT * FROM new_employees
WHERE emp_id = 2;

-- Very few rows → Index Scan


-- Query 2: Find ~half rows → Bitmap or Seq Scan  
EXPLAIN ANALYZE
SELECT * FROM new_employees 
WHERE salary > 50000;
-- Medium rows → Bitmap Scan == group the category


-- Query 3: Find almost all rows → Seq Scan
EXPLAIN ANALYZE
SELECT * FROM new_employees 
WHERE salary > 0;
-- Almost all rows → Seq Scan

SELECT datname FROM pg_database;

--------------Function breaks index

EXPLAIN ANALYZE
SELECT * FROM new_employees
WHERE name = 'Employee_500';


-- Now wrap in UPPER() — index breaks, Seq Scan works

EXPLAIN ANALYZE
SELECT * FROM new_employees
WHERE UPPER(name) = 'EMPLOYEE_500';