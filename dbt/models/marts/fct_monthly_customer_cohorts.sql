with orders as (
    select
        sales_order_id,
        customer_id,
        order_date,
        datefromparts(year(order_date), month(order_date), 1) as order_month,
        total_due_amount
    from {{ ref('stg_sales_order_headers') }}
    where order_status != 'Cancelled'
),
cohorts as (
    select * from {{ ref('int_customer_orders_aggregated') }}
),
classified_orders as (
    select
        o.sales_order_id,
        o.customer_id,
        o.order_month,
        o.total_due_amount,
        c.first_order_month,
        case
            when o.order_month = c.first_order_month then 'New'
            else 'Returning'
        end as customer_lifecycle_stage
    from orders o
    inner join cohorts c on o.customer_id = c.customer_id
),
monthly_cohort_summary as (
    select
        order_month,
        count(distinct customer_id) as total_active_customers,
        count(distinct case when customer_lifecycle_stage = 'New' then customer_id end) as new_customers_acquired,
        count(distinct case when customer_lifecycle_stage = 'Returning' then customer_id end) as repeat_customers_active,
        sum(total_due_amount) as total_order_revenue,
        sum(case when customer_lifecycle_stage = 'New' then total_due_amount else 0 end) as new_customer_revenue,
        sum(case when customer_lifecycle_stage = 'Returning' then total_due_amount else 0 end) as repeat_customer_revenue,
        -- Retention Rate % (Repeat Customers / Total Customers)
        case 
            when count(distinct customer_id) > 0
            then cast((count(distinct case when customer_lifecycle_stage = 'Returning' then customer_id end) * 100.0 / count(distinct customer_id)) as decimal(10, 2))
            else 0
        end as retention_rate_pct
    from classified_orders
    group by order_month
)
select * from monthly_cohort_summary