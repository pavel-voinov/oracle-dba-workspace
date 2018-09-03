/*
*/
@@reports.inc

column inst_id format 990 heading "Inst#"
column sid format a12 heading "SID"
column spid format a6 heading "SPID"
column username format a25 heading "Username"
column machine format a35 heading "Machine"
column osuser format a25 heading "OS user"
column program format a38 heading "Program" word_wrapped
column service_name format a16 heading "Service"

SELECT s.inst_id, s.sid || ',' || s.serial# as sid, p.spid, regexp_replace(s.service_name, '\.' || sys_context('USERENV', 'DB_DOMAIN') || '$') as service_name, s.username, s.machine, s.osuser, s.program
FROM gv$session s, gv$process p
WHERE not regexp_like(s.service_name, '^SYS\$(USERS|BACKGROUND)$')
  AND p.inst_id = s.inst_id AND p.addr = s.paddr
  AND s.status = 'ACTIVE'
  AND NOT (s.inst_id = SYS_CONTEXT('USERENV', 'INSTANCE') AND s.sid = SYS_CONTEXT('USERENV', 'SID'))
ORDER BY s.inst_id, s.username, s.service_name, s.sid
/
