/*
*/
@reports/reports_header

define schema=&1

column granted_role format a30 heading "Role"
column admin_option format a12 heading "Admin option"
column default_role format a10 heading "Is default"

SELECT granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee = '&schema'
ORDER BY 1
/
