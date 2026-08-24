--------------------------------------------------------
-- MEASURES EXPLORATION
/*
  Purpose: Analyze the measures of the transactions.

  Measures: 
    - Total Sales
    - Total Transactions
    - Total Customers
    - Total Products
    - Total Online Transactions
    - Total Offline Transactions
    - Total Quantity Sold
*/
--------------------------------------------------------
SELECT 
	'Total Sales' AS measure_name, SUM(purchase_amount_inr) AS measure_value
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Transactions', COUNT(DISTINCT transaction_id)
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Customers', COUNT(DISTINCT customer_id)
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Products', COUNT(product_key)
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Online Transactions', SUM(CASE online_offline WHEN 'Online' THEN 1 ELSE 0 END)
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Offline Transactions', SUM(CASE online_offline WHEN 'Offline' THEN 1 ELSE 0 END)
FROM gold.fact_transactions
UNION ALL
SELECT 
	'Total Quantity Sold', SUM(quantity)
FROM gold.fact_transactions;