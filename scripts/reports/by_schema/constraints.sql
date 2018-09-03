/*
*/
@reports/reports_header
@reports/db_version

set termout off
column cols_agg new_value cols_agg
SELECT case
         when to_number('&db_version') < 11 then
           'wm_concat(column_name)'
         else
           'listagg(column_name, '','') within group(order by position)'
       end as cols_agg
FROM dual
/
set termout on

define schema=&1

column constraint_name format a30 heading "Constraint name"
column constraint_type format a10 heading "Constraint|type"
column table_name format a38 heading "Table name"
column columns format a44 heading "Columns" word_wrapped
column status format a8 heading "Status"

SELECT table_name, decode(generated, 'N', constraint_name, '*GENERATED NAME*') as constraint_name,
  (SELECT to_char(&cols_agg)
   FROM dba_cons_columns c
   WHERE c.owner = i.owner AND c.constraint_name = i.constraint_name) as columns,
  decode(constraint_type, 'P', 'PK', 'R', 'FK', 'U', 'UK', 'C', 'CHECK', 'R', 'READONLY', constraint_type) as constraint_type,
  status, validated
FROM dba_constraints i
WHERE owner = '&schema'
ORDER BY table_name, constraint_name
/
