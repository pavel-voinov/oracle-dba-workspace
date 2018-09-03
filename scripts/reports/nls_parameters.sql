/*
*/
@@reports.inc
set feedback off

column parameter format a30 heading "Parameter"
column value format a40 heading "Value"

SELECT parameter, value
FROM nls_database_parameters
ORDER BY 1
/


set feedback on
