import duckdb

con = duckdb.connect("dev.duckdb")

# Load raw_products
con.execute("""
CREATE OR REPLACE TABLE sources.src_sales AS (
  SELECT * FROM read_csv_auto('/Users/divinesam/Documents/data/dbtt_duckdb_dwh_data/sales.csv', header=TRUE)
);
""")

# Load raw_date
con.execute("""
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
""")

con.close()