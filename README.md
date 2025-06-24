# Case Study: E - Commerce (Data Warehousing) - Divine Sam

![Snow_dbt_DWH.jpg](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/Snow_dbt_DWH.jpg)

## TECH STACK:

**Source**: CSV FIles

**Ingestion**: Python ELT Script 

Codebase, version control and workflow: DBT

**Data Warehouse**: DuckDB

**Database** **IDE**: DBeaver

Orchestration: MAGE AI

1. Look at the problem and plan
2. Set up tables & schema
3. Set up sources - dbt 
4. Staging layer - minimal transformations and incremental tables
5. dimension tables - staging layer
6. Fact Tables - staging layer
7. Aggregated Tables - Data Mart layer
8. Orchestration - Apache Airflow

---

## About the Source Data:

### Download sales dataset here:

[sales.csv](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/sales.csv)

### Sales Source Data Description:

### 🔑 Key Columns:

This dataset contains **point-of-sale transaction records**, where each row represents a **single purchase transaction or event**. Key features include:

- `transaction_id`: Unique identifier for each transaction.
- `transactional_date`: Timestamp of when the transaction occurred. will be used as our delta column for our incremental loading strategy
- `product_id`: ID of the purchased product.
- `customer_id`: Identifier for the customer.
- `payment`: Payment method used (e.g., visa).
- `credit_card`: Masked credit card number used for the transaction.
- `loyalty_card`: Indicates if a loyalty card was used (`F` = False).
- `cost`: The internal cost of the items to the business.
- `quantity`: Number of items purchased.
- `price`: Selling price per unit

---

### Script to create date base table:

- Script:
    
    ```sql
    CREATE OR REPLACE TABLE sources.src_date AS (
      SELECT
        CAST(STRFTIME(datum, '%Y%m%d') AS INTEGER) AS date_key,
        datum AS date,
        STRFTIME(datum, '%A') AS weekday,
        CAST(STRFTIME(datum, '%w') AS INTEGER) + 1 AS weekday_num,
        DATE_PART('day', datum) AS day_month,
        CAST(STRFTIME(datum, '%j') AS INTEGER) AS day_of_year,
        CAST(STRFTIME(datum, '%W') AS INTEGER) + 1 AS week_of_year,
        STRFTIME(datum, '%Y-W%W-%w') AS iso_week,
        DATE_PART('month', datum) AS month,
        STRFTIME(datum, '%B') AS month_name,
        STRFTIME(datum, '%b') AS month_name_short,
        DATE_PART('quarter', datum) AS quarter,
        DATE_PART('year', datum) AS year,
        DATE_TRUNC('month', datum) AS first_day_of_month,
        DATE_TRUNC('month', datum) + INTERVAL '1 month' - INTERVAL '1 day' AS last_day_of_month,
        STRFTIME(datum, '%Y-%m') AS mmyyyy,
        CASE
            WHEN STRFTIME(datum, '%w') IN ('0', '6') THEN 'weekend'
            ELSE 'weekday'
        END AS weekend_indr
      FROM (
        SELECT DATE '2010-01-01' + INTERVAL '1 day' * i AS datum
        FROM range(0, 7301) AS r(i)
      ) dq
      ORDER BY date_key
    );
    
    ```
    

This dataset is a **date dimension table** (also called a calendar table), commonly used in data warehouses and analytics to enrich transactional or event data with detailed date-related attributes.

Each row represents **one calendar date**, and the columns provide various breakdowns and categorizations for analytical use:

---

### 🔑 Key Columns:

- `date_key`: An integer-formatted date key (e.g., 20100101) useful for joins.
- `date`: Full timestamp format of the calendar date.
- `weekday`: Name of the day (e.g., Monday).
- `weekday_num`: Numeric day of the week (1=Sunday, 7=Saturday).
- `day_month`, `day_of_year`: Day number in the month and year respectively.
- `week_of_year`, `iso_week`: Week number in standard and ISO format.
- `month`, `month_name`, `month_name_short`: Various representations of the month.
- `quarter`: Fiscal quarter (1–4).
- `year`: 4-digit year value.
- `first_day_of_month`, `last_day_of_month`: Useful for monthly aggregations.
- `mmyyyy`: Month-year in "YYYY-MM" format for time grouping.
- `weekend_indr`: Categorical flag to distinguish between `weekday` and `weekend`.

---

### 🧠 Use Case:

This table is primarily used to **join with transaction or event tables** (like the one you shared earlier) on the `transactional_date` to enable:

- Time-based aggregations (daily, weekly, monthly)
- Period comparisons (e.g., YoY, MoM)
- Filtering by weekend/weekday, month, quarter, etc.
- Enabling custom fiscal calendars or reporting logics

It's a foundational component in any time-series analysis or dashboard reporting.

---

## Designing the Fact:

1. Create Date Key:
    1. Create a surrogate key using the `transactional_date_key` to link to the date base table - FK for Date table
    2. Include product_FK
    3. Payment Dimension
    4. Adding Calculated columns:
        1. Add total_cost
        2. Add total_price
        3. Add profit
        
    
    **FInal Table Structure:**
    
    ![image.png](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/image.png)
    

![image.png](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/image%201.png)

![image.png](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/image%202.png)

![image.png](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/image%203.png)

![image.png](Case%20Study%20E%20-%20Commerce%20(Data%20Warehousing)%20-%20Divin%201efe9cb738c180cd8ab2e5230d10a63a/image%204.png)
