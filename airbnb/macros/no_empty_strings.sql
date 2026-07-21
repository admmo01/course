
{%- macro no_empty_strings(model) -%}
   
    {%- for  col in adapter.get_columns_in_relation(model) -%}
        {%- if col.is_string() -%}
            coalesce({{ col.name }},'') <> '' AND
        {%- endif %}
    {% endfor -%}
    TRUE
     
{%- endmacro -%} 


