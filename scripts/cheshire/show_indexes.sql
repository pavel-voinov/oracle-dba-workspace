/*
*/
set serveroutput on size unlimited linesize 180 pagesize 9999

column index_name format a36 heading "Index name"
column table_name format a36 heading "Table name"
column uniqueness format a12 heading "Uniqueness"
column index_type format a40 heading "Domain index|type"
column status format a10 heading "Status"
column domidx_status format a20 heading "Domain index|status/op.status"
column columns format a20 heading "Columns"
column parameters format a180 heading "Domain index parameters" newline word_wrapped

break on owner
compute count label "Count" of owner on owner

SELECT owner || '.' || index_name as index_name,
  table_owner || '.' || table_name as table_name,
  (SELECT listagg(column_name || decode(c.descend, 'DESC', c.descend), ',') within group(order by column_position)
   FROM all_ind_columns c
   WHERE c.index_owner = i.owner AND c.index_name = i.index_name) as columns,
  uniqueness, ityp_owner || '.' || ityp_name as index_type,
  status, domidx_status || '/' || domidx_opstatus as domidx_status,
  parameters
FROM all_indexes i
WHERE index_type = 'DOMAIN' AND regexp_like(ityp_owner, '^C\$MDLICHESH[0-9]{2}$')
ORDER BY 1, 2, 3
/

clear breaks
clear computes
