-- ============================
-- 4. DIMENSION: dim_product
-- ============================
{{ config(
    materialized = 'table',
    alias = 'dim_product',
    tags = ['dim']
) }}

SELECT DISTINCT
  md5(product_id) AS product_fk,
  product_id
FROM {{ ref('incremental_src_sales') }}