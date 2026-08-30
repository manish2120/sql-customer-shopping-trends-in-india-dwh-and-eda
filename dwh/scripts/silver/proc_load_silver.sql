/*
---------------------------------------------
Stored Procedure : Load Silver Layer (Bronze -> Silver)
---------------------------------------------
  Script Purpose : 
    This script loads data from Bronze layer to Silver layer.

  Warning:
    1. This script truncates the entire existing data from silver layer table.
    2. Inserts transformed and cleansed data from Bronze to Silver layer.
    3. Ensure to take a proper backup before executing this script.

  Parameter : None
    This stored procedure does not accept any parameters or return any values.

  Usage : 
    EXEC silver.load_silver;
*/

-- Insert Data into csti_customer_details
CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
	SET NOCOUNT ON;

	PRINT '================================';
	PRINT '>> Load Silver Layer: silver.csti_customer_shopping_behavior';
	PRINT '================================';

	DECLARE 
		@start_time DATETIME, 
		@end_time DATETIME,
		@rows_inserted INT = 0,
		@status NVARCHAR(20),
		@duration_seconds INT,
		@error_message NVARCHAR(MAX) = NULL;

	SET @start_time = GETDATE();

	BEGIN TRY
		PRINT '>> Truncating Silver Table...';
		TRUNCATE TABLE silver.csti_customer_shopping_behavior;

		PRINT '>> Inserting Cleansed Data into Silver Table...';
		INSERT INTO silver.csti_customer_shopping_behavior (
			transaction_id,
			customer_id,
			purchase_date,
			age,
			gender,
			location,
			online_offline,
			online_store,
			category,
			item_purchased,
			brand,
			color,
			size,
			quantity,
			purchase_amount_inr,
			discount_percent,
			festival_sale,
			shipping_charge_inr,
			delivery_speed,
			delivery_time_in_days,
			subscription_status,
			payment_method,
			review_rating,
			return_status,
			previous_purchases,
			frequency_of_purchases,
			dwh_create_date
		)
		SELECT 
			TRIM(transaction_id) AS transaction_id,
			TRIM(customer_id) AS customer_id,
			TRY_CAST(purchase_date AS DATE) AS purchase_date,
			TRY_CAST(TRIM(age) AS INT) AS age,
			TRIM(gender) AS gender,
			TRIM(location) AS location,
			COALESCE(NULLIF(TRIM(online_offline), ''), 'Unknown/Offline') AS online_offline,
			COALESCE(NULLIF(TRIM(online_store), ''), 'Unknown') AS online_store,
			TRIM(category) AS category,
			TRIM(item_purchased) AS item_purchased,
			TRIM(brand) AS brand,
			TRIM(color) AS color,
			ISNULL(NULLIF(TRIM(size), ''), 'N/A') AS size,
			TRY_CAST(TRIM(quantity) AS INT) AS quantity,
			TRY_CAST(TRIM(purchase_amount_inr) AS DECIMAL(18, 2)) AS purchase_amount_inr,
			discount_percent,
			COALESCE(NULLIF(TRIM(festival_sale), ''), 'Regular Days') AS festival_sale,
			shipping_charge_inr,
			CASE
				WHEN delivery_time_in_days = 0 THEN 'Same Day'
				WHEN delivery_time_in_days BETWEEN 1 AND 2 THEN 'Express'
				WHEN delivery_time_in_days > 2 THEN 'Standard'
				ELSE 'Unknown'
			END AS delivery_speed,
			delivery_time_in_days,
			subscription_status,
			payment_method,
			review_rating,
			return_status,
			previous_purchases,
			frequency_of_purchases,
			@start_time AS dwh_create_date
		FROM bronze.csti_customer_shopping_behavior;

		SET @rows_inserted = @@ROWCOUNT;
		SET @end_time = GETDATE();
		SET @status = 'Success';
		SET @duration_seconds = DATEDIFF(second, @start_time, @end_time);

		PRINT '================================';
		PRINT '>> Silver Layer Loaded Successfully.';
		PRINT '>> Rows Processed: ' + CAST(@rows_inserted AS NVARCHAR(10));
		PRINT '>> Load Duration: ' + CAST(@duration_seconds AS NVARCHAR) + ' seconds.';
		PRINT '================================';
	END TRY

	BEGIN CATCH
		SET @end_time = GETDATE();
		SET @status = 'Failed';
		SET @error_message = ERROR_MESSAGE();
		SET @duration_seconds = DATEDIFF(second, @start_time, @end_time);

		PRINT '================================';
		PRINT '>> Error occurred during running Silver Layer.';
		PRINT '>> Error Message: ' + CAST(ERROR_MESSAGE() AS NVARCHAR(MAX));
		PRINT '================================';
	END CATCH

	-- Audit Logging
	INSERT INTO audit.etl_log (
		process_name, 
		schema_name, 
		table_name, 
		processed_records, 
		start_time,
		end_time,
		duration_seconds,
		status,
		error_message
	)
	VALUES (
		'load_silver', 
		'silver', 
		'csti_customer_shopping_behavior', 
		@rows_inserted, 
		@start_time,
		@end_time, 
		@duration_seconds,
		@status, 
		@error_message
	);
END;