{{ config(
    materialized='table',
    schema='marts'
) }}

WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

metrics AS (
    SELECT * FROM {{ ref('int_customer_metrics') }}
)

SELECT
    c.customer_id,
    c.territory_id,
    m.total_orders,
    m.lifetime_value,
    m.avg_order_value,
    m.first_order_date,
    m.last_order_date,
    m.customer_tenure_days,
    CASE
        WHEN m.lifetime_value >= 10000 THEN 'High Value'
        WHEN m.lifetime_value >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    CASE
        WHEN m.customer_tenure_days >= 365 THEN 'Loyal'
        WHEN m.customer_tenure_days >= 180 THEN 'Regular'
        ELSE 'New'
    END as customer_type
FROM customers c
INNER JOIN metrics m ON c.customer_id = m.customer_id