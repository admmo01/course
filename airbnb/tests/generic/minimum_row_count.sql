{% test minimum_row_count(model, min_row_count) %}

SELECT count(*) AS ct  FROM {{ model }} 
HAVING ct < {{min_row_count}}
 
{% endtest %}