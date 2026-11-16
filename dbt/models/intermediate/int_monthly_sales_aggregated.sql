with item_sales as (
    select * from {{ ref('int_sales_order_items_joined') }}
),
monthly_agg as (
    select
        order_month,
        order_year,
        order_month_num,
        territory_id,
        territory_name,
        territory_group,
        category_name,
        count(distinct sales_order_id) as total_orders,
        count(distinct customer_id) as total_customers,
        sum(order_qty) as total_units_sold,
        sum(gross_sales_amount) as total_gross_revenue,
        sum(discount_amount) as total_discount_amount,
        sum(net_sales_amount) as total_net_revenue,
        sum(total_cost) as total_cost_amount,
        sum(gross_margin) as total_gross_margin
    from item_sales
    group by
        order_month,
        order_year,
        order_month_num,
        territory_id,
        territory_name,
        territory_group,
        category_name
)
select * from monthly_agg
