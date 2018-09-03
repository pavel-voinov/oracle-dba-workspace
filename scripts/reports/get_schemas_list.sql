/*
*/
@@reports.inc
@system_users_filter.sql
set serveroutput on size unlimited heading off timing off feedback off echo off verify off newpage none scan off linesize 4000 pagesize 9999 termout on trimspool on

SELECT username
FROM dba_users
WHERE not regexp_like(username, :v_sys_users_regexp)
ORDER BY 1
/
