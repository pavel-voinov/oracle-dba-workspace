/*
*/
@@reports.inc

column owner format a30 heading "schema"
column object_type format a30 heading "Object type"
column object_name format a30 heading "Object name"

break on owner
compute count label "Count" of owner on owner


SELECT owner, object_type, object_name
FROM dba_objects
WHERE status = 'INVALID' AND decode(object_type, 'JAVA CLASS', 1, 0) = 0
ORDER BY 1, 2, 3
/

clear breaks
clear computes

