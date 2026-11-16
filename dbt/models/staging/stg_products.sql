{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    ProductID as product_id,
    Name as product_name,
    ProductNumber as product_number,
    Color as color,
    ListPrice as list_price,
    Size as size,
    Weight as weight,
    ProductSubcategoryID as subcategory_id,
    ModifiedDate as modified_date
FROM {{ source('adventureworks_production', 'Product') }}
WHERE DiscontinuedDate IS NULL