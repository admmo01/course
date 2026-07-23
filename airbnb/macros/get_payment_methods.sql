{% macro get_column_values (column_name, relation) %}

{% set query %}

   select distinct {{column_name}}
   from {{relation}}
   order by 1

{% endset %}

{% set results = run_query(query) %}
{% if execute %}

    {% set results_list=results.columns[0].values() %}

{% else %}

    {% set results_list=[] %}

{% endif %}   

{{ log (results_list, info=True)}}
{{ return(results_list) }}


{% endmacro %}











{% macro get_payment_methods() %}

{{ return(get_column_values('payment_method', ref('raw_payments'))) }}

{% endmacro %}
