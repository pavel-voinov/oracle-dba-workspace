/*
*/
set serveroutput on timing on echo off

define p_schema=&1
define db_link=&2

set termout on

column dir format a15 heading "Difference"
column table_name format a32 heading "Table name"

TTITLE "Compare tables (excluding temporary, secondary, external and mview log tables)"
SELECT 'LOCAL->REMOTE' as dir, table_name, column_name
FROM (SELECT c.table_name, c.column_name, c.column_id, c.data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
      FROM dba_tables t, dba_tab_columns c
      WHERE t.owner = upper('&p_schema') AND t.secondary = 'N' AND t.temporary = 'N' AND c.owner = t.owner AND c.table_name = t.table_name
        AND not exists (SELECT table_name FROM dba_external_tables WHERE owner = upper('&p_schema')
                        MINUS
                        SELECT log_table FROM dba_mview_logs WHERE log_owner = upper('&p_schema'))
      MINUS
      SELECT c.table_name, c.column_name, c.column_id, c.data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
      FROM dba_tables@&db_link t, dba_tab_columns@&db_link c
      WHERE t.owner = upper('&p_schema') AND t.secondary = 'N' AND t.temporary = 'N' AND c.owner = t.owner AND c.table_name = t.table_name)
UNION ALL
SELECT 'REMOTE->LOCAL' as dir, table_name, column_name
FROM (SELECT c.table_name, c.column_name, c.column_id, c.data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
      FROM dba_tables@&db_link t, dba_tab_columns@&db_link c
      WHERE t.owner = upper('&p_schema') AND t.secondary = 'N' AND t.temporary = 'N' AND c.owner = t.owner AND c.table_name = t.table_name
        AND not exists (SELECT table_name FROM dba_external_tables@&db_link WHERE owner = upper('&p_schema')
                        MINUS
                        SELECT log_table FROM dba_mview_logs@&db_link WHERE log_owner = upper('&p_schema'))
      MINUS
      SELECT c.table_name, c.column_name, c.column_id, c.data_type, c.data_length, c.data_precision, c.data_scale, c.nullable
      FROM dba_tables t, dba_tab_columns c
      WHERE t.owner = upper('&p_schema') AND t.secondary = 'N' AND t.temporary = 'N' AND c.owner = t.owner AND c.table_name = t.table_name)
/
