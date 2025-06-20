{{ config(
    materialized = 'view',
    tags = ['mart', 'sales_summary'],
    alias = 'mart_sales_summary',
    description ='Track daily sales performance with revenue, cost, and profit'
) }}

SELECT
  d.date AS transaction_date,
  SUM(f.total_price) AS total_revenue,
  SUM(f.total_cost) AS total_cost,
  SUM(f.profit) AS total_profit,
  COUNT(DISTINCT f.transaction_id) AS total_transactions
FROM {{ ref('fct_sales_transaction') }} f
JOIN {{ ref('dim_date') }} d
  ON f.transactional_date_fk = d.date_key
GROUP BY d.date
ORDER BY d.date
