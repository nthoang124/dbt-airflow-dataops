with details as (
    select * from {{ ref('stg_sales_order_details') }}
),
headers as (
    select * from {{ ref('stg_sales_order_headers') }}
),
products as (
    select * from {{ ref('stg_production_product') }}
),
categories as (
    select * from {{ ref('stg_production_product_categories') }}
),
territories as (
    select * from {{ ref('stg_sales_territories') }}
),
joined as (
    select
        d.sales_order_detail_id,
        d.sales_order_id,
        h.order_date,
        -- Truncate order_date to first day of the month for monthly grouping
        datefromparts(year(h.order_date), month(h.order_date), 1) as order_month,
        year(h.order_date) as order_year,
        month(h.order_date) as order_month_num,
        h.customer_id,
        h.territory_id,
        coalesce(t.territory_name, 'Unassigned') as territory_name,
        coalesce(t.territory_group, 'Unassigned') as territory_group,
        h.order_status,
        h.order_channel,
        d.product_id,
        p.product_name,
        coalesce(c.category_name, 'Uncategorized') as category_name,
        coalesce(c.subcategory_name, 'Uncategorized') as subcategory_name,
        d.order_qty,
        d.unit_price,
        d.unit_price_discount,
        -- Financial calculations
        cast(d.order_qty * d.unit_price as decimal(18, 4)) as gross_sales_amount,
        cast(d.order_qty * d.unit_price * d.unit_price_discount as decimal(18, 4)) as discount_amount,
        cast(d.line_total as decimal(18, 4)) as net_sales_amount,
        cast(d.order_qty * coalesce(p.standard_cost, 0) as decimal(18, 4)) as total_cost,
        cast(d.line_total - (d.order_qty * coalesce(p.standard_cost, 0)) as decimal(18, 4)) as gross_margin
    from details d
    inner join headers h on d.sales_order_id = h.sales_order_id
    left join products p on d.product_id = p.product_id
    left join categories c on p.subcategory_id = c.subcategory_id
    left join territories t on h.territory_id = t.territory_id
    where h.order_status != 'Cancelled'
)
select * from joined
