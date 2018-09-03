/*
*/
@reports/reports_header

define schema=&1

column object_name format a30 heading "Procedure name"
column parallel format a9 heading "Parallel"
column status format a10 heading "Status"
column cnt format 9999990 heading "Lines count"

SELECT t.object_name, o.status, t.parallel, count(*) as cnt
FROM dba_procedures t, dba_objects o, dba_source s
WHERE t.owner = '&schema' AND o.owner = t.owner AND t.object_type = 'PROCEDURE' AND o.object_type = t.object_type AND o.object_name = t.object_name
  AND s.owner = o.owner AND s.name = o.object_name AND s.type = o.object_type
GROUP BY t.object_name, o.status, t.parallel
ORDER BY 1
/
