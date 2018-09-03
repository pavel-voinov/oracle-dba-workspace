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
column table_name format a30 heading "Table name"
column index_name format a30 heading "Index name"
column columns format a44 heading "Columns" word_wrapped
column status format a8 heading "Status"
column validated format a13 heading "Validated"

SELECT table_name, constraint_name, columns, status, validated, regexp_replace(index_name, '^(SYS_IOT_TOP).*$', '\1_INDEX') as index_name
FROM (
SELECT i.table_name, decode(i.generated, 'N', i.constraint_name, '*GENERATED NAME*') as constraint_name,
  (SELECT to_char(&cols_agg)
   FROM dba_cons_columns c
   WHERE c.owner = i.owner AND c.constraint_name = i.constraint_name) as columns,
  i.status, i.validated,
  nullif(decode(i.owner, i.index_owner, '', i.index_owner || '.') || index_name, '.') as index_name
FROM dba_constraints i, dba_tables t
WHERE i.owner = '&schema' AND i.constraint_type = 'U'
  AND t.table_name = i.table_name AND t.owner = i.owner AND t.dropped = 'NO'
)
ORDER BY table_name, constraint_name, columns
/
