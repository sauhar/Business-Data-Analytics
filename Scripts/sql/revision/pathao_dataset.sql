-- ============================================================
--  PATHAO NEPAL — Revision Dataset
--  SkillShikshya · Business Data Analytics with AI
--
--  Tables:
--    riders         → customers who book rides
--    drivers        → Pathao driver partners
--    vehicles       → each driver's vehicle
--    rides          → every trip booked
--    payments       → payment for each ride
--    zones          → service zones (Kathmandu, Pokhara, etc.)
--    promotions     → discount codes
--    ride_promotions → junction table (rides ↔ promotions)
-- ============================================================

-- ── DROP & CREATE ────────────────────────────────────────────

DROP TABLE IF EXISTS ride_promotions;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS rides;
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS zones;


-- Zone / Service area
CREATE TABLE zones (
    zone_id      SERIAL PRIMARY KEY,
    zone_name    VARCHAR(50)  NOT NULL,
    district     VARCHAR(50)  NOT NULL,
    is_active    BOOLEAN      DEFAULT TRUE
);

-- Riders (customers)
CREATE TABLE riders (
    rider_id     SERIAL PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    phone        VARCHAR(15)  UNIQUE NOT NULL,
    email        VARCHAR(100),
    city         VARCHAR(50)  NOT NULL,
    joined_date  DATE         NOT NULL,
    is_active    BOOLEAN      DEFAULT TRUE
);

-- Drivers
CREATE TABLE drivers (
    driver_id    SERIAL PRIMARY KEY,
    full_name    VARCHAR(100) NOT NULL,
    phone        VARCHAR(15)  UNIQUE NOT NULL,
    zone_id      INT          REFERENCES zones(zone_id),  -- FK → zones
    license_no   VARCHAR(20)  UNIQUE NOT NULL,
    rating       NUMERIC(3,2) DEFAULT 5.00,
    joined_date  DATE         NOT NULL,
    is_active    BOOLEAN      DEFAULT TRUE
);

-- Vehicles (One driver → one vehicle at a time)
CREATE TABLE vehicles (
    vehicle_id   SERIAL PRIMARY KEY,
    driver_id    INT          REFERENCES drivers(driver_id), -- FK → drivers
    vehicle_type VARCHAR(30)  NOT NULL,  -- Bike, Car, E-Scooter
    plate_no     VARCHAR(15)  UNIQUE NOT NULL,
    model        VARCHAR(50)  NOT NULL,
    year         INT          NOT NULL
);

-- Rides (core fact table)
CREATE TABLE rides (
    ride_id      SERIAL PRIMARY KEY,
    rider_id     INT          REFERENCES riders(rider_id),   -- FK
    driver_id    INT          REFERENCES drivers(driver_id), -- FK
    zone_id      INT          REFERENCES zones(zone_id),     -- FK
    pickup       VARCHAR(100) NOT NULL,
    dropoff      VARCHAR(100) NOT NULL,
    ride_date    DATE         NOT NULL,
    ride_time    TIME         NOT NULL,
    distance_km  NUMERIC(5,2) NOT NULL,
    fare_nrs     NUMERIC(8,2) NOT NULL,
    status       VARCHAR(20)  NOT NULL  -- Completed, Cancelled, Ongoing
        CHECK (status IN ('Completed','Cancelled','Ongoing'))
);

-- Payments (one payment per ride)
CREATE TABLE payments (
    payment_id   SERIAL PRIMARY KEY,
    ride_id      INT          REFERENCES rides(ride_id),     -- FK
    method       VARCHAR(20)  NOT NULL,  -- Cash, eSewa, Khalti, Bank
    amount_nrs   NUMERIC(8,2) NOT NULL,
    paid_at      TIMESTAMP    NOT NULL,
    status       VARCHAR(20)  DEFAULT 'Success'
        CHECK (status IN ('Success','Failed','Pending'))
);

