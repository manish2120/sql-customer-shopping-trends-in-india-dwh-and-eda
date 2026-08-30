/*
---------------------------------------------
AUDIT LAYER : ETL Log
---------------------------------------------
  Script Purpose : 
    This script creates a table to store ETL log.

  Warning:
    1. This script truncates the entire existing data from audit log table.
    2. Ensure to take a proper backup before executing this script.

  Parameter : None
    This table does not accept any parameters or return any values.
*/

USE IndianCustomerShoppingTrendsDW;
GO

-- Create Audit Schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'audit')
BEGIN 
    EXEC('CREATE SCHEMA [audit]');
END
GO

-- Drop table if exists
IF OBJECT_ID('audit.etl_log', 'U') IS NOT NULL
    DROP TABLE audit.etl_log;
GO

-- Create table
CREATE TABLE audit.etl_log (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    batch_id UNIQUEIDENTIFIER DEFAULT NEWID(),
    process_name NVARCHAR(100) NOT NULL,
    schema_name NVARCHAR(100) NOT NULL,
    table_name NVARCHAR(100) NOT NULL,
    processed_records INT NULL,
    status NVARCHAR(20) NOT NULL, -- 'SUCCESS', 'FAILED'
    error_message NVARCHAR(MAX) NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    duration_seconds INT NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE()
);
GO