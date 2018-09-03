/*
*/
@reports/reports_header

define schema=&1

column object_type format a30 heading "Package part"
column object_name format a30 heading "Package name"
column status format a10 heading "Status"
column cnt format 9999990 heading "Lines count"

SELECT o.object_name, o.object_type, o.status, count(*) as cnt
FROM dba_objects o, dba_source s
WHERE o.owner = '&schema' AND object_type IN ('PACKAGE', 'PACKAGE BODY')
  AND s.owner = o.owner AND s.name = o.object_name AND s.type = o.object_type
GROUP BY o.object_name, o.object_type, o.status
ORDER BY 1, decode(o.object_type, 'PACKAGE', 1, 2)
/
