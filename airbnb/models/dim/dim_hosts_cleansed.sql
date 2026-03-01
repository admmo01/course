WITH src_hosts AS (
    SELECT * FROM {{ref('src_hosts')}} 
)

SELECT id, 
COALESCE(name,'Anonymous') AS host_name, 
is_superhost,
creation_date,
update_date 
FROM src_hosts 