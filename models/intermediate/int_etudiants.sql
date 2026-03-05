{{ config(materialized='view') }}

with base as (

    select *
    from {{ ref('stg_etudiants') }}

)

select
    user_id,
    path_category_name,
    age_group,
    gender,
    region,
    year_path_started

from base

where lower(path_category_name) = 'data'