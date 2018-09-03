/*
*/
@@reports.inc

column comp_id format a16 heading "ID"
column comp_name format a50 heading "Name" word_wrapped
column version format a12 heading "Version"
column status format a10 heading "Status"
column control format a15 heading "Control"
column schema format a20 heading "Schema"
column other_schemas format a50 heading "Other schemas"

SELECT comp_id, comp_name, version, status, control, schema, other_schemas
FROM dba_registry
ORDER BY comp_id
/
