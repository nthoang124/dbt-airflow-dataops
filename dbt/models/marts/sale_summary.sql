{{ config(
    materialized='table',
    schema='marts'
) }}

WITH daily_sales AS (
    SELECT
        CAST(order_date AS DATE) AS order_date,
        SUM(total_amount) AS daily_revenue,
        COUNT(DISTINCT order_id) AS daily_orders
    FROM {{ ref('stg_orders') }}
    GROUP BY CAST(order_date AS DATE)
),

sales_with_running_total AS (
    SELECT
        order_date,
        daily_revenue,
        daily_orders,
        SUM(daily_revenue) OVER (
            ORDER BY order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total_revenue
    FROM daily_sales
),

final AS (
    SELECT
        curr.order_date,
        curr.daily_revenue,
        curr.daily_orders,
        curr.running_total_revenue,
        CASE
            WHEN prev.daily_revenue IS NULL OR prev.daily_revenue = 0 THEN NULL
            ELSE ROUND(((curr.daily_revenue - prev.daily_revenue) * 100.0) / prev.daily_revenue, 2)
        END AS yoy_growth_pct
    FROM sales_with_running_total curr
    LEFT JOIN daily_sales prev
        ON prev.order_date = DATEADD(year, -1, curr.order_date)
)

SELECT
    order_date,
    daily_revenue,
    daily_orders,
    running_total_revenue,
    yoy_growth_pct
FROM final
