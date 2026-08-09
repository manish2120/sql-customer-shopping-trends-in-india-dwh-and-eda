-- Check For NULL and Empty Values in Size and Delivery Speed
-- Expectation : 0
SELECT 
    COUNT(CASE WHEN size IS NULL OR TRIM(size) = '' THEN 1 END) AS missing_size,
    COUNT(CASE WHEN delivery_speed IS NULL OR TRIM(delivery_speed) = '' THEN 1 END) AS missing_delivery_speed
FROM silver.csti_customer_shopping_behavior;

-- Check Delivery Speed / Time (Delivery Speed / Time Should be Same Day = 0, Express = 1, 2 and Standard = Greater than 2)
-- Expectation : No Result
SELECT 
    transaction_id,
    delivery_speed, 
    delivery_time_in_days
FROM silver.csti_customer_shopping_behavior
WHERE (delivery_speed = 'Same Day'  AND TRY_CAST(delivery_time_in_days AS INT) != 0)
   OR (delivery_speed = 'Express'   AND TRY_CAST(delivery_time_in_days AS INT) NOT BETWEEN 1 AND 2)
   OR (delivery_speed = 'Standard'  AND TRY_CAST(delivery_time_in_days AS INT) <= 2);


-- Check NULL values
-- Expectation : No Result
SELECT 
size
FROM silver.csti_customer_shopping_behavior
WHERE size IS NULL OR size = '';

