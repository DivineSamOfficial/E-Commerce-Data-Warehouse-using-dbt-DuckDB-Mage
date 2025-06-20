{{ config(
    materialized = 'incremental',
    unique_key = 'transaction_id',  
    tags = ['source', 'incremental', 'sales'],
    alias = 'incremental_src_sales',
    description = 'Incremental sales source data'
) }}

WITH source_data AS (
    SELECT
        *
    FROM 
        {{ source('src', 'sales') }}
    
    {% if is_incremental() %}
    WHERE transactional_date > (SELECT MAX(transactional_date) FROM {{ this }})
    {% endif %}
)

SELECT
    *
FROM 
    source_data