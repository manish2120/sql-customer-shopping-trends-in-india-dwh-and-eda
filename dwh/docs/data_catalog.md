# Data Catalog For Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of dimension tables, fact tables and aggregated tables for specific business metrics.

## 1. dim_customers
- Purpose: Provides detailed information about each customer.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_key | BIGINT | Surrogate Key |
| customer_id | NVARCHAR(50) NOT | Unique Identifier for Customer |
| age | INT | Age of Customer |
| gender | NVARCHAR(20) | Gender of Customer |
| location | NVARCHAR(50) | Location of Customer |
| subscription_status | NVARCHAR(10) | Subscription Status of Customer |

## 2. dim_products
- Purpose: Provides detailed information about the products which are purchased by the customers.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| product_key | BIGINT | Surrogate Key |
| category | NVARCHAR(50) | Category of Product |
| item_purchased | NVARCHAR(100) | Item Purchased |
| brand | NVARCHAR(50) | Brand of Product |
| color | NVARCHAR(20) | Color of Product |
| size | NVARCHAR(20) | Size of Product |

## 3. fact_transactions
- Purpose: Provides detailed information about the purchased products transactions by the customers.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| transaction_key | BIGINT | Surrogate Key |
| transaction_id | NVARCHAR(50) NOT | Unique Identifier for Transaction |
| customer_key | BIGINT | Foreign Key to dim_customers |
| product_key | BIGINT | Foreign Key to dim_products |
| online_offline | NVARCHAR(20) | Online/Offline |
| online_store | NVARCHAR(50) | Online Store |
| quantity | INT | Quantity |
| festival_sale | NVARCHAR(50) | Festival Sale |
| discount_percent | DECIMAL(5, 2) | Discount Percent |
| purchase_amount_inr | DECIMAL(18, 2) | Purchase Amount in INR |
| payment_method | NVARCHAR(30) | Payment Method |
| delivery_speed | NVARCHAR(20) | Delivery Speed |
| delivery_time_in_days | INT | Delivery Time in Days |
| return_status | NVARCHAR(20) | Return Status |
| previous_purchases | INT | Previous Purchases |
| frequency_of_purchases | NVARCHAR(20) | Frequency of Purchases |
| review_rating | INT | Review Rating |

## 4. agg_customer_summary
- Purpose: Provides aggregated summary information about the customers based on their purchasing behavior.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| customer_key | BIGINT | Surrogate Key |
| customer_id | NVARCHAR(50) | Unique Identifier for Customer |
| total_transactions | INT | Total Transactions |
| online_shopping_rate | NVARCHAR(42) | Online Shopping Rate |
| offline_shopping_rate | NVARCHAR(42) | Offline Shopping Rate |

## 5. agg_customer_shopping_platform
- Purpose: Provides aggregated summary information about the customers based on their payment method.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| payment_method | NVARCHAR(30) | Payment Method |
| total_transactions | INT | Total Transactions |
| online_shopping_rate | NVARCHAR(42) | Online Shopping Rate |
| offline_shopping_rate | NVARCHAR(42) | Offline Shopping Rate |

## 6. agg_fulfillment_performance
- Purpose: Provides aggregated summary information about the fulfillment performance based on the delivery speed and there ratings behavior.
- Columns Structure: 

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| delivery_speed | NVARCHAR(20) | Delivery Speed |
| expected_delivery_days | NVARCHAR(20) | Expected Delivery Days |
| avg_delivery_days | DECIMAL(18, 2) | Average Delivery Days |
| avg_rating | DECIMAL(18, 2) | Average Rating |
| returned_rate | NVARCHAR(20) | Returned Rate |
