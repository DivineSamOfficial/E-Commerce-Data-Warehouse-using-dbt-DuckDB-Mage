{{ config(
    materialized = 'view', 
    tags = ['mart', 'paymet_analysis'],
    alias = 'mart_payment_analysis',
    description = 'Monitor how payment types and loyalty cards are used.'
) }}

SELECT
  pm.payment,
  pm.loyalty_card,
  COUNT(f.transaction_id) AS transaction_count,
  SUM(f.total_price) AS total_spent
FROM {{ ref('fct_sales_transaction') }} f
JOIN {{ ref('dim_payments') }} pm
  ON f.payment_fk = pm.payment_fk
GROUP BY pm.payment, pm.loyalty_card
ORDER BY total_spent DESC



