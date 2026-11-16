{{ config(
    materialized='view',
    schema='staging'
)}}

SELECT
    SalesOrderID as order_id,
    CustomerID as customer_id,
    TerritoryID as territory_id,
    OrderDate as order_date,
    DueDate as due_date,
    ShipDate as ship_date,
    Status as status,
    SubTotal as sub_total,
    TaxAmt as tax_amount  
FROM {{ source('adventureworks', 'SalesOrderHeader') }}