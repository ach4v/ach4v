{{ config(materialized='view') }}

with students as (

    select
        year_path_started,
        gender,
        count(user_id) as nb_students

    from {{ ref('int_etudiants') }}
    where gender in ('M','F')  -- on exclut unknown
    group by year_path_started, gender

),

population as (

    -- Population 2025 comme référence
    select
        gender,
        sum(population) as population_gender
    from {{ ref('int_population2025') }}
    where gender in ('M','F')
    group by gender

),

totals as (

    select
        year_path_started,
        sum(nb_students) as total_students
    from students
    group by year_path_started

),

total_population as (

    select sum(population_gender) as total_population
    from population

)

select
    s.year_path_started,
    s.gender,
    s.nb_students,
    p.population_gender,

    -- % étudiants par genre dans l'année
    (s.nb_students::float / t.total_students) * 100 as pct_students,

    -- % population genre (référence fixe 2025)
    (p.population_gender::float / tp.total_population) * 100 as pct_population,

    -- Indice de représentativité
    case
        when t.total_students = 0
          or tp.total_population = 0
        then null
        else
            ((s.nb_students::float / t.total_students))
            /
            ((p.population_gender::float / tp.total_population))
    end as representativity_index

from students s

left join population p
    on s.gender = p.gender

left join totals t
    on s.year_path_started = t.year_path_started

cross join total_population tp