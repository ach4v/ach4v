{{ config(materialized='table') }}

with combined as (

    select
        'age' as indicator_type,
        age_group as dimension,
        year_path_started as year,
        representativity_index as index_value
    from {{ ref('int_evo_age_analysis') }}

    union all

    select
        'gender',
        gender,
        year_path_started,
        representativity_index
    from {{ ref('int_evo_gender_indicator') }}

    union all

    select
        'territory',
        region,
        year_path_started,
        students_per_100k
    from {{ ref('int_evo_territoire_penetration') }}

),

-- ✅ On calcule les stats une seule fois
stats as (

    select
        *,
        avg(index_value) over (partition by indicator_type) as indicator_avg
    from combined

)

select
    indicator_type,
    dimension,
    year,
    index_value,
    indicator_avg,
    index_value - indicator_avg as gap_to_avg,

    case
        when index_value is null then 'Unknown'

        when indicator_type in ('age','gender')
             and index_value < 0.8 then 'Underrepresented'

        when indicator_type in ('age','gender')
             and index_value > 1.2 then 'Overrepresented'

        when indicator_type = 'territory'
             and index_value < indicator_avg then 'Below Average'

        else 'Balanced'
    end as status

from stats