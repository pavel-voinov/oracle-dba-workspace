/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all packages in schema &schema:

PROMPT Packages count - before:
SELECT count(*) as cnt FROM dba_objects WHERE owner = upper('&schema') AND object_type = 'PACKAGE'
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, object_name
            from dba_objects
            where owner = upper('&schema')
              and object_type = 'PACKAGE')
  loop
    l_SQL := 'DROP PACKAGE "' || t.owner || '"."' || t.object_name || '"';
    begin
      dbms_output.put(l_SQL || ';');
      execute immediate l_SQL;
      dbms_output.put_line(' -- OK');
    exception when others then
      dbms_output.put_line(':' || SQLERRM);
    end;
  end loop;
end;
/
PROMPT Packages remained in schema:
SELECT owner, object_name as package_name FROM dba_objects WHERE owner = upper('&schema') AND object_type = 'PACKAGE'
ORDER BY 1, 2
/
