set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off newpage none

set termout off

define fmask=''
column time_stamp new_value fmask

SELECT 'kill_sessions_' || to_char(sysdate, 'YYYYMMDDHH24MISS') || '.sql' as time_stamp FROM dual
/

set termout on

column status format a10
column machine format a30
column program format a30
column username format a20
column osuser format a10

SELECT inst_id, sid, serial#, username, osuser, machine, program, status
FROM gv$session WHERE sql_id = '&1'
ORDER BY 1, 2, 4
/

spool /tmp/&fmask

column sql_text format a1024 word_wrapped

set termout on

PROMPT set echo on timing on

SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ',@' || inst_id || ''' IMMEDIATE;' as sql_text
FROM gv$session WHERE sql_id = '&1'
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





