/*
----------------------------------------
QUALITY CHECKS - GOLD LAYER
----------------------------------------
Script Purpose : 
This script is used to perform various quality checks for the data integrity, consistency and accuracy in the gold layer.
It includes checks for :
    - Uniqueness of Surrogate Keys.
    - Data Model Connectivity for Analytical Purposes.

Usage :
    - Run all the queries one by one.
    - Check the results.
    - If all queries returns results as per the expectations, then the data is clean.
    - If any query doesn't returns results as per the expectations, then there is an issue with the data.
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers.
-- Expectation: No results 
SELECT
	customer_key,
	COUNT(*) AS duplicate_customers
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products.
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_transactions'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions.
-- Expectation: No results 
SELECT * 
FROM gold.fact_transactions f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  

