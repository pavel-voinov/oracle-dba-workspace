/*
*/
@@reports.inc

column conf# format 9990 heading "#"
column name format a50 heading "Name"
column value format a100 heading "Value"

SELECT conf#, name, value
FROM v$rman_configuration
ORDER BY 1
/
