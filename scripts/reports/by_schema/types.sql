/*
*/
@reports/reports_header

define schema=&1

column type_name format a30 heading "Type name"
column attributes format 99990 heading "Attributes"
column methods format 99990 heading "Methods"
column local_attributes format 99990 heading "Attributes|Local"
column local_methods format 99990 heading "Methods|Local"
column supertype_name format a30 heading "Super type"
column status format a10 heading "Status"

SELECT t.type_name, t.attributes, t.methods, t.local_attributes, t.local_methods, o.status, decode(t.supertype_owner, null, '', t.supertype_owner || '.') || t.supertype_name as supertype_name
FROM dba_types t, dba_objects o
WHERE t.owner = '&schema' AND o.owner = t.owner AND o.object_type = 'TYPE' AND o.object_name = t.type_name
ORDER BY 1
/
