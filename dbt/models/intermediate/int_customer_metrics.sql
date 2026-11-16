{{ config(
    materialized='view',
    schema='intermediate'
) }}

WITH customer_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        total_amount
    FROM {{ ref('stg_orders') }}
)

SELECT
    customer_id,
    COUNT(order_id) as total_orders,
    SUM(total_amount) as lifetime_value,
    AVG(total_amount) as avg_order_value,
    MIN(order_date) as first_order_date,
    MAX(order_date) as last_order_date,
    DATEDIFF(day, MIN(order_date), MAX(order_date)) as customer_tenure_days
FROM customer_orders
GROUP BY customer_id