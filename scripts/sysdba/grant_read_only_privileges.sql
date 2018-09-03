set serveroutput on size unlimited

define p_user=&1
define p_schema=&2

declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for o in (SELECT owner, table_name
            FROM dba_tables
            WHERE regexp_like(owner, '^&p_schema.$', 'i')
              AND secondary = 'N' AND iot_name is null
            UNION ALL
            SELECT o.owner, o.view_name
            FROM dba_views o, dba_dependencies d
            WHERE regexp_like(o.owner, '^&p_schema.$', 'i')
              AND d.owner(+) = o.owner
              AND d.type(+) = 'VIEW'
              AND d.name(+) = o.view_name
              AND d.referenced_owner(+) NOT IN ('SYS', 'PUBLIC')
              AND d.owner is null
            MINUS
            SELECT owner, table_name
            FROM dba_tab_privs
            WHERE grantee = upper('&p_user'))
  loop
    l_SQL := 'GRANT SELECT ON "' || o.owner || '"."' || o.table_name || '" TO &p_user.';
    dbms_output.put_line(l_SQL || ';');
    begin
      execute immediate l_SQL;
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
declare
  l_SQL  varchar2(32000);
begin
  dbms_output.enable(null);
  for o in (
SELECT owner, name, referenced_owner, referenced_name, referenced_type, decode(referenced_type, 'TYPE', 'EXECUTE', 'SELECT') as privilege
FROM dba_dependencies d
WHERE not regexp_like(referenced_owner, '^(SYS|PUBLIC|C\$MDLICHEM??)$')
  AND referenced_owner <> owner
CONNECT BY PRIOR owner = referenced_owner
  AND PRIOR name = referenced_name
  AND PRIOR type = referenced_type
START WITH regexp_like(owner, '^&p_schema.$', 'i') AND type IN ('VIEW', 'SYNONYM')
ORDER BY decode(referenced_type, 'TYPE', 0, 1))
  loop
    l_SQL := 'GRANT ' || o.privilege || ' ON "' || o.referenced_owner || '"."' || o.referenced_name || '" TO "' || o.owner || '" WITH GRANT OPTION';
    dbms_output.put_line(l_SQL || ';');
    begin
      execute immediate l_SQL;
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
    l_SQL := 'GRANT SELECT ON "' || o.owner || '"."' || o.name || '" TO &p_user.';
    dbms_output.put_line(l_SQL || ';');
    begin
      execute immediate l_SQL;
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
begin
  dbms_output.enable(null);
  for g in (SELECT 'GRANT EXECUTE ON "' || o.owner || '"."' || o.object_name || '" TO "' || upper('&p_user') || '"' as sql_text
            FROM dba_objects o
            WHERE o.owner = upper('&p_schema')
              AND o.object_type IN ('TYPE', 'FUNCTION')  -- PACKAGE, PROCEDURE
              AND not exists (SELECT null FROM dba_source x
                              WHERE x.owner = o.owner
                                AND x.name = o.object_name
                                AND regexp_like(x.text, 'AUTHID DEFINER', 'i')))
  loop
    dbms_output.put_line(g.sql_text);
    begin
      execute immediate g.sql_text;
    exception when others then
      dbms_output.put_line(SQLERRM);
    end;
  end loop;
end;
/
