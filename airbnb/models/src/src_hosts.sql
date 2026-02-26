WITH raw_hosts AS 
(
SELECT  * FROM  AIRBNB.RAW.RAW_HOSTS
)

SELECT id, 
name, 
is_superhost,
created_at AS creation_date,
updated_at AS update_date 

FROM raw_hosts