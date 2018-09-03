/*
*/
@reports/reports_header

define schema=&1

column view_name format a30 heading "View name"
column text_length format 99999990 heading "Length of query text"
column status format a10 heading "Status"

SELECT v.view_name, v.text_length, o.status
FROM dba_views v, dba_objects o
WHERE v.owner = '&schema' AND o.owner = v.owner AND o.object_type = 'VIEW' AND o.object_name = v.view_name
ORDER BY 1
/
