{{ config(
    materialized='view',
    schema='intermediate'
) }}

WITH order_details AS (
    SELECT
        product_id,
        order_id,
        quantity,
        unit_price,
        line_total
    FROM {{ ref('stg_order_details') }}
)

SELECT
    product_id,
    COUNT(DISTINCT order_id) as times_ordered,
    SUM(quantity) as total_quantity_sold,
    SUM(line_total) as total_revenue,
    AVG(unit_price) as avg_selling_price
FROM order_details
GROUP BY product_id