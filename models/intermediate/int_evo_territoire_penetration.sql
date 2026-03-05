{{ config(materialized='view') }}

with students as (

    select
        year_path_started,
        region,
        count(user_id) as nb_students

    from {{ ref('int_etudiants') }}
    group by year_path_started, region

),

population as (

    -- Population 2025 comme référence fixe
    select
        region,
        sum(population) as population_region
    from {{ ref('int_population2025') }}
    group by region

)

select
    s.year_path_started,
    s.region,
    s.nb_students,
    p.population_region,

    -- ✅ Taux pour 100 000 habitants
    case
        when p.population_region = 0 then null
        else (s.nb_students::float / p.population_region) * 100000
    end as students_per_100k,

    -- ✅ Statut stratégique
    case
        when (s.nb_students::float / p.population_region) * 100000 < 2
            then 'Low Penetration'
        when (s.nb_students::float / p.population_region) * 100000 between 2 and 6
            then 'Medium Penetration'
        else 'High Penetration'
    end as penetration_level

from students s

left join population p
    on s.region = p.region