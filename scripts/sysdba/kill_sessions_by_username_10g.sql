set serveroutput on size unlimited verify off timing off feedback off linesize 1024 pagesize 9999 heading off long 32000 autotrace off newpage none echo off

set termout off

define username='&1'
define fmask=''
column time_stamp new_value fmask

SELECT 'kill_sessions_' || to_char(sysdate, 'YYYYMMDDHH24MISS') || '.sql' as time_stamp FROM dual
/

spool /tmp/&fmask

column sql_text format a1024 word_wrapped

set termout on

PROMPT set echo on

SELECT 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || serial# || ''' IMMEDIATE;' as sql_text
FROM v$session
WHERE username like upper('&username.%')
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
