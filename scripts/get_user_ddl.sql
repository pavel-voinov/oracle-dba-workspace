set serveroutput on size unlimited verify off timing off feedback off linesize 32000 pagesize 0 heading off long 2000000 autotrace off newpage none trimspool on termout on

PROMPT Saving DDL for user &1 into &2

set termout off

@system_users_filter.sql
@reports/db_version.sql

set termout off

define file_name='&2'
column file_name new_value file_name
column username new_value username
column uobj_type new_value uobj_type

variable v_user varchar2(30);
exec :v_user := upper('&1');

SELECT replace('&file_name', '$', '\$') as file_name
FROM dual
/
column q_select new_value q_select
column g_select new_value g_select
SELECT case
         when to_number('&db_version') < 11 then
           'wm_concat(replace(''QUOTA '' || decode(max_bytes, -1, ''UNLIMITED'', to_char(ceil(max_bytes / power(2, 20))) || ''M'') || '' ON "'' || tablespace_name || ''"'', '','', '' ''))'
         else
           'listagg(''QUOTA '' || decode(max_bytes, -1, ''UNLIMITED'', to_char(ceil(max_bytes / power(2, 20))) || ''M'') || '' ON "'' || tablespace_name || ''"'', '' '') within group (order by tablespace_name) || '';'''
       end as q_select,
       case
         when to_number('&db_version') < 11 then
           'wm_concat(privilege)'
         else
           'listagg(privilege, '', '') within group (order by decode(privilege, ''SELECT'', 1, ''EXECUTE'', 2, ''INSERT'', 3, ''UPDATE'', 4, ''DELETE'', 5, 6))'
       end as g_select
FROM dual
/

whenever sqlerror exit failure

begin
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'PRETTY', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'SQLTERMINATOR', true);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'OID', false);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform, 'FORCE', true);
end;
/
column sql_text format a32000 word_wrapped

set feedback off

spool &file_name append

PROMPT set serveroutput on size unlimited timing off define off scan off verify off
PROMPT

--SELECT regexp_replace(sql_text, '\;[[:space:]]*$', chr(10) || '/', 1, 0, 'mn') as sql_text
SELECT sql_text
FROM (SELECT to_clob('/* Create user */') as sql_text FROM dual
      UNION ALL
      SELECT dbms_metadata.get_ddl('USER', :v_user)
      FROM dba_users
      WHERE username = :v_user
      UNION ALL
      SELECT to_clob('/* Tablespace quotas */') FROM dual
      UNION ALL
      SELECT to_clob('ALTER USER "' || username || '" ' || to_char(&q_select))
      FROM dba_ts_quotas
      WHERE username = :v_user AND dropped = 'NO'
      GROUP BY username
      UNION ALL
      SELECT to_clob('/* Roles */') FROM dual
      UNION ALL
      SELECT to_clob(ddl_text)
      FROM (SELECT 'GRANT "' || granted_role || '" TO "' || grantee || '"' || decode(admin_option, 'YES', ' WITH ADMIN OPTION') || ';' as ddl_text
            FROM dba_role_privs
            WHERE grantee = :v_user
            ORDER BY granted_role)
      UNION ALL
      SELECT to_clob('/* Default roles */') FROM dual
      UNION ALL
      SELECT dbms_metadata.get_granted_ddl('DEFAULT_ROLE', :v_user)
      FROM dual
      WHERE exists (SELECT null FROM dba_role_privs WHERE grantee = :v_user)
      UNION ALL
      SELECT to_clob('/* System privileges */') FROM dual
      UNION ALL
      SELECT to_clob(ddl_text)
      FROM (SELECT 'GRANT ' || privilege || ' TO "' || grantee || '"' || decode(admin_option, 'YES', ' WITH ADMIN OPTION') || ';' as ddl_text
            FROM dba_sys_privs
            WHERE grantee = :v_user
            ORDER BY privilege)
      UNION ALL
      SELECT to_clob('/* Privileges granted on system objects */') FROM dual
      UNION ALL
      SELECT to_clob(ddl_text)
      FROM (SELECT 'GRANT ' || to_char(&g_select) ||
              ' ON "' || owner || '"."' || table_name || '" TO "' || grantee || '"' || decode(grantable, 'YES', ' WITH GRANT OPTION') || ';' as ddl_text
            FROM dba_tab_privs
            WHERE grantee = :v_user
              AND regexp_like(owner, :v_sys_users_regexp)
            GROUP BY grantee, owner, table_name, grantable
            ORDER BY owner, table_name)
      UNION ALL
      SELECT to_clob('/* Proxy */') FROM dual
      UNION ALL
      SELECT dbms_metadata.get_granted_ddl('PROXY', :v_user)
      FROM dual
      WHERE exists (SELECT null FROM dba_proxies WHERE client = :v_user)
      UNION ALL
      SELECT to_clob('ALTER USER "' || client || '" GRANT CONNECT THROUGH "' || proxy || '";')
      FROM dba_proxies
      WHERE proxy = :v_user
      UNION ALL
      SELECT to_clob('/* Object privileges granted to user */') FROM dual
      UNION ALL
      SELECT to_clob(ddl_text)
      FROM (SELECT 'GRANT ' || to_char(&g_select) ||
              ' ON "' || owner || '"."' || table_name || '" TO "' || grantee || '"' || decode(grantable, 'YES', ' WITH GRANT OPTION') || ';' as ddl_text
            FROM dba_tab_privs
            WHERE grantee = :v_user
              AND not regexp_like(owner, :v_sys_users_regexp)
            GROUP BY grantee, owner, table_name, grantable
            ORDER BY owner, table_name)
     )
     UNION ALL
     SELECT to_clob('/* System triggers */') FROM dual
     UNION ALL
     SELECT dbms_metadata.get_ddl('TRIGGER', trigger_name, :v_user)
     FROM dba_triggers
     WHERE owner = :v_user
       AND trim(triggering_event) IN ('LOGON', 'DDL')
/

set termout on

spool off

exit
