----------------------------------------------
-- DATE EXPLORATION
/*
  Purpose: Analyze the date range of transactions, orders and identify the youngest and oldest customers.

  Measures: 
    - First order date
    - Last order date
    - Total orders of each customer
    - Total spendings of each customer
    - Youngest customer age
    - Oldest customer age

  Dimensions: 
    - Customer
*/
----------------------------------------------

-- Find the first and last order date
SELECT
	MIN(purchase_date) AS first_order_date,
	MAX(purchase_date) AS last_order_date,
	DATEDIFF(month, MIN(purchase_date), MAX(purchase_date)) AS order_range_month
FROM gold.fact_transactions;

-- Find the total orders of each customer
SELECT
	customer_id,
	MIN(purchase_date) AS first_order_date,
	MAX(purchase_date) AS last_order_date,
	COUNT(customer_id) AS total_orders,
	SUM(purchase_amount_inr) AS total_spendings
FROM gold.fact_transactions
GROUP BY customer_id
ORDER BY customer_id ASC;

-- Identify the youngest and oldest customers age based on there transactions
WITH customerSummary AS (
SELECT
	t.customer_id AS customer_id,
	c.age AS age,
	MAX(t.purchase_date) AS last_order_date
FROM gold.fact_transactions t
LEFT JOIN gold.dim_customers c
ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.age
), 
rankedCustomers AS (
	SELECT 
		customer_id,
        age,
        last_order_date,
        FIRST_VALUE(customer_id) OVER (ORDER BY age ASC) AS youngest_customer_id,
        FIRST_VALUE(age) OVER (ORDER BY age ASC) AS youngest_age,
        FIRST_VALUE(customer_id) OVER (ORDER BY age DESC) AS oldest_customer_id,
        FIRST_VALUE(age) OVER (ORDER BY age DESC) AS oldest_age
	FROM customerSummary
)
SELECT DISTINCT
    youngest_customer_id,
    youngest_age AS youngest_customer,
    oldest_customer_id,
    oldest_age AS oldest_customer
FROM rankedCustomers;