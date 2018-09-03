/*

Script to grant specified privileges on specified object types in defined schema to specified user
*/
set serveroutput on size 1000000 verify off timing off feedback off termout on echo off

define p_user='&1'
define p_owner='&2'
define p_object_type='&3'
define p_privilege='&4'

declare
  l_owner    varchar2(32) := upper('&p_owner');
  l_user     varchar2(32) := upper('&p_user');
  l_obj_type varchar2(255) := upper('&p_object_type');
  l_priv     varchar2(255) := upper('&p_privilege');

  procedure exec_SQL(p_SQL varchar2)
  is
  begin
    dbms_output.put_line(p_SQL || ';');
    execute immediate p_SQL;
  exception when others then
    dbms_output.put_line(SQLERRM);
  end exec_SQL;
  
begin
  dbms_output.enable(null);

  for x in (SELECT 'GRANT ' || l_priv || ' ON "' || owner || '"."' || object_name || '" TO "' || l_user || '"' as grant_sql
            FROM dba_objects
            WHERE owner = l_owner
              AND object_type IN ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
              AND regexp_like(l_priv, '(SELECT|INSERT|DELETE|UPDATE|FLASHBACK|ALTER)')
              AND regexp_like(object_type, '^(' || replace(l_obj_type, ',', '|') || ')$'))
  loop
    exec_SQL(x.grant_sql);
  end loop;

  for x in (SELECT 'GRANT ' || l_priv || ' ON "' || owner || '"."' || object_name || '" TO "' || l_user || '"' as grant_sql
            FROM dba_objects
            WHERE owner = l_owner
              AND object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'TYPE')
              AND regexp_like(l_priv, '(EXECUTE|ALTER)')
              AND regexp_like(object_type, '^(' || replace(l_obj_type, ',', '|') || ')$'))
  loop
    exec_SQL(x.grant_sql);
  end loop;
end;
/
set echo on
