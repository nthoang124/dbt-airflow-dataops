with monthly_base as (
    select * from {{ ref('int_monthly_sales_aggregated') }}
),
with_growth_lag as (
    select
        order_month,
        order_year,
        order_month_num,
        territory_name,
        territory_group,
        category_name,
        total_orders,
        total_customers,
        total_units_sold,
        total_net_revenue,
        total_gross_margin,
        -- Prior month revenue for MoM
        lag(total_net_revenue, 1) over (
            partition by territory_name, category_name
            order by order_month
        ) as prev_month_revenue,
        -- Prior year (12 months ago) revenue for YoY
        lag(total_net_revenue, 12) over (
            partition by territory_name, category_name
            order by order_month
        ) as prev_year_revenue
    from monthly_base
),
final_metrics as (
    select
        order_month,
        order_year,
        order_month_num,
        territory_name,
        territory_group,
        category_name,
        total_orders,
        total_customers,
        total_units_sold,
        total_net_revenue,
        total_gross_margin,
        -- Profit Margin %
        case 
            when total_net_revenue > 0 
            then cast((total_gross_margin / total_net_revenue) * 100 as decimal(10, 2))
            else 0 
        end as profit_margin_pct,
        -- MoM Growth %
        case
            when prev_month_revenue is not null and prev_month_revenue > 0
            then cast(((total_net_revenue - prev_month_revenue) / prev_month_revenue) * 100 as decimal(10, 2))
            else null
        end as mom_revenue_growth_pct,
        -- YoY Growth %
        case
            when prev_year_revenue is not null and prev_year_revenue > 0
            then cast(((total_net_revenue - prev_year_revenue) / prev_year_revenue) * 100 as decimal(10, 2))
            else null
        end as yoy_revenue_growth_pct
    from with_growth_lag
)
select * from final_metrics