{{ config(materialized='view') }}

-- STAGING : nettoyage léger + renommage colonnes RAW

select
    newreg_l as region,      -- nom région lisible
    sexe as gender,          -- H / F
    trage as age_group,      -- tranche d'âge brute
    pop as population        -- population brute

from {{ source('raw_population','populationbrut') }}