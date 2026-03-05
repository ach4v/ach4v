{{ config(materialized='view') }}

with base as (

    select
        case 
            when trim(substr(region, 6)) in (
                'Guadeloupe',
                'Martinique',
                'Guyane',
                'La Réunion',
                'Mayotte'
            ) then 'DROM'
            else trim(substr(region, 6))
        end as region,

        case 
            when gender = 'H' then 'M'
            when gender = 'F' then 'F'
            else gender
        end as gender,

        case 
            when age_group not in (
                '0 à 4 ans',
                '5 à 9 ans',
                '10 à 14 ans',
                '15 à 19 ans'
            )
            then
                case
                    when age_group = '20 à 24 ans' then '20-24 ans'
                    when age_group = '25 à 29 ans' then '25-29 ans'
                    when age_group = '30 à 34 ans' then '30-34 ans'
                    when age_group = '35 à 39 ans' then '35-39 ans'
                    when age_group = '40 à 44 ans' then '40-44 ans'
                    when age_group = '45 à 49 ans' then '45-49 ans'
                    when age_group = '50 à 54 ans' then '50-54 ans'
                    when age_group = '55 à 59 ans' then '55-59 ans'
                    when age_group in (
                        '60 à 64 ans',
                        '65 à 69 ans',
                        '70 à 74 ans',
                        '75 à 79 ans',
                        '80 ans et plus'
                    ) then '60 ans ou plus'
                end
        end as age_group,

        population

    from {{ ref('stg_population2025') }}

    where trim(substr(region, 6)) != 'Corse'

)

select
    region,
    gender,
    age_group,
    sum(population) as population

from base

where age_group is not null

group by region, gender, age_group

