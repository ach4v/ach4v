{{ config(materialized='table') }}

with combine as (

    select
        'âge' as type_indicateur,
        age_group as dimension,
        year_path_started as annee,
        'indice_representativite' as type_metrque,
        representativity_index as valeur_metrque
    from {{ ref('int_evo_age_analysis') }}

    union all

    select
        'genre',
        gender,
        year_path_started,
        'indice_representativite',
        representativity_index
    from {{ ref('int_evo_gender_indicator') }}

    union all

    select
        'territoire',
        region,
        year_path_started,
        'taux_pour_100k',
        students_per_100k
    from {{ ref('int_evo_territoire_penetration') }}

)

select
    type_indicateur,
    dimension,
    annee,
    type_metrque,
    valeur_metrque,

    case
        when valeur_metrque is null then 'Inconnu'

        when type_indicateur in ('âge','genre')
             and valeur_metrque < 0.8 then 'Sous-représenté'

        when type_indicateur in ('âge','genre')
             and valeur_metrque > 1.2 then 'Surreprésenté'

        when type_indicateur = 'territoire'
             and valeur_metrque < 2 then 'Faible pénétration'

        when type_indicateur = 'territoire'
             and valeur_metrque between 2 and 6 then 'Pénétration moyenne'

        else 'Pénétration forte'
    end as statut

from combine