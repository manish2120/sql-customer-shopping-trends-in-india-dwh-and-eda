/* -----------------------------------------
  Stored Procedure Name : bronze.load_bronze

  Script Purpose :
    1. This script creates or alters a stored procedure 'bronze.load_bronze' if it exists which loads data from the CSV file 'customer_shopping_behavior_renamed_columns.csv' into the 'bronze.csti_customer_shopping_behavior' table.

  Parameters : This script doesn't accept any parameters.

  Usage : EXEC bronze.load_bronze; -- Use to execute the stored procedure.
--------------------------------------------*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 

BEGIN
	PRINT '================================';
	PRINT '>> Load Bronze Layer: bronze.csti_customer_shopping_behavior';
	PRINT '================================';

	DECLARE 
		@start_time DATETIME, 
		@end_time DATETIME,
		@rows_inserted INT,
		@status NVARCHAR(20),
		@duration_seconds INT,
		@error_message NVARCHAR(MAX);

	BEGIN TRY

	PRINT '================================';
	PRINT '>> Truncating Table: bronze.csti_customer_shopping_behavior';
	PRINT '================================';

	SET @start_time = GETDATE();

	TRUNCATE TABLE bronze.csti_customer_shopping_behavior;

	PRINT '================================';
	PRINT '>> Inserting Data into the Bronze Layer: bronze.csti_customer_shopping_behavior';
	PRINT '================================';

		BULK INSERT bronze.csti_customer_shopping_behavior
		FROM 'C:\SQL CSTI\customer_shopping_behavior_renamed_columns.csv' -- Provide the path to the CSV file as per location of the file.
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			FORMAT = 'CSV', 
			MAXERRORS = 10,
			ERRORFILE = 'C:\SQL CSTI\csv_error_log.txt'
		);

	SET @rows_inserted = @@ROWCOUNT;
	SET @end_time = GETDATE();
	SET @status = 'Success';
	SET @duration_seconds = DATEDIFF(second, @start_time, @end_time);

	PRINT '================================';
	PRINT '>> Bronze Layer Loaded Successfully.';
	PRINT '================================';
	PRINT '================================';
	PRINT '>> Load Duration: ' + CAST(@duration_seconds AS NVARCHAR) + ' seconds.';
	PRINT '================================';

	END TRY

	BEGIN CATCH
		SET @end_time = GETDATE();
		SET @status = 'Failed';
		SET @error_message = ERROR_MESSAGE();

		PRINT '================================';
		PRINT '>> Error occurred during running Bronze Layer.';
		PRINT '>> Error Message' + CAST(ERROR_MESSAGE() AS NVARCHAR);
		PRINT '>> Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT '>> Error State' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '>> Error State' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT '================================';
	END CATCH

	-- Audit Log
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
		'load_bronze', 
		'bronze', 
		'csti_customer_shopping_behavior', 
		@rows_inserted, 
		@start_time,
		@end_time, 
		@duration_seconds,
		@status, 
		@error_message
	);
END