-- Promotions / discount codes
CREATE TABLE promotions (
    promo_id     SERIAL PRIMARY KEY,
    code         VARCHAR(20)  UNIQUE NOT NULL,
    discount_pct INT          NOT NULL,  -- e.g. 20 means 20%
    valid_from   DATE         NOT NULL,
    valid_to     DATE         NOT NULL,
    is_active    BOOLEAN      DEFAULT TRUE
);

-- Many-to-Many: rides ↔ promotions (junction table)
CREATE TABLE ride_promotions (
    rp_id        SERIAL PRIMARY KEY,
    ride_id      INT          REFERENCES rides(ride_id),
    promo_id     INT          REFERENCES promotions(promo_id),
    applied_at   TIMESTAMP    DEFAULT NOW()
);


-- ── SEED DATA ────────────────────────────────────────────────

-- Zones
INSERT INTO zones (zone_name, district, is_active) VALUES
('Kathmandu Ring Road',  'Kathmandu',  TRUE),
('Lalitpur / Patan',     'Lalitpur',   TRUE),
('Bhaktapur',            'Bhaktapur',  TRUE),
('Pokhara Lakeside',     'Kaski',      TRUE),
('Pokhara New Road',     'Kaski',      TRUE),
('Chitwan / Bharatpur',  'Chitwan',    FALSE);  -- not yet active

-- Riders
INSERT INTO riders (full_name, phone, email, city, joined_date, is_active) VALUES
('Ram Sharma',         '9801111111', 'ram@gmail.com',     'Kathmandu', '2022-03-10', TRUE),
('Sita Thapa',         '9802222222', 'sita@yahoo.com',    'Lalitpur',  '2022-05-18', TRUE),
('Hari Gurung',        '9803333333', NULL,                'Pokhara',   '2022-07-04', TRUE),
('Anita Maharjan',     '9804444444', 'anita@gmail.com',   'Kathmandu', '2022-09-22', TRUE),
('Bikash Rai',         '9805555555', 'bikash@gmail.com',  'Bhaktapur', '2023-01-15', TRUE),
('Sunita Tamang',      '9806666666', NULL,                'Kathmandu', '2023-02-28', TRUE),
('Rohan Shrestha',     '9807777777', 'rohan@gmail.com',   'Lalitpur',  '2023-04-05', TRUE),
('Priya Basnet',       '9808888888', 'priya@gmail.com',   'Pokhara',   '2023-06-11', FALSE), -- inactive
('Krishna Adhikari',   '9809999999', NULL,                'Kathmandu', '2023-08-20', TRUE),
('Deepa Karki',        '9800000000', 'deepa@gmail.com',   'Chitwan',   '2023-11-01', TRUE);

-- Drivers
INSERT INTO drivers (full_name, phone, zone_id, license_no, rating, joined_date, is_active) VALUES
('Bijay Lama',         '9811000001', 1, 'KA-BA-001',  4.85, '2021-06-01', TRUE),
('Suresh Magar',       '9811000002', 1, 'KA-BA-002',  4.72, '2021-08-15', TRUE),
('Nabin Shrestha',     '9811000003', 2, 'LA-PA-001',  4.90, '2021-09-20', TRUE),
('Dipak Tamang',       '9811000004', 3, 'BH-BA-001',  4.60, '2022-01-10', TRUE),
('Anil Gurung',        '9811000005', 4, 'PO-KA-001',  4.95, '2022-03-05', TRUE),
('Santosh KC',         '9811000006', 4, 'PO-KA-002',  4.40, '2022-07-18', TRUE),
('Ramesh Poudel',      '9811000007', 5, 'PO-KB-001',  4.78, '2022-10-01', TRUE),
('Manish Bhandari',    '9811000008', 1, 'KA-BB-001',  4.55, '2023-01-12', TRUE),
('Prem Thapa',         '9811000009', 2, 'LA-PB-001',  4.88, '2023-03-25', TRUE),
('Gopal Rai',          '9811000010', 1, 'KA-BC-001',  3.95, '2023-06-01', FALSE); -- deactivated

