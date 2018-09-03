/*
*/
@@reports.inc
@system_users_filter.sql
@system_roles_filter.sql
@system_obj_privs.sql

column grantee format a30 heading "User name"
column granted_role format a30 heading "Role name"
column privilege format a30 heading "Privilege"
column admin_option format a15 heading "Admin option"
column owner format a30 heading "Owner"
column table_name format a30 heading "ObjectName"
column grantable format a15 heading "Grantable"

SELECT grantee, granted_role, admin_option
FROM dba_role_privs
WHERE regexp_like(granted_role, '^(DBA|RESOURCE|.*_FULL_DATABASE)$')
  AND not regexp_like(grantee, :v_sys_users_regexp)
  AND not regexp_like(grantee, :v_sys_roles_regexp)
  AND not regexp_like(grantee, :v_sys_roles1_regexp)
ORDER BY 1, 2
/

SELECT grantee, privilege, admin_option
FROM dba_sys_privs
WHERE regexp_like(privilege, '^(UNLIMITED TABLESPACE|CREATE(| PUBLIC) DATABASE LINK|(DROP|CREATE) ANY.*)$')
  AND not regexp_like(grantee, :v_sys_users_regexp)
  AND not regexp_like(grantee, :v_sys_roles_regexp)
  AND not regexp_like(grantee, :v_sys_roles1_regexp)
ORDER BY 1, 2
/

SELECT grantee, owner, table_name, privilege, grantable
FROM dba_tab_privs a
WHERE not regexp_like(grantee, :v_sys_users_regexp)
  AND not regexp_like(grantee, :v_sys_roles_regexp)
  AND not regexp_like(grantee, :v_sys_roles1_regexp)
  AND grantor = 'SYS'
  AND not regexp_like(table_name, :v_sys_objprivs_regexp)
  AND not exists (
                  select 1 
                  from dba_directories 
                  where owner = a.owner 
                  and directory_name = a.table_name
                  )
ORDER BY 1, 2, 3
/

