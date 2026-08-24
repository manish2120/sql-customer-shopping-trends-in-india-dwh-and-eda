--------------------------------------------------------
-- RANKING ANALYSIS
/*
  Purpose: Analyze the ranking of the transactions.

  Measures: 
    - Total Subscribed Customers
    - Total Sales
    - Total Returned Products

  Dimensions: 
    - Location
    - Brand
    - Festival Sale
    - Item Purchased
*/
--------------------------------------------------------

-- Top 5 locations were most subscribed customers exist
SELECT TOP 5
	location,
	SUM(CASE subscription_status WHEN 'Yes' THEN 1 ELSE 0 END) AS total_subscribed_customers
FROM gold.dim_customers
GROUP BY location
ORDER BY total_subscribed_customers DESC;

-- Top 5 brand products sale
SELECT TOP 5
	p.brand,
	SUM(t.purchase_amount_inr) AS total_sales
FROM gold.dim_products p
LEFT JOIN gold.fact_transactions t
ON t.product_key = p.product_key
GROUP BY p.brand
ORDER BY total_sales DESC;

-- Top 3 festival sales
SELECT TOP 3
	festival_sale,
	SUM(purchase_amount_inr) AS total_sales
FROM gold.fact_transactions
GROUP BY festival_sale
ORDER BY total_sales DESC;

-- Bottom 3 festival sales
SELECT TOP 3
	festival_sale,
	SUM(purchase_amount_inr) AS total_sales
FROM gold.fact_transactions
GROUP BY festival_sale
ORDER BY total_sales ASC;

-- Top 5 returned products
SELECT TOP 5
	p.item_purchased,
	SUM(CASE t.return_status WHEN 'Returned' THEN 1 ELSE 0 END) AS total_returned_products
FROM gold.dim_products p
LEFT JOIN gold.fact_transactions t
ON t.product_key = p.product_key
GROUP BY p.item_purchased
ORDER BY total_returned_products DESC;