-- Vehicles
INSERT INTO vehicles (driver_id, vehicle_type, plate_no, model, year) VALUES
(1,  'Bike',     'BA 1 KA 1234',  'Honda CB Shine',     2020),
(2,  'Car',      'BA 2 KA 5678',  'Suzuki Alto',         2019),
(3,  'Bike',     'LA 1 PA 2345',  'Yamaha FZS',          2021),
(4,  'Bike',     'BH 1 BA 3456',  'Honda CD 110',        2018),
(5,  'Bike',     'PO 1 KA 4567',  'TVS Apache',          2022),
(6,  'Car',      'PO 2 KA 5679',  'Hyundai Santro',      2020),
(7,  'E-Scooter','PO 1 KB 6789',  'Vmoto Stash',         2023),
(8,  'Bike',     'BA 3 KA 7890',  'Bajaj Pulsar',        2021),
(9,  'Car',      'LA 2 PB 8901',  'Maruti Swift',        2022),
(10, 'Bike',     'BA 4 KA 9012',  'Hero Splendor',       2019);

-- Rides
INSERT INTO rides (rider_id, driver_id, zone_id, pickup, dropoff, ride_date, ride_time, distance_km, fare_nrs, status) VALUES
(1,  1, 1, 'Thamel',         'Koteshwor',      '2024-01-05', '08:30', 6.2,  180.00, 'Completed'),
(2,  3, 2, 'Patan Dhoka',    'Lagankhel',      '2024-01-06', '09:15', 3.5,  110.00, 'Completed'),
(3,  5, 4, 'Lakeside',       'Airport Pokhara','2024-01-07', '11:00', 5.0,  150.00, 'Completed'),
(4,  1, 1, 'Maharajgunj',    'New Baneshwor',  '2024-01-08', '07:45', 4.8,  145.00, 'Completed'),
(5,  4, 3, 'Bhaktapur Durbar','Suryabinayak',  '2024-01-10', '14:00', 3.2,  100.00, 'Completed'),
(6,  2, 1, 'Putalisadak',    'Banasthali',     '2024-01-12', '10:30', 7.0,  210.00, 'Completed'),
(7,  9, 2, 'Kumaripati',     'Sanepa',         '2024-01-14', '16:00', 2.8,   90.00, 'Completed'),
(1,  8, 1, 'Baluwatar',      'Tripureshwor',   '2024-01-15', '08:00', 5.5,  165.00, 'Completed'),
(2,  3, 2, 'Jawalakhel',     'Ekantakuna',     '2024-01-16', '18:30', 4.2,  130.00, 'Completed'),
(3,  6, 4, 'Chipledhunga',   'Prithvi Chowk',  '2024-01-17', '12:00', 3.8,  120.00, 'Cancelled'),
(4,  1, 1, 'Naxal',          'Kalanki',        '2024-02-01', '09:00', 8.5,  255.00, 'Completed'),
(8,  5, 4, 'Lakeside',       'Begnas',         '2024-02-03', '10:00', 12.0, 360.00, 'Completed'),  -- inactive rider still has old data
(9,  2, 1, 'Chabahil',       'Ratnapark',      '2024-02-05', '08:15', 5.0,  150.00, 'Completed'),
(10, 7, 5, 'New Road Pkr',   'Pokhara Bus Park','2024-02-06','13:00', 4.5,  135.00, 'Completed'),
(1,  1, 1, 'Thamel',         'Airport KTM',    '2024-02-10', '05:30', 9.0,  270.00, 'Completed'),
(5,  4, 3, 'Thimi',          'Bhaktapur Core', '2024-02-12', '11:30', 2.5,   80.00, 'Completed'),
(6,  8, 1, 'Lazimpat',       'Maitighar',      '2024-02-15', '09:30', 3.5,  110.00, 'Completed'),
(2,  9, 2, 'Pulchowk',       'Tikabhairab',    '2024-02-18', '17:00', 5.5,  165.00, 'Completed'),
(3,  5, 4, 'Baidam',         'Seti Bridge',    '2024-02-20', '14:30', 6.0,  180.00, 'Completed'),
(7,  3, 2, 'Imadol',         'Nakhu',          '2024-02-22', '08:45', 4.0,  120.00, 'Cancelled'),
(4,  2, 1, 'Durbarmarg',     'Sukedhara',      '2024-03-01', '10:00', 6.5,  195.00, 'Completed'),
(9,  1, 1, 'Budhanilkantha', 'Ratnapark',      '2024-03-05', '07:30', 10.0, 300.00, 'Completed'),
(1,  8, 1, 'Kapan',          'Putalisadak',    '2024-03-08', '09:15', 7.2,  216.00, 'Completed'),
(5,  4, 3, 'Gatthaghar',     'Lokanthali',     '2024-03-10', '16:45', 3.0,   95.00, 'Completed'),
(6,  2, 1, 'Gongabu',        'Kalimati',       '2024-03-12', '08:00', 5.8,  175.00, 'Ongoing');

