{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    ProductCategoryID as category_id,
    Name as category_name,
    ModifiedDate as modified_date
FROM {{ source('adventureworks_production', 'ProductCategory') }}