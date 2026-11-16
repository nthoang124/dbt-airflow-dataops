with source as (
    select * from {{ source('adventureworks', 'SalesTerritory') }}
),
staged as (
    select
        cast(TerritoryID as int) as territory_id,
        cast(Name as nvarchar(50)) as territory_name,
        cast(CountryRegionCode as nvarchar(5)) as country_code,
        cast([Group] as nvarchar(50)) as territory_group,
        cast(ModifiedDate as datetime) as modified_date
    from source
)
select * from staged
