{{ config(
    materialized='table',
    schema='marts'
) }}

WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

performance AS (
    SELECT * FROM {{ ref('int_product_performance') }}
)

SELECT
    p.product_id,
    p.product_name,
    p.product_number,
    p.color,
    p.list_price,
    COALESCE(pf.times_ordered, 0) as times_ordered,
    COALESCE(pf.total_quantity_sold, 0) as total_quantity_sold,
    COALESCE(pf.total_revenue, 0) as total_revenue,
    COALESCE(pf.avg_selling_price, 0) as avg_selling_price,
    CASE
        WHEN pf.total_revenue >= 100000 THEN 'Top Seller'
        WHEN pf.total_revenue >= 50000 THEN 'Good Seller'
        WHEN pf.total_revenue > 0 THEN 'Low Seller'
        ELSE 'No Sales'
    END as product_performance
FROM products p
LEFT JOIN performance pf ON p.product_id = pf.product_id