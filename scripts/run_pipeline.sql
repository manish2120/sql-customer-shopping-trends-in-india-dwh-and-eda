/*
===============================================================================
Master ETL Orchestration Script: Run Full Data Warehouse Pipeline
===============================================================================
Script Purpose:
    This script orchestrates the end-to-end execution of the ETL pipeline for the 
    Indian Customer Shopping Trends Data Warehouse ("IndianCustomerShoppingTrendsDW").

Pipeline Flow:
    1. Bronze Layer  : Ingests raw source data from CSV files into Bronze staging tables.
    2. Silver Layer  : Cleanses, standardizes, and enriches data from Bronze to Silver.
    3. Gold Layer    : For Analytics and Reporting Purposes.

Usage:
    EXECUTE this script in SSMS to refresh the entire Data Warehouse end-to-end.
===============================================================================
*/

USE IndianCustomerShoppingTrendsDW;
GO

DECLARE @pipeline_start_time DATETIME, @pipeline_end_time DATETIME;
SET @pipeline_start_time = GETDATE();

PRINT '===============================================================================';
PRINT '  STARTING DATA WAREHOUSE ETL PIPELINE: IndianCustomerShoppingTrendsDW';
PRINT '  Execution Start Time: ' + CAST(@pipeline_start_time AS NVARCHAR);
PRINT '===============================================================================';

BEGIN TRY

    ---------------------------------------------------------------------------
    -- Step 1: Execute Bronze Layer Loading
    ---------------------------------------------------------------------------
    PRINT '';
    PRINT '---------------------------------------------------------------------------';
    PRINT '>>> Step 1/2: Loading Bronze Layer (Raw Staging)...';
    PRINT '---------------------------------------------------------------------------';
    EXEC bronze.load_bronze;

    ---------------------------------------------------------------------------
    -- Step 2: Execute Silver Layer Loading
    ---------------------------------------------------------------------------
    PRINT '';
    PRINT '---------------------------------------------------------------------------';
    PRINT '>>> Step 2/2: Loading Silver Layer (Cleaned & Standardized)...';
    PRINT '---------------------------------------------------------------------------';
    EXEC silver.load_silver;

    SET @pipeline_end_time = GETDATE();

    PRINT '';
    PRINT '===============================================================================';
    PRINT '  ETL PIPELINE COMPLETED SUCCESSFULLY!';
    PRINT '  Total Pipeline Execution Duration: ' + CAST(DATEDIFF(second, @pipeline_start_time, @pipeline_end_time) AS NVARCHAR) + ' seconds.';
    PRINT '  Completion Time: ' + CAST(@pipeline_end_time AS NVARCHAR);
    PRINT '===============================================================================';

END TRY
BEGIN CATCH
    PRINT '';
    PRINT '===============================================================================';
    PRINT '  ERROR OCCURRED DURING ETL PIPELINE EXECUTION';
    PRINT '  Error Message : ' + ERROR_MESSAGE();
    PRINT '  Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT '  Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
    PRINT '===============================================================================';
END CATCH;
GO
