/*
*/
set serveroutput on size unlimited echo off scan on verify off

set termout off
column schema new_value schema
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as schema FROM dual;
set termout on

PROMPT Drop all database objects in schema "&schema":

PROMPT Objects count before:
SELECT count(*) as cnt FROM all_objects WHERE owner = '&schema'
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT object_name, object_type
            FROM all_objects
            WHERE owner = '&schema'
              AND object_type in ('PROCEDURE', 'FUNCTION', 'TYPE', 'PACKAGE', 'TRIGGER', 'MATERIALIZED VIEW', 'VIEW', 'SYNONYM', 'SEQUENCE', 'TABLE', 'DATABASE LINK')
              AND secondary = 'N'
            ORDER BY decode(object_type, 'PROCEDURE', 1, 'FUNCTION', 2, 'TYPE', 3, 'PACKAGE', 4, 'TRIGGER', 5,
              'MATERIALIZED VIEW', 6, 'VIEW', 7, 'SYNONYM', 8, 'SEQUENCE', 9, 10))
  loop
    l_SQL := 'DROP ' || t.object_type || ' "' || t.object_name || '"';
    if t.object_type = 'TABLE' then
      l_SQL := l_SQL || ' CASCADE CONSTRAINTS PURGE';
    end if;
    begin
      dbms_output.put(l_SQL);
      execute immediate l_SQL;
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
begin
  dbms_output.enable(null);
  for t in (SELECT rname as group_name
            FROM all_refresh
            WHERE rowner = '&schema')
  loop
    begin
      dbms_output.put('Drop refresh group: ' || t.group_name);
      dbms_refresh.destroy('"' || t.group_name || '"');
      dbms_output.put_line(' - OK');
    exception when others then
      dbms_output.put_line(': ' || SQLERRM);
    end;
  end loop;
end;
/
PROMPT Objects count after:
SELECT object_name, object_type FROM all_objects WHERE owner = '&schema'
/

undefine schema
