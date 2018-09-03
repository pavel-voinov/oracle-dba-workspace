/*
*/
@reports/reports_header
set feedback off heading off
@system_users_filter.sql

column sql_text format a32000 word_wrapped

SELECT 'GRANT ' || privilege || ' TO "' || grantee || '"' || decode(admin_option, 'YES', ' WITH ADMIN OPTION') || ';' as sql_text
FROM dba_sys_privs
WHERE not regexp_like(grantee, :v_sys_users_regexp)
ORDER BY grantee, privilege
/
