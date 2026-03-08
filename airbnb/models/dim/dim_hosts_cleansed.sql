{{
  config(
    materialized='view'
  )

}}


WITH src_hosts AS (
    SELECT * FROM {{ref('src_hosts')}} 
)

SELECT host_id, 
COALESCE(name,'Anonymous') AS host_name, 
--iff(is_superhost='t',true,false) as is_superhost, this is just to test contract
is_superhost,
created_at,
updated_at 
FROM src_hosts 