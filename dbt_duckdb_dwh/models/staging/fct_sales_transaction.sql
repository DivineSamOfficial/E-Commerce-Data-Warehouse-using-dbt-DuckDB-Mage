-- ============================
-- 4. FACT: fct_sales_transactions
-- ============================
{{ config(
    materialized = 'table',               
    tags = ['fact','sales_transactions'],     
    alias = 'fct_sales_transaction',             
    description = 'Staged and cleaned category data.'
) }}

WITH src_sales AS(
    
    SELECT * FROM {{ ref('incremental_src_sales') }}
)
SELECT
    transaction_id,
    CAST(STRFTIME(transactional_date, '%Y%m%d') AS INTEGER) AS transactional_date_fk,
    md5(product_id) AS product_fk,
    customer_id,
    md5(COALESCE(payment,'cash') || loyalty_card) AS payment_FK,
    credit_card,
    cost,
    quantity,
    price AS price_per_unit,
    cost * quantity AS total_cost,
    price * quantity AS total_price,
    (price * quantity) - (cost * quantity) AS profit,
    
FROM
    src_sales


