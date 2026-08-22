/* -----------------------------------------
  Script Purpose :
    1. Pre-processing Context: Some source CSV headers were renamed via a Python with Pandas Library ('file: rename_column.py') to standardized headers (removing spaces/special symbols) into snake_case.
    2. This script creates a table in the 'bronze' schema by dropping the existing 'bronze.csti_customer_shopping_behavior' table.
    3. Create the table 'bronze.csti_customer_shopping_behavior' with the specified columns.

  Note : Run this script to redefine the DDL structure of bronze table.
--------------------------------------------*/

-- Drop the table if it exists
IF OBJECT_ID ('bronze.csti_customer_shopping_behavior', 'U') IS NOT NULL
  DROP TABLE bronze.csti_customer_shopping_behavior;

-- Create the table
CREATE TABLE bronze.csti_customer_shopping_behavior (
  transaction_id           NVARCHAR(MAX),
  customer_id              NVARCHAR(MAX),
  purchase_date            NVARCHAR(MAX),
  age                      NVARCHAR(MAX),
  gender                   NVARCHAR(MAX),
  location                 NVARCHAR(MAX),
  online_offline           NVARCHAR(MAX),
  online_store             NVARCHAR(MAX),
  category                 NVARCHAR(MAX),
  item_purchased           NVARCHAR(MAX),
  brand                    NVARCHAR(MAX),
  color                    NVARCHAR(MAX),
  size                     NVARCHAR(MAX),
  quantity                 NVARCHAR(MAX),
  purchase_amount_inr      NVARCHAR(MAX),
  discount_percent         NVARCHAR(MAX),
  festival_sale            NVARCHAR(MAX),
  shipping_charge_inr      NVARCHAR(MAX),
  delivery_speed           NVARCHAR(MAX),
  delivery_time_in_days    NVARCHAR(MAX),
  subscription_status      NVARCHAR(MAX),
  payment_method           NVARCHAR(MAX),
  review_rating            NVARCHAR(MAX),
  return_status            NVARCHAR(MAX),
  previous_purchases       NVARCHAR(MAX),
  frequency_of_purchases   NVARCHAR(MAX)
);