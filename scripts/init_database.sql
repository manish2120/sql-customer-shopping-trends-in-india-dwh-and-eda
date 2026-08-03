/* -------------------------------
Script Purpose :
	1. This script creates a new database named "CustomerShoppingTrendsDW" after checking if it already exists or not.
	2. If it does exists, the script will immediately drops the existing database and recreates it.
	3. Additionally, script sets up three schemas within the database: 'bronze', 'silver' and 'gold'.

Warning :
	1. This script will drop the entire database named "CustomerShoppingTrendsDW" with the uncommited changes if the database exists.
	2. All data inside the database will be permanently deleted.
	3. Please ensure that you have a proper backup before running this script.
---------------------------------- */

-- Use the master
USE master;
GO

-- Drop and recreate the 'CustomerShoppingTrendsDW' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CustomerShoppingTrendsDW')
BEGIN
	ALTER DATABASE CustomerShoppingTrendsDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CustomerShoppingTrendsDW;
END;
GO

-- Create the database
CREATE DATABASE CustomerShoppingTrendsDW;
GO

-- Use the CustomerShoppingTrendsDW database
USE CustomerShoppingTrendsDW;
GO

-- Create Schemas : 'bronze', 'silver' and 'gold'
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;