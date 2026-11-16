with customers as (
    select * from {{ source('adventureworks', 'Customer') }}
),
persons as (
    select * from {{ source('adventureworks_person', 'Person') }}
),
stores as (
    select * from {{ source('adventureworks', 'Store') }}
),
staged as (
    select
        cast(c.CustomerID as int) as customer_id,
        cast(c.PersonID as int) as person_id,
        cast(c.StoreID as int) as store_id,
        cast(c.TerritoryID as int) as territory_id,
        cast(c.AccountNumber as nvarchar(30)) as account_number,
        case
            when c.PersonID is not null then 'Individual Consumer'
            when c.StoreID is not null then 'Retail Store'
            else 'Unknown'
        end as customer_type,
        coalesce(
            rtrim(concat(p.FirstName, ' ', p.MiddleName + ' ', p.LastName)),
            rtrim(concat(p.FirstName, ' ', p.LastName)),
            s.Name,
            'Customer #' + cast(c.CustomerID as nvarchar(10))
        ) as customer_name,
        cast(c.ModifiedDate as datetime) as modified_date
    from customers c
    left join persons p on c.PersonID = p.BusinessEntityID
    left join stores s on c.StoreID = s.BusinessEntityID
)
select * from staged