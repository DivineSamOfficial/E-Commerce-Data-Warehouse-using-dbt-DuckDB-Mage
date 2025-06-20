-- ============================
-- 4. DIMENSION: dim_payment
-- ============================

{{ config(
    materialized = 'table',
    alias = 'dim_payment',
    tags = ['dim']
) }}

SELECT DISTINCT
  md5(COALESCE(payment, 'cash') || loyalty_card) AS payment_fk,
  COALESCE(payment, 'cash') AS payment,
  loyalty_card
FROM {{ ref('incremental_src_sales') }}
