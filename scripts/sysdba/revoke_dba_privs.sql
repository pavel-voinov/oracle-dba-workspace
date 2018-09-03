@system_users_filter.sql
@system_roles_filter.sql
@system_obj_privs.sql

PROMPT Users with DBA-level privileges (before):
@r/users_with_dba_privs.sql

begin
  for q in (
SELECT 'REVOKE ' || granted_role || ' FROM "' || grantee || '"' as sql_text
FROM dba_role_privs
WHERE regexp_like(granted_role, '^(DBA|RESOURCE|.*_FULL_DATABASE)$')
  AND not regexp_like(grantee, :v_sys_users_regexp)
  AND not regexp_like(grantee, :v_sys_roles_regexp)
  AND not regexp_like(grantee, :v_sys_roles1_regexp)
UNION ALL
SELECT 'REVOKE ' || privilege || ' FROM "' || grantee || '"' as sql_text
FROM dba_sys_privs
WHERE regexp_like(privilege, '^(UNLIMITED TABLESPACE|CREATE(| PUBLIC) DATABASE LINK|(DROP|CREATE) ANY.*)$')
  AND not regexp_like(grantee, :v_sys_users_regexp)
  AND not regexp_like(grantee, :v_sys_roles_regexp)
  AND not regexp_like(grantee, :v_sys_roles1_regexp)
UNION ALL
SELECT 'REVOKE '|| privilege || ' ON "' || owner|| '"."' || table_name || '" FROM "'|| grantee ||'"' as sql_text
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
ORDER BY 1)
  loop
    execute immediate q.sql_text;
  end loop;
end loop;
/

PROMPT Users with DBA-level privileges (after):
@r/users_with_dba_privs.sql
