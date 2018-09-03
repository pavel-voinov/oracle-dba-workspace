/*
*/
set serveroutput on size unlimited echo off scan on verify off

ACCEPT p_object_type DEFAULT '*' PROMPT "Object type [all, if not specified]: "

define all_object_types='PROCEDURE,FUNCTION,TYPE,PACKAGE,TRIGGER,MATERIALIZED VIEW,VIEW,SYNONYM,SEQUENCE,TABLE,DATABASE LINK,REFRESH GROUP'

set termout off
column schema new_value schema
column object_type new_value object_type
SELECT sys_context('USERENV', 'CURRENT_SCHEMA') as schema,
  '^(' || replace(decode('&p_object_type', '*', '&all_object_types', upper('&p_object_type')), ',', '|') || ')$' as object_type
FROM dual;
set termout on

PROMPT Drop database objects in current schema ("&schema"):
PROMPT ----------------------------------------------------
PROMPT Objects count before:
SELECT count(*) as cnt
FROM all_objects
WHERE owner = '&schema'
  AND regexp_like(object_type, '&object_type')
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (SELECT object_name, object_type
            FROM all_objects
            WHERE owner = '&schema'
              AND regexp_like(object_type, '&object_type')
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
            WHERE rowner = '&schema'
              AND regexp_like('REFRESH GROUP', '&object_type'))
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
SELECT object_type, object_name
FROM all_objects WHERE owner = '&schema'
  AND regexp_like(object_type, '&object_type')
ORDER BY 1, 2
/

undefine schema
