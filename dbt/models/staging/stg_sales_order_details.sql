with source as (
    select * from {{ source('adventureworks', 'SalesOrderDetail') }}
),
staged as (
    select
        cast(SalesOrderDetailID as int) as sales_order_detail_id,
        cast(SalesOrderID as int) as sales_order_id,
        cast(ProductID as int) as product_id,
        cast(OrderQty as int) as order_qty,
        cast(UnitPrice as decimal(18, 4)) as unit_price,
        cast(UnitPriceDiscount as decimal(18, 4)) as unit_price_discount,
        cast(LineTotal as decimal(38, 6)) as line_total,
        cast(ModifiedDate as datetime) as modified_date
    from source
)
select * from staged