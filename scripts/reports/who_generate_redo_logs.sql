/*
*/
@@reports.inc

column username format a30
column program format a30
column machine format a30

SELECT inst_id, sid, serial#, username, program, machine, block_changes
FROM (SELECT s.inst_id, s.sid, s.serial#, s.username, s.program, s.machine, i.block_changes, row_number () over (partition by s.inst_id order by i.block_changes desc) as rn
      FROM gv$session s, gv$sess_io i
      WHERE s.inst_id = i.inst_id AND s.sid = i.sid 
      ORDER BY i.block_changes desc)
WHERE rn <= 10
ORDER BY inst_id;
