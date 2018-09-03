/*

Script to get current state of constraints in schema
*/
set serveroutput on size unlimited linesize 1024 long 32000 trimspool on newpage none define on scan on verify off

define p_owner=&1
define p_table=&2

set termout off
column fmask new_value fmask
SELECT lower('&p_owner') || '_constraints_state.sql' as fmask FROM dual;
set termout on heading off feedback off timing off pagesize 9999 trimspool on echo off verify off newpage none long 2000000000 linesize 32767

column sql_text format a1024 word_wrapped

whenever sqlerror continue

spool &fmask
SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" ' || decode(status, 'ENABLED', 'ENABLE', 'DISABLED', 'DISABLE') || decode(validated, 'NOT VALIDATED', ' NOVALIDATE') || ' CONSTRAINT "' || constraint_name || '";' as sql_text
FROM dba_constraints
WHERE owner = upper('&p_owner')
  AND table_name like upper('&p_table')
  AND constraint_type in ('P', 'U', 'R')
ORDER BY owner, decode(constraint_type, 'P', 1, 'U', 2, 'R', 3, 4), table_name
/
spool off
PROMPT Constraints states have been saved into &fmask

undefine p_owner
undefine p_user
