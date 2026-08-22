/*
----------------------------------------
DDL Script - GOLD LAYER
----------------------------------------
Script Purpose : 
This script is used to create views for the gold layer.
The Gold Layer represents the final dimension and fact tables (Star Schema)
It includes views for : 
	- dim_customers
	- dim_products
	- fact_transactions
	- agg_customer_summary
	- agg_customer_shopping_platform
	- agg_fulfillment_performance

Usage :
	- These views are queried for analytics and reporting.
*/

-----------------------------------------------------
-- Create Dimension Table : gold.dim_customers
-----------------------------------------------------

-- Drop View gold.dim_customers if it exists
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

-- Create View gold.dim_customers
CREATE VIEW gold.dim_customers AS
SELECT 
	s.customer_id,
	s.age,
	s.gender,
	s.location,
	s.subscription_status
FROM (
	SELECT
		DISTINCT 
		customer_id,
		age,
		gender,
		location,
		subscription_status
	FROM silver.csti_customer_shopping_behavior
) AS s;
GO

-----------------------------------------------------
-- Create Dimension Table : gold.dim_products
-----------------------------------------------------
-- Drop View gold.dim_products if it exists
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

-- Create View gold.dim_products
CREATE VIEW gold.dim_products AS 
SELECT 
	CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CONCAT(category, item_purchased, brand, color, size)), 2) AS product_key, -- Surrogate Key
	category,
	item_purchased,
	brand,
	color,
	size
FROM (
	SELECT
		DISTINCT
		category,
		item_purchased,
		brand,
		color,
		size
	FROM silver.csti_customer_shopping_behavior
) AS distinct_products;
GO

-----------------------------------------------------
-- Create Fact Table : gold.fact_transactions
-----------------------------------------------------
-- Drop View gold.fact_transactions if it exists
IF OBJECT_ID('gold.fact_transactions', 'V') IS NOT NULL
    DROP VIEW gold.fact_transactions;
GO

-- Create View gold.fact_transactions
CREATE VIEW gold.fact_transactions AS
SELECT
	s.transaction_id,	
	c.customer_id,
	p.product_key,
	s.online_offline,
	s.online_store,
	s.quantity,
	s.festival_sale,
	s.discount_percent,
	s.purchase_amount_inr,
	s.payment_method,
	s.delivery_speed,
	s.delivery_time_in_days,
	s.return_status,
	s.previous_purchases,
	s.frequency_of_purchases,
	s.review_rating
FROM silver.csti_customer_shopping_behavior s
LEFT JOIN gold.dim_products p
ON	s.category			 = p.category
    AND s.item_purchased = p.item_purchased
    AND s.brand          = p.brand
    AND s.color          = p.color
    AND s.size           = p.size
LEFT JOIN gold.dim_customers c
ON 	s.customer_id			  		= c.customer_id
	AND s.age				  				= c.age
	AND s.gender			  			= c.gender
	AND s.location			  		= c.location
	AND s.subscription_status = c.subscription_status;
GO

-----------------------------------------------------
-- Create Aggregate Table : gold.agg_customer_summary
-----------------------------------------------------
-- Drop View gold.agg_customer_summary if it exists
IF OBJECT_ID('gold.agg_customer_summary', 'V') IS NOT NULL
	DROP VIEW gold.agg_customer_summary;
GO

-- Create View gold.agg_customer_summary
CREATE VIEW gold.agg_customer_summary AS
SELECT 
  st.customer_id,
  COUNT(st.transaction_id) AS total_transactions,
  
	  TRY_CAST(
		  COUNT(
			  CASE 
				WHEN st.online_offline = 'Online' THEN 1 
			  END
			) * 100.0 / COUNT(*) AS DECIMAL(5, 2)
  ) AS online_shopping_rate,
  
		TRY_CAST(
			COUNT(
				CASE 
					WHEN st.online_offline = 'Offline' THEN 1 
				END
			) * 100.0 / COUNT(*) AS DECIMAL(5, 2)
		) AS offline_shopping_rate
FROM (
	SELECT
		c.customer_id,
		t.transaction_id,
		t.online_offline
	FROM gold.dim_customers c
	LEFT JOIN gold.fact_transactions t
	ON c.customer_id = t.customer_id
) st
GROUP BY st.customer_id;
GO

-----------------------------------------------------
-- Create Aggregate Table : gold.agg_customer_shopping_platform
-----------------------------------------------------
-- Drop View gold.agg_customer_shopping_platform if it exists
IF OBJECT_ID('gold.agg_customer_shopping_platform', 'V') IS NOT NULL
	DROP VIEW gold.agg_customer_shopping_platform;
GO

-- Create View gold.agg_customer_shopping_platform
CREATE VIEW gold.agg_customer_shopping_platform AS
SELECT 
	payment_method,
	COUNT(transaction_id) AS total_transactions,
	TRY_CAST(COUNT(CASE WHEN online_offline = 'Online' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS online_shopping_rate, -- Tells how many percent users did shopping online
	TRY_CAST(COUNT(CASE WHEN online_offline = 'Offline' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS offline_shopping_rate -- Tells how many percent users did shopping offline
FROM gold.fact_transactions
GROUP BY payment_method;
GO

-----------------------------------------------------
-- Create Aggregate Table : gold.agg_fulfillment_performance
-----------------------------------------------------
-- Drop View gold.agg_fulfillment_performance if it exists
IF OBJECT_ID('gold.agg_fulfillment_performance', 'V') IS NOT NULL
	DROP VIEW gold.agg_fulfillment_performance;
GO

-- Create View gold.agg_fulfillment_performance
CREATE VIEW gold.agg_fulfillment_performance AS
SELECT 
  delivery_speed,
  CASE 
	WHEN delivery_speed = 'Same Day' THEN '0'
	WHEN delivery_speed = 'Express' THEN '1 - 2'
	WHEN delivery_speed = 'Standard' THEN 'More than 2'
  END AS expected_delivery_days,
  AVG(delivery_time_in_days) AS avg_delivery_days,
  AVG(review_rating) AS avg_rating,
  TRY_CAST(COUNT(CASE WHEN return_status = 'Returned' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS returned_rate,
  TRY_CAST(COUNT(CASE WHEN return_status = 'Not Returned' THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5, 2)) AS not_returned_rate
FROM gold.fact_transactions
GROUP BY delivery_speed;
GO