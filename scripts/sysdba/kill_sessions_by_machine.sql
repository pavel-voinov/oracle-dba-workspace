set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading on long 32000 autotrace off newpage none

set termout off

define machine='&1'
define fmask=''
column time_stamp new_value fmask

SELECT 'kill_sessions_' || to_char(sysdate, 'YYYYMMDDHH24MISS') || '.sql' as time_stamp FROM dual
/

set termout on

PROMPT Sessions to kill:

column username format a30
column machine format a40
column spid format a15

SELECT s.inst_id, s.sid, s.serial#, s.username, s.osuser, s.program, s.machine, p.spid, s.status
FROM gv$session s, gv$process p
WHERE regexp_like(s.machine, '^(&machine.)$', 'i')
  AND s.inst_id = p.inst_id
  AND p.addr = s.paddr
ORDER BY s.inst_id, s.status, s.sid
/

column sql_text format a1024 word_wrapped

set heading off

spool /tmp/&fmask

PROMPT set echo on timing on

SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ',@' || inst_id || ''' IMMEDIATE;' as sql_text
FROM gv$session
WHERE regexp_like(machine, '^(&machine.)$', 'i')
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

