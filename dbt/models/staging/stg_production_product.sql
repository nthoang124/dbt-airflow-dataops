with source as (
    select * from {{ source('adventureworks_production', 'Product') }}
),
staged as (
    select
        cast(ProductID as int) as product_id,
        cast(Name as nvarchar(100)) as product_name,
        cast(ProductNumber as nvarchar(50)) as product_number,
        cast(ProductSubcategoryID as int) as subcategory_id,
        cast(StandardCost as decimal(18, 4)) as standard_cost,
        cast(ListPrice as decimal(18, 4)) as list_price,
        cast(FinishedGoodsFlag as bit) as is_finished_good,
        case when DiscontinuedDate is not null then 1 else 0 end as is_discontinued,
        cast(ModifiedDate as datetime) as modified_date
    from source
)
select * from staged