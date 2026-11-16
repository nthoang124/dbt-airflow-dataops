with headers as (
    select * from {{ ref('stg_sales_order_headers') }}
    where order_status != 'Cancelled'
),
customer_history as (
    select
        customer_id,
        min(order_date) as first_order_date,
        datefromparts(year(min(order_date)), month(min(order_date)), 1) as first_order_month,
        max(order_date) as last_order_date,
        count(distinct sales_order_id) as lifetime_order_count,
        sum(total_due_amount) as lifetime_spend
    from headers
    group by customer_id
)
select * from customer_history
