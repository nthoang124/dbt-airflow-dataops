{{ config(
    materialized='view',
    schema='staging'
) }}

SELECT
    SalesOrderID as order_id,
    CustomerID as customer_id,
    TerritoryID as territory_id,
    OrderDate as order_date,
    DueDate as due_date,
    ShipDate as ship_date,
    Status as status,
    SubTotal as sub_total,
    TaxAmt as tax_amount,
    Freight as freight,
    TotalDue as total_amount,
    ModifiedDate as modified_date
FROM {{ source('adventureworks', 'SalesOrderHeader') }}
