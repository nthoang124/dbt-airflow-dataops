with source as (
    select * from {{ source('adventureworks', 'SalesOrderHeader') }}
),
staged as (
    select
        cast(SalesOrderID as int) as sales_order_id,
        cast(SalesOrderNumber as nvarchar(30)) as sales_order_number,
        cast(CustomerID as int) as customer_id,
        cast(TerritoryID as int) as territory_id,
        cast(OrderDate as datetime) as order_date,
        cast(DueDate as datetime) as due_date,
        cast(ShipDate as datetime) as ship_date,
        case cast(Status as int)
            when 1 then 'In Process'
            when 2 then 'Approved'
            when 3 then 'Backordered'
            when 4 then 'Rejected'
            when 5 then 'Shipped'
            when 6 then 'Cancelled'
            else 'Unknown'
        end as order_status,
        cast(OnlineOrderFlag as bit) as is_online_order,
        case 
            when OnlineOrderFlag = 1 then 'Online'
            else 'Offline / Reseller'
        end as order_channel,
        cast(SubTotal as decimal(18, 4)) as subtotal_amount,
        cast(TaxAmt as decimal(18, 4)) as tax_amount,
        cast(Freight as decimal(18, 4)) as freight_amount,
        cast(TotalDue as decimal(18, 4)) as total_due_amount,
        cast(ModifiedDate as datetime) as modified_date
    from source
)
select * from staged