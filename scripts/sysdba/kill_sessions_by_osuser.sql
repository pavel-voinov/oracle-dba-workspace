set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading on long 32000 autotrace off newpage none

set termout off

define username='&1'
--define fmask=''
column time_stamp new_value fmask

SELECT 'kill_sessions_' || to_char(sysdate, 'YYYYMMDDHH24MISS') || '.sql' as time_stamp FROM dual;

set termout on

column inst_id format 990 heading "Inst#"
column sid format 999990 heading "SID"
column spid format a6 heading "SPID"
column username format a25 heading "Username"
column machine format a35 heading "Machine"
column osuser format a25 heading "OS user"
column program format a38 heading "Program" word_wrapped
column service_name format a16 heading "Service"
column status format a8 heading "Status"

PROMPT Sessions to kill:

SELECT s.inst_id, s.sid, s.serial#, s.username, s.osuser, s.program, s.machine, p.spid, s.status
FROM gv$session s, gv$process p
WHERE regexp_like(s.osuser, '^(&username.)$', 'i')
  AND s.inst_id = p.inst_id
  AND p.addr = s.paddr
  AND status <> 'KILLED'
ORDER BY s.inst_id, s.status, s.sid
/

column sql_text format a100 word_wrapped

PROMPT set echo on timing on

set heading off

spool /tmp/&fmask

SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ',@' || inst_id || ''' IMMEDIATE;' as sql_text
FROM gv$session
WHERE regexp_like(osuser, '^(&username.)$', 'i')
  AND status <> 'KILLED'
ORDER BY inst_id, status, sid
/

PROMPT set echo off

PROMPT pause
PROMPT host rm -i /tmp/&fmask

set termout off

spool off

set termout on

PROMPT Press Ctrl-C to exit or any other key to start &fmask script
pause
@/tmp/&fmask
