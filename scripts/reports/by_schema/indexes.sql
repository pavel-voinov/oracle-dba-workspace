/*
*/
@reports/reports_header
@reports/db_version

set termout off
column cols_agg new_value cols_agg
SELECT case
         when to_number('&db_version') < 11 then
           'wm_concat(column_name || decode(c.descend, ''DESC'', c.descend))'
         else
           'listagg(column_name || decode(c.descend, ''DESC'', c.descend), '','') within group(order by column_position)'
       end as cols_agg
FROM dual
/
set termout on

define schema=&1

column index_name format a30 heading "Index name"
column index_type format a23 heading "Index type"
column table_name format a38 heading "Table name"
column tablespace_name format a30 heading "Tablespace name"
column uniqueness format a10 heading "Unique"
column secondary format a10 heading "Secondary"
column compression format a11 heading "Compression"
column columns format a44 heading "Columns" word_wrapped

SELECT decode(owner, table_owner, '', table_owner || '.') || table_name as table_name, decode(generated, 'N', index_name, '*GENERATED NAME*') as index_name,
  (SELECT to_char(&cols_agg)
   FROM dba_ind_columns c
   WHERE c.index_owner = i.owner AND c.index_name = i.index_name) as columns,
  index_type, uniqueness, tablespace_name
FROM dba_indexes i
WHERE owner = '&schema' AND decode(index_type, 'DOMAIN', 1, 'LOB', 2, 0) = 0
ORDER BY table_name, index_name, columns
/
