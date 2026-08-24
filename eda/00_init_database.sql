/* -------------------------------
Script Purpose :
	1. This script creates a new database named "IndianCustomerShoppingTrendsDWAnalytics" after checking if it already exists or not.
	2. If it does exists, the script will immediately drops the existing database and recreates it.
	3. Additionally, script sets up three schemas within the database: 'bronze', 'silver' and 'gold'.

Warning :
	1. This script will drop the entire database named "IndianCustomerShoppingTrendsDWAnalytics" with the uncommited changes if the database exists.
	2. All data inside the database will be permanently deleted.
	3. Please ensure that you have a proper backup before running this script.
---------------------------------- */

-- Use the master
USE master;
GO

-- Drop and recreate the 'IndianCustomerShoppingTrendsDWAnalytics' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'IndianCustomerShoppingTrendsDWAnalytics')
BEGIN
	ALTER DATABASE IndianCustomerShoppingTrendsDWAnalytics SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE IndianCustomerShoppingTrendsDWAnalytics;
END;
GO

-- Create the database
CREATE DATABASE IndianCustomerShoppingTrendsDWAnalytics;
GO

-- Use the IndianCustomerShoppingTrendsDWAnalytics database
USE IndianCustomerShoppingTrendsDWAnalytics;
GO

-- Create Schemas : 'gold'
CREATE SCHEMA gold;
GO

-- Create Customer Dimension Table
CREATE TABLE gold.dim_customers (
    customer_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    age INT,
    gender NVARCHAR(10),
    location NVARCHAR(50),
    subscription_status NVARCHAR(10)
);
GO

-- Create Product Dimension Table
CREATE TABLE gold.dim_products (
    product_key NVARCHAR(64) NOT NULL PRIMARY KEY,
    category NVARCHAR(50),
    item_purchased NVARCHAR(50),
    brand NVARCHAR(50),
    color NVARCHAR(50),
    size NVARCHAR(20)
);
GO

-- Create Transaction Fact Table
CREATE TABLE gold.fact_transactions (
    transaction_id NVARCHAR(50) NOT NULL PRIMARY KEY,
    customer_id NVARCHAR(50) NOT NULL,
    product_key NVARCHAR(64) NOT NULL,
    purchase_date DATE,
    online_offline NVARCHAR(20),
    online_store NVARCHAR(50),
    quantity INT,
    festival_sale NVARCHAR(50),
    discount_percent DECIMAL(18, 2),
    purchase_amount_inr DECIMAL(18, 2),
    payment_method NVARCHAR(50),
    delivery_speed NVARCHAR(20),
    delivery_time_in_days INT,
    return_status NVARCHAR(20),
    previous_purchases INT,
    frequency_of_purchases NVARCHAR(30),
    review_rating INT
);
GO

-- Insert Data into Customer Dimension Table
BULK INSERT gold.dim_customers
FROM 'C:\SQL CSTI\sql-data-analytics\gold.dim_customers.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

-- Insert Data into Product Dimension Table
BULK INSERT gold.dim_products
FROM 'C:\SQL CSTI\sql-data-analytics\gold.dim_products.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO

-- Insert Data into Transaction Fact Table
BULK INSERT gold.fact_transactions
FROM 'C:\SQL CSTI\sql-data-analytics\gold.fact_transactions.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO