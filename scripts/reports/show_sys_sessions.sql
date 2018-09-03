/*
*/
@@reports.inc

column inst_id format 990 heading "Inst"
column sid format a12 heading "SID"
column spid format a6 heading "SPID"
column status format a10 heading "Status"
column username format a19 heading "Username"
column machine format a30 heading "Machine"
column osuser format a25 heading "OS user"
column program format a40 heading "Program" word_wrapped
column service_name format a20 heading "Service"

SELECT s.inst_id, s.sid || ',' || s.serial# as sid, p.spid, s.service_name, s.status, s.username, s.machine, s.osuser, s.program
FROM gv$session s, gv$process p
WHERE regexp_like(s.service_name, '^SYS\$(USERS|BACKGROUND)$')
  AND p.inst_id = s.inst_id AND p.addr = s.paddr
ORDER BY s.inst_id, decode(s.status, 'ACTIVE', 0, 1), s.username, s.service_name, s.sid
/
