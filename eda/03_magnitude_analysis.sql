--------------------------------------------------------
-- MAGNITUDE ANALYSIS
/*
  Purpose: Analyze the magnitude of the transactions by comparing measure by dimension.

  Measures: 
    - Total Number of Customers
    - Total Number of Transactions
    - Total Number of Products Sold
    - Average Cost in Each Category
    - Total Number of Transaction By Payment Methods
    - Total Number of Transactions By Customers

  Dimensions: 
    - Location
    - Category
    - Payment Method
    - Customer
*/
--------------------------------------------------------

-- Total Number of Customers By Location
SELECT
	location,
	COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY location
ORDER BY location ASC;

-- Total Number of Transactions By Location
SELECT
	c.location,
	COUNT(transaction_id) AS total_transactions
FROM gold.dim_customers c
LEFT JOIN gold.fact_transactions t
ON c.customer_id = t.customer_id
GROUP BY c.location
ORDER BY c.location ASC;

-- Total Number of Products Sold By Category
SELECT
	p.category,
	COUNT(t.product_key) AS total_products
FROM gold.dim_products p
LEFT JOIN gold.fact_transactions t
ON p.product_key = t.product_key
GROUP BY p.category
ORDER BY p.category ASC;

-- What is the Average Cost In Each Category
SELECT
	p.category,
	COUNT(t.product_key) AS total_products,
	TRY_CAST(AVG(t.purchase_amount_inr) AS DECIMAL(18, 2)) AS avg_cost
FROM gold.dim_products p
LEFT JOIN gold.fact_transactions t
ON p.product_key = t.product_key
GROUP BY p.category
ORDER BY p.category ASC;

-- Total Number of Transaction By Payment Methods
SELECT
	payment_method,
	COUNT(transaction_id) AS total_transactions
FROM gold.fact_transactions
GROUP BY payment_method
ORDER BY payment_method ASC;

-- Total Number of Transactions By Customers
SELECT
	c.customer_id,
	COUNT(transaction_id) AS total_transactions
FROM gold.dim_customers c
LEFT JOIN gold.fact_transactions t
ON c.customer_id = t.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id ASC;

