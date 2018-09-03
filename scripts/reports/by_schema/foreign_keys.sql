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
column delete_rule format a30 heading "Delete rule"
column columns format a44 heading "Columns" word_wrapped
column status format a8 heading "Status"
column validated format a13 heading "Validated"
column r_constraint_name format a30 heading "Ref. constraint"
column r_owner format a30 heading "Ref. owner"

SELECT table_name, constraint_name, columns, r_owner, r_constraint_name, status, validated, delete_rule
FROM (
SELECT i.table_name, decode(i.generated, 'N', i.constraint_name, '*GENERATED NAME*') as constraint_name, i.r_owner, i.r_constraint_name,
  (SELECT to_char(&cols_agg)
   FROM dba_cons_columns c
   WHERE c.owner = i.owner AND c.constraint_name = i.constraint_name) as columns,
  i.status, i.validated, i.delete_rule
FROM dba_constraints i, dba_tables t
WHERE i.owner = '&schema' AND i.constraint_type = 'R'
  AND t.table_name = i.table_name AND t.owner = i.owner AND t.dropped = 'NO'
)
ORDER BY table_name, constraint_name, columns
/
