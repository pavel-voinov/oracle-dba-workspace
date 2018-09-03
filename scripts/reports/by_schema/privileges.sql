/*
*/
@reports/reports_header

define schema=&1

column owner format a30 heading "Object owner"
column table_name format a30 heading "Object name"
column grantor format a30 heading "Grantor"
column privilege format a30 heading "Privilege"
column grantable format a10 heading "Grantable"

SELECT owner, table_name, privilege, grantable
FROM dba_tab_privs
WHERE grantee = '&schema'
ORDER BY 1, 2, 3
/
