{{ config(materialized='view') }}

with students as (

    select
        year_path_started,
        age_group,
        count(user_id) as nb_students

    from {{ ref('int_etudiants') }}
    group by year_path_started, age_group

),

population as (

    -- Population 2025 utilisée comme référence fixe
    select
        age_group,
        sum(population) as population_age
    from {{ ref('int_population2025') }}
    group by age_group

),

totals as (

    select
        year_path_started,
        sum(nb_students) as total_students
    from students
    group by year_path_started

),

total_population as (

    select sum(population_age) as total_population
    from population

)

select
    s.year_path_started,
    s.age_group,
    s.nb_students,
    p.population_age,

    -- % étudiants dans la tranche pour l'année
    (s.nb_students::float / t.total_students) * 100 as pct_students,

    -- % population dans la tranche (référence 2025)
    (p.population_age::float / tp.total_population) * 100 as pct_population,

    -- Indice de représentativité
    case
        when t.total_students = 0
          or tp.total_population = 0
        then null
        else
            ((s.nb_students::float / t.total_students))
            /
            ((p.population_age::float / tp.total_population))
    end as representativity_index

from students s

left join population p
    on s.age_group = p.age_group

left join totals t
    on s.year_path_started = t.year_path_started

cross join total_population tp