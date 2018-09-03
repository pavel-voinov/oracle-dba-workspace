set serveroutput on size unlimited linesize 180 trimspool on

SELECT s.inst_id, s.sid, s.serial#, s.username, s.program, i.block_changes
FROM gv$session s, gv$sess_io i
WHERE s.inst_id = i.inst_id AND s.sid = i.sid
ORDER BY 1, 6 desc;
