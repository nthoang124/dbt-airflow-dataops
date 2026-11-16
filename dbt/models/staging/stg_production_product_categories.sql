with subcategories as (
    select * from {{ source('adventureworks_production', 'ProductSubcategory') }}
),
categories as (
    select * from {{ source('adventureworks_production', 'ProductCategory') }}
),
staged as (
    select
        cast(s.ProductSubcategoryID as int) as subcategory_id,
        cast(s.ProductCategoryID as int) as category_id,
        cast(s.Name as nvarchar(50)) as subcategory_name,
        cast(c.Name as nvarchar(50)) as category_name,
        cast(s.ModifiedDate as datetime) as modified_date
    from subcategories s
    inner join categories c on s.ProductCategoryID = c.ProductCategoryID
)
select * from staged
