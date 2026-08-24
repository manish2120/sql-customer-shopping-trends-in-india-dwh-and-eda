# 📊 Exploratory Data Analysis (EDA)

This directory contains SQL scripts for **Exploratory Data Analysis (EDA)** on the `gold` layer of the **Indian Customer Shopping Trends Data Warehouse**. 

The goal of this EDA phase is to analyze business performance, understand customer purchasing behavior, compare metrics across dimensions, and uncover actionable business insights.

---

## 📁 Analysis Structure

The EDA workflow are divided into these main four core analytical phases:

```text
eda/
├── 01_date_exploration.sql        # Explore the dates and timespan of the transactions and customer orders.
├── 02_measures_exploration.sql    # Show all the key metrics of the business
├── 03_dimensions_exploration.sql  # Categorical attributes & distributions
├── 04_magnitude_analysis.sql      # Comparative analysis (Measure by Dimension)
└── 05_ranking_analysis.sql        # Top & Bottom performance rankings
```

---

## 🔍 Analytical Phases Breakdown

### Database Exploration
```sql
  USE database_name; -- Replace with the database name

  SELECT 
      TABLE_CATALOG, 
      TABLE_SCHEMA, 
      TABLE_NAME, 
      TABLE_TYPE
  FROM INFORMATION_SCHEMA.TABLES;

  SELECT 
      COLUMN_NAME, 
      DATA_TYPE, 
      IS_NULLABLE, 
      CHARACTER_MAXIMUM_LENGTH
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'dim_customers'; -- Replace with the table name you want to explore
```

### Dimension Exploration
```sql
  USE database_name; -- Replace with the database name

  SELECT DISTINCT
    customer_id,
    age,
    gender,
    location,
    subscription_status
  FROM gold.dim_customers; 

  SELECT DISTINCT
    product_key,
    category,
    item_purchased,
    brand,
    color,
    size
  FROM gold.dim_products;
```

### 1. Date Exploration (`01_date_exploration.sql`)
Explore the dates and timespan of the transactions and customer orders.
* **Key Metrics Evaluated:**
  * **First order date**
  * **Last order date**
  * **Total orders**
  * **Total spendings**
  * **Youngest customer**
  * **Oldest customer**

---

### 2. Measures Exploration (`02_measures_exploration.sql`)
To understand the overall scale of business operations.
* **Key Metrics Evaluated:**
  * **Total Revenue / Sales (`purchase_amount_inr`)**
  * **Total Transactions Count**
  * **Total Unique Customers**
  * **Total Product Keys**
  * **Shopping Preferences:** Total Online vs. Total Offline Transactions
  * **Total Quantity Sold**

---

### 3. Magnitude Analysis (`03_magnitude_analysis.sql`)
Combines **Measures By Dimensions** to analyze how performance scales across different business segments.
  * Total Customers **BY Location**
  * Total Transactions **BY Location**
  * Total Products Sold **BY Category**
  * Average Item Cost **BY Category**
  * Total Transactions **BY Payment Method**
  * Total Transactions **BY Customer ID**

---

### 4. Ranking Analysis (`04_ranking_analysis.sql`)
Identifies top-performing and underperforming segments using SQL ordering and window functions (`TOP N` and `Bottom N` Analysis).
* **Key Rankings:**
  * **Top 5 Locations** by Subscribed Customer Volume
  * **Top 5 Brands** by Total Sales Revenue
  * **Top 3 & Bottom 3 Festival Sales** by Sales Performance
  * **Top 5 Most Returned Products** by Returned Products

---

## 💡 Key Business Questions Answered

* **Revenue & Sales Drivers:** Which product categories and brands generate the highest total revenue?
* **Regional Customer Base:** Which locations has the highest proportion of subscribed customers?
* **Fulfillment & Returns:** Which product items suffer from the highest return rates?
* **Shopping & Payment Preferences:** What do customers prefer to pay (UPI, Credit Card, COD), and what is the distribution between online stores vs. offline shopping?
