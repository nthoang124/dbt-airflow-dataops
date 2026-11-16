{{config(
    materialized='view',
    schema='staging'
)}}

SELECT
    CustomerID as customer_id,
    PersonID as person_id,
    StoreID as store_id,
    TerritoryID as territory_id,
    AccountNumber as account_number,
    ModifiedDate as modified_date
FROM {{ source('adventureworks', 'Customer') }}