-- Payments
INSERT INTO payments (ride_id, method, amount_nrs, paid_at, status) VALUES
(1,  'eSewa',   180.00, '2024-01-05 08:55:00', 'Success'),
(2,  'Cash',    110.00, '2024-01-06 09:40:00', 'Success'),
(3,  'Khalti',  150.00, '2024-01-07 11:32:00', 'Success'),
(4,  'Cash',    145.00, '2024-01-08 08:12:00', 'Success'),
(5,  'eSewa',   100.00, '2024-01-10 14:28:00', 'Success'),
(6,  'Bank',    210.00, '2024-01-12 10:58:00', 'Success'),
(7,  'Cash',     90.00, '2024-01-14 16:22:00', 'Success'),
(8,  'eSewa',   165.00, '2024-01-15 08:30:00', 'Success'),
(9,  'Khalti',  130.00, '2024-01-16 18:55:00', 'Success'),
-- ride 10 cancelled — no payment
(11, 'Cash',    255.00, '2024-02-01 09:28:00', 'Success'),
(12, 'Khalti',  360.00, '2024-02-03 10:45:00', 'Success'),
(13, 'eSewa',   150.00, '2024-02-05 08:38:00', 'Success'),
(14, 'Cash',    135.00, '2024-02-06 13:25:00', 'Success'),
(15, 'eSewa',   270.00, '2024-02-10 05:55:00', 'Success'),
(16, 'Cash',     80.00, '2024-02-12 11:52:00', 'Success'),
(17, 'Khalti',  110.00, '2024-02-15 09:55:00', 'Success'),
(18, 'eSewa',   165.00, '2024-02-18 17:28:00', 'Success'),
(19, 'Cash',    180.00, '2024-02-20 14:58:00', 'Success'),
-- ride 20 cancelled — no payment
(21, 'Bank',    195.00, '2024-03-01 10:25:00', 'Success'),
(22, 'eSewa',   300.00, '2024-03-05 07:55:00', 'Success'),
(23, 'Cash',    216.00, '2024-03-08 09:38:00', 'Success'),
(24, 'Khalti',   95.00, '2024-03-10 17:05:00', 'Success');
-- ride 25 ongoing — payment pending

-- Promotions
INSERT INTO promotions (code, discount_pct, valid_from, valid_to, is_active) VALUES
('DASHAIN20',  20, '2024-10-01', '2024-10-20', FALSE),
('NEWUSER15',  15, '2024-01-01', '2024-12-31', TRUE),
('TIHAR10',    10, '2024-11-01', '2024-11-10', FALSE),
('ESEWA5',      5, '2024-01-01', '2024-12-31', TRUE),
('POKHARA25',  25, '2024-02-01', '2024-03-31', TRUE);

-- Ride-Promotions (junction table)
INSERT INTO ride_promotions (ride_id, promo_id) VALUES
(1,  2),   -- Ram used NEWUSER15
(3,  5),   -- Hari used POKHARA25
(6,  4),   -- Sunita used ESEWA5
(12, 5),   -- ride 12 used POKHARA25
(15, 2),   -- Ram used NEWUSER15 again
(19, 5);   -- Hari used POKHARA25