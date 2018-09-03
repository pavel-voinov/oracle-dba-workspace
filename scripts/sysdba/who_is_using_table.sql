/*
*/
SELECT s.inst_id, s.sid, s.serial#, s.status, s.username, s.osuser, s.program, s.machine, c.owner, c.object_name, c.object_type
FROM gv$locked_object a, gv$session s, dba_objects c
WHERE s.inst_id = a.inst_id
  AND s.sid = a.session_id
  AND a.object_id = c.object_id
  AND a.object_id IN (SELECT object_id FROM dba_objects WHERE owner = upper('&1') AND object_name LIKE upper('&2'))
/
