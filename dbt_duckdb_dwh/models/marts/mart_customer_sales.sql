{{ config(
    materialized = 'view',  
    tags = ['mart', 'customer_sales'],
    alias = 'mart_customer_sales',
    description = 'Understand how much each customer is purchasing.'
) }}

SELECT
  f.customer_id,
  COUNT(f.transaction_id) AS total_transactions,
  SUM(f.total_price) AS total_spent,
  SUM(f.total_cost) AS total_cost,
  SUM(f.profit) AS total_profit
FROM {{ ref('fct_sales_transaction') }} f
GROUP BY f.customer_id

