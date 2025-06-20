{{ config(
    materialized = 'view', 
    tags = ['mart', 'customer_sales'],
    alias = 'mart_product_performance',
    description = 'Identify top-performing products.'
) }}

SELECT
  p.product_id,
  SUM(f.quantity) AS units_sold,
  SUM(f.total_price) AS total_sales,
  SUM(f.total_cost) AS total_cost,
  SUM(f.profit) AS total_profit
FROM {{ ref('fct_sales_transaction') }} f
JOIN {{ ref('dim_product') }} p
  ON f.product_fk = p.product_fk
GROUP BY p.product_id
ORDER BY total_sales DESC
