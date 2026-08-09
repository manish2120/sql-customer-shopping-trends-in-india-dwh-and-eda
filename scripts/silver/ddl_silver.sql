/* 
--------------------------------------
DDL Script: Create Silver Table
--------------------------------------
Script Purpose : 
    This script creates a table in the 'silver' schema dropping the existing table if it exist.

Warning:
    1. This script drops the entire existing table and re-creates the new empty table.
    2. Ensure to take a proper backup before executing this script.
    3. Run this script only to re-define the DDL structure of 'silver' layer tables.
-----------------------------------------*/
IF OBJECT_ID('silver.csti_customer_shopping_behavior', 'U') IS NOT NULL
    DROP TABLE silver.csti_customer_shopping_behavior
GO

CREATE TABLE silver.csti_customer_shopping_behavior (
    transaction_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL,
    purchase_date DATE,
    age INT,
    gender NVARCHAR(20),
    location NVARCHAR(50),
    online_offline NVARCHAR(20),
    online_store NVARCHAR(50),
    category NVARCHAR(50),
    item_purchased NVARCHAR(50),
    brand NVARCHAR(50),
    color NVARCHAR(20),
    size NVARCHAR(20),
    quantity INT,
    purchase_amount_inr DECIMAL(18, 2),
    discount_percent DECIMAL(5, 2),
    festival_sale NVARCHAR(100),
    shipping_charge_inr DECIMAL(18, 2),
    delivery_speed NVARCHAR(20),
    delivery_time_in_days INT,
    subscription_status NVARCHAR(10),
    payment_method NVARCHAR(30),
    review_rating INT,
    return_status NVARCHAR(20),
    previous_purchases INT,
    frequency_of_purchases NVARCHAR(20),
    dwh_create_date DATETIME DEFAULT GETDATE()
);
GO