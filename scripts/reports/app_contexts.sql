/*
*/
@@reports.inc

column schema format a30 heading "Schema"
column namespace format a30 heading "Namespace"
column package format a30 heading "Package"
column type format a30 heading "Type"


SELECT namespace, schema, package, type
fROM dba_context
ORDER BY 1, 2
/

