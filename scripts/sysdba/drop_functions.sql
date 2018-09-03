/*
*/
set serveroutput on size unlimited echo off scan on verify off

define schema=&1

PROMPT Drop all functions in schema &schema:

PROMPT Functions count - before:
SELECT count(*) as cnt FROM dba_objects WHERE owner = upper('&schema') AND object_type = 'FUNCTION'
/
declare
  l_SQL varchar2(32000);
begin
  dbms_output.enable(null);
  for t in (select owner, object_name
            from dba_objects
            where owner = upper('&schema')
              and object_type = 'FUNCTION')
  loop
    l_SQL := 'DROP FUNCTION "' || t.owner || '"."' || t.object_name || '"';
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
PROMPT Functions remained in schema:
SELECT owner, object_name as function_name FROM dba_objects WHERE owner = upper('&schema') AND object_type = 'FUNCTION'
ORDER BY 1, 2
/
