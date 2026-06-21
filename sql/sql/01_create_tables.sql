CREATE DATABASE IF NOT EXISTS pharma_sc;
USE pharma_sc;
CREATE TABLE IF NOT EXISTS supply_chain (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    product_name      VARCHAR(150),
    category          VARCHAR(100),
    supplier          VARCHAR(100),
    region            VARCHAR(100),
    warehouse         VARCHAR(100),
    order_date        DATE,
    lead_time_days    INT,
    order_quantity    INT,
    stock_on_hand     INT,
    reorder_point     INT,
    avg_daily_demand  DECIMAL(10,2),
    unit_cost         DECIMAL(10,2),
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS pharma_sales (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    sale_date  DATE,
    drug_code  VARCHAR(20),
    units_sold DECIMAL(10,4)
);

SELECT 'Tables created successfully' AS status;

USE pharma_sc;

SELECT COUNT(*) AS total_rows FROM supply_chain;
SELECT COUNT(*) AS total_rows FROM pharma_sales;

-- Preview first 5 rows
SELECT * FROM supply_chain LIMIT 5;
SELECT * FROM pharma_sales LIMIT 5;