@reports/reports.inc

column inst_id format 990 heading "Inst#"
column sid format 999990 heading "SID"
column spid format a7 heading "SrvPID"
column status format a10 heading "Status"
column username format a20 heading "DB user"
column machine format a20 heading "Machine"
column osuser format a15 heading "OS user"
column program format a30 heading "Program" word_wrapped
column sql_text format a120 newline
column object_name format a50 heading "Object name"

SELECT s.inst_id, s.sid, s.status, s.username, s.osuser, s.machine, s.program, p.spid, a.owner || '.' || a.object || ' (' || a.type || ')' as object_name,
  'ALTER SYSTEM KILL SESSION ''' || s.sid || ',' || s.serial# || ',@' || s.inst_id || ''' IMMEDIATE;' as sql_text
FROM gv$session s, gv$access a, gv$process p
WHERE s.inst_id = a.inst_id and s.sid = a.sid
  AND a.owner = upper('&1')
  AND a.object like upper('&2')
  AND p.inst_id = s.inst_id
  AND p.addr = s.paddr
/
