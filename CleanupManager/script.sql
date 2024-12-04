-- Drop the database if it exists
DROP DATABASE IF EXISTS TestCleanupDb;

-- Create the test database
CREATE DATABASE IF NOT EXISTS TestCleanupDb;

-- Switch to the test database
USE TestCleanupDb;

-- Enable file-per-table (optional, ensures each table has its own file)
SET GLOBAL innodb_file_per_table = 1;

-- Drop the `orders` table if it exists
DROP TABLE IF EXISTS orders;

-- Create the `orders` table without partitioning
CREATE TABLE orders (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    created_at DATETIME NOT NULL,
    customer_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL
);

-- Insert a large amount of fake data into `orders`
-- This generates approximately 10 million rows
INSERT INTO orders (created_at, customer_id, amount)
SELECT
    DATE_ADD('2015-01-01', INTERVAL FLOOR(RAND() * 3650) DAY), -- Random date within ~10 years
    FLOOR(RAND() * 1000000) + 1,                              -- Random customer_id
    ROUND(RAND() * 500, 2)                                   -- Random amount
FROM
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t1,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t2,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t3,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t4,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t5;

-- Drop the `customers` table if it exists
DROP TABLE IF EXISTS customers;

-- Create the `customers` table without partitioning
CREATE TABLE customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    last_login DATETIME NOT NULL
);

-- Insert a large amount of fake data into `customers`
-- This generates approximately 1 million rows
INSERT INTO customers (name, email, last_login)
SELECT
    CONCAT('Customer ', FLOOR(RAND() * 1000000) + 1),
    CONCAT('customer', FLOOR(RAND() * 1000000) + 1, '@example.com'),
    DATE_ADD('2015-01-01', INTERVAL FLOOR(RAND() * 3650) DAY) -- Random date within ~10 years
FROM
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t1,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t2,
    (SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) t3;

-- View total rows in each table
SELECT 'orders' AS TableName, COUNT(*) AS TotalRows FROM orders
UNION ALL
SELECT 'customers', COUNT(*) FROM customers;
