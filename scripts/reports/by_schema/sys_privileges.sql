/*
*/
@reports/reports_header

define schema=&1

column privilege format a30 heading "Privilege"
column admin_option format a12 heading "Admin option"

SELECT privilege, admin_option
FROM dba_sys_privs
WHERE grantee = '&schema'
ORDER BY 1
/
