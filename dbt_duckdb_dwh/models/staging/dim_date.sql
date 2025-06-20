-- ============================
-- 4. DIMENSION: dim_date
-- ============================

{{ config(
    materialized = 'table',
    alias = 'date',
    tags = ['dim']
) }}

SELECT DISTINCT
    *
FROM {{ source('src', 'date') }}