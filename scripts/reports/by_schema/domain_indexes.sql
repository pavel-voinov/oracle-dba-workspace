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

define p_schema=&1

column index_name format a30 heading "Index name"
column table_name format a36 heading "Table name"
column uniqueness format a10 heading "Uniqueness"
column index_type format a30 heading "Domain index type"
column status format a10 heading "Status"
column domidx_status format a20 heading "Domain index|status/op.status"
column columns format a30 heading "Columns"
column parameters format a180 heading "Domain index parameters" newline word_wrapped

SELECT index_name,
  decode(owner, table_owner, '', table_owner || '.') || table_name as table_name,
  (SELECT to_char(&cols_agg)
   FROM dba_ind_columns c
   WHERE c.index_owner = i.owner AND c.index_name = i.index_name) as columns,
  uniqueness,
  ityp_owner || '.' || ityp_name as index_type,
  status,
  domidx_status || '/' || domidx_opstatus as domidx_status,
  parameters
FROM dba_indexes i
WHERE owner = '&p_schema' AND index_type = 'DOMAIN'
ORDER BY 1, 2, 3
/
