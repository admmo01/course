select f.* from {{ref('fct_reviews')}} f
inner join {{ref('dim_listings_cleansed')}} l
on  f.listing_id=l.listing_id 
where f.review_date < l.created_at