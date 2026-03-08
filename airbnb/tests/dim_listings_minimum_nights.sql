select count (*)  as NB_ERRORS
from {{ref('dim_listings_cleansed')}}
where minimum_nights<1
having count (*) >0