@@reports.inc

column inst_id format 990 heading "Inst#"
column sid format a12 heading "SID"
column blocked_sid format a12 heading "Blocked|SID"
column username format a25 heading "Username"
column machine format a35 heading "Machine"
column osuser format a25 heading "OS user"
column program format a38 heading "Program" word_wrapped
column blocked_program format a38 heading "Blocked|program" word_wrapped
column service_name format a16 heading "Service"
column spid format a6 heading "SPID"

SELECT s.inst_id, s.sid || ',' || s.serial# as sid, regexp_replace(s.service_name, '\.' || sys_context('USERENV', 'DB_DOMAIN') || '$') as service_name, s.username, s.machine, s.osuser, s.program,
  ls.sid || ',' || ls.serial# as blocked_sid, ls.program as blocked_program
FROM gv$session s, gv$session ls, gv$lock l, gv$lock ll
WHERE (l.inst_id, l.id1, l.id2) IN (SELECT inst_id, id1, id2 FROM gv$lock WHERE request = 0
                                    INTERSECT
                                    SELECT inst_id, id1, id2 FROM gv$lock WHERE lmode = 0)
  AND l.inst_id = ll.inst_id
  AND l.id1 = ll.id1
  AND l.id2 = ll.id2
  AND l.request = 0
  AND ll.lmode = 0
  AND l.sid = s.sid AND l.inst_id = s.inst_id
  AND ll.sid = ls.sid AND ll.inst_id = ls.inst_id
--  AND NOT (s.inst_id = SYS_CONTEXT('USERENV', 'INSTANCE') AND s.sid = SYS_CONTEXT('USERENV', 'SID'))
ORDER BY s.inst_id, s.username, s.service_name, s.sid
/
