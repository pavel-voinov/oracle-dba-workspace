/*
*/
@@reports.inc
@system_users_filter.sql

column username format a30 heading "Username"

SELECT DISTINCT username
FROM dba_users
WHERE not regexp_like(username, :v_sys_users_regexp)
ORDER BY 1
/
