/*
*/
@reports/reports_header
set feedback off heading off
@system_users_filter.sql

column sql_text format a32000 word_wrapped

SELECT 'GRANT ' || listagg(privilege, ', ') within group (order by privilege) || ' ON ' || decode(privilege, 'READ', 'DIRECTORY ', 'WRITE', 'DIRECTORY ', '"' || owner || '".') || '"' || table_name || '" TO "' || grantee || '"' || decode(grantable, 'YES', ' WITH GRANT OPTION') || ';' as sql_text
FROM dba_tab_privs
WHERE not regexp_like(grantee, :v_sys_users_regexp)
GROUP BY grantee, owner, table_name, grantable
ORDER BY grantee, owner, table_name
/
