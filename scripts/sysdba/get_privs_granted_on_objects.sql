/*

Script to get privileges granted on schema objects to all or specified user
*/
set serveroutput on size unlimited linesize 1024 long 32000 trimspool on newpage none define on scan on verify off

define p_owner=&1
define p_user=&2

set termout off
column fmask new_value fmask
SELECT 'privs_granted_on_' || lower('&p_owner') || '_objects_to_' || replace(lower('&p_user'), '%', 'all') || '.sql' as fmask FROM dual;
set termout on heading off feedback off timing off pagesize 9999 trimspool on echo off verify off newpage none long 2000000000 linesize 32767

column sql_text format a1024 word_wrapped

whenever sqlerror continue

PROMPT Object privileges will be saved in &fmask
spool &fmask
SELECT 'GRANT ' || privilege || ' ON "' || owner || '"."' || table_name || '" TO "' || grantee || '"' || decode(grantable, 'YES', ' WITH GRANT OPTION') || ';' as sql_text
FROM dba_tab_privs
WHERE owner = upper('&p_owner')
  AND grantee like upper('&p_user')
/
spool off

undefine p_owner
undefine p_user
