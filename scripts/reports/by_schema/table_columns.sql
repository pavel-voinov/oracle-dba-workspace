/*
*/
@reports/reports_header

define schema=&1

column table_name format a30 heading "Table name"
column column_id format 990 heading "#"
column column_name format a30 heading "Column name"
column data_type format a16 heading "Data type"
column data_length format 99990 heading "Data|lenght"
column data_precision format 99990 heading "Data|precision"
column data_scale format 99990 heading "Data|scale"
column nullable format a10 heading "Nullable"
--column character_set_name format a15 heading "Charset name"

break on table_name

SELECT c.table_name, c.column_id, c.column_name,
  decode(c.data_type_owner, null, '', c.data_type_owner || '.') || c.data_type as data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
--, c.character_set_name, c.char_length, decode(c.char_used, 'B', 'BYTE', 'CHAR') as char_used, c.char_col_decl_length
fROM dba_tab_columns c, dba_tables t
WHERE t.owner = '&schema' AND t.dropped = 'NO' AND c.owner = t.owner AND c.table_name = t.table_name
ORDER BY c.table_name, c.column_id, c.column_name
/

clear breaks
