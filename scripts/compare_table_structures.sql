/*
*/
set serveroutput on timing on echo off

define p_schema=&1
define db_link=&2

set termout on

column dir format a15 heading "Difference"
column table_name format a32 heading "Table name"

TTITLE "Compare tables (excluding temporary, secondary, external and mview log tables)"
SELECT 'LOCAL DB ONLY' as dir, t.table_name
FROM
(SELECT table_name FROM dba_tables WHERE owner = upper('&p_schema') AND secondary = 'N' AND temporary = 'N'
 MINUS
 SELECT table_name FROM dba_external_tables WHERE owner = upper('&p_schema')
 MINUS
 SELECT log_table FROM dba_mview_logs WHERE log_owner = upper('&p_schema')
 MINUS 
 SELECT table_name FROM dba_tables@&db_link WHERE owner = upper('&p_schema') AND secondary = 'N' AND temporary = 'N') t
UNION ALL
SELECT 'REMOTE DB ONLY' as dir, t.table_name
FROM
(SELECT table_name FROM dba_tables@&db_link WHERE owner = upper('&p_schema') AND secondary = 'N' AND temporary = 'N'
 MINUS
 SELECT table_name FROM dba_external_tables@&db_link WHERE owner = upper('&p_schema')
 MINUS
 SELECT log_table FROM dba_mview_logs@&db_link WHERE log_owner = upper('&p_schema')
 MINUS 
 SELECT table_name FROM dba_tables WHERE owner = upper('&p_schema') AND secondary = 'N' AND temporary = 'N') t
/
