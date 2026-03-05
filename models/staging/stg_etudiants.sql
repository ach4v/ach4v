{{ config(materialized='view')}}

    -- Nomminer les colonnes pour facilité les jointures entre les 2 tables RAW


select  case 
        when user_id like 'U-%' then user_id           
        when user_id like 'U%' then concat('U-', substr(user_id, 2))  
        else user_id -- Standardisation de format                                 
    end as user_id,
        path_category_name,
        age_group,
        coalesce(gender, 'unknown') as gender, -- Remplace les lignes null de gender par unknown (H / F / Unknown)
        region,
        try_cast(year_path_started as integer) as year_path_started -- Convertir les lignes de cette colonne en INT pour éviter les erreurs. Précaution.

from {{ source('raw_etudiantbrut','etudiants')